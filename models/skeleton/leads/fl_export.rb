module BlackStack
module Leads
  class Export < Sequel::Model(:fl_export)
    many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
    many_to_one :fl_search, :class=>:'BlackStack::Leads::Search', :key=>:id_search
    one_to_many :fl_export_leads, :class=>'BlackStack::Leads::ExportLead', :key=>:id_export

    # return campaigns if non-premium accounts with deliveries
    # no need to filter by `archive_success`, because any campaign with deliveries will be archived
    def self.ids_to_archive()
      q = "
        select a.name, a.id, e.id as id_export, count(x.id) as n_leads
        --select count(distinct a.id) as accounts, count(distinct e.id) as exports, count(distinct x.id) as leads
        from account a 
        join \"user\" u on a.id=u.id_account
        join fl_export e on u.id=e.id_user
        join fl_export_lead x on e.id=x.id_export
        where coalesce(a.premium,false)=false
        group by a.name, a.id, e.id
      "
      DB[q].all.map { |r| r[:id_export] }
    end

    # This method is for internal use only,
    # End-users should not call this method directly
    # 
    # Archive the following tables
    # - fl_company (canceled)
    # - fl_export_lead
    # - fl_data - delete all the private data not assigned to any export
    # - fl_lead - delete all the private leads not assigned to any export
    def self.archive(id, n=200, l=nil)
        l = BlackStack::DummyLogger.new(nil) if l.nil?

        # fl_export_lead
        l.logs 'archiving fl_export_lead... '
        n = DB.execute("
          insert into fl_export_lead_history
          select x.*
          --select count(distinct x.id_lead)
          from fl_export_lead x 
          where x.id_export='#{id}'
          limit #{n}
          on conflict do nothing 
        ")                
        l.done
        return false if n > 0

        l.logs 'deleting fl_export_lead... '
        n = DB.execute("
          delete from fl_export_lead where id in (select id from fl_export_lead_history) limit #{n} 
        ")
        l.done
        return false if n > 0

        # fl_data
        l.logs 'archiving fl_data... '
        n = DB.execute("
          insert into fl_data_history
          select * 
          --select count(*)
          from fl_data 
          where id_lead in ( 
                select x.id
                from fl_lead x
                join \"user\" u on (u.id=x.id_user and u.id_account='#{id}')
            left join fl_export_lead el on x.id=el.id_lead
            group by x.id
            having count(el.id)=0
          )
          limit #{n}
          on conflict do nothing  
        ")                
        l.done
        return false if n > 0

        l.logs 'deleting fl_data... '
        n = DB.execute("
          delete from fl_data where id in (select id from fl_data_history) limit #{n} 
        ")
        l.done
        return false if n > 0

        # fl_lead
        l.logs 'archiving fl_lead... '
        n = DB.execute("
          insert into fl_lead_history
          select * 
          --select count(*)
          from fl_lead 
          where id in ( 
                select x.id
                from fl_lead x
                join \"user\" u on (u.id=x.id_user and u.id_account='#{id}')
            left join fl_export_lead el on x.id=el.id_lead
            group by x.id
            having count(el.id)=0
          )
          limit #{n}
          on conflict do nothing  
        ")                
        l.done
        return false if n > 0

        l.logs 'deleting fl_lead... '
        n = DB.execute("
          delete from fl_lead where id in (select id from fl_lead_history) limit #{n} 
        ")
        l.done
        return false if n > 0
        
        return true
    end

    def archive(l=nil)
      l = BlackStack::DummyLogger.new(nil) if l.nil?
      begin
          l.logs 'flag archiving start... '
          self.flag_archive_start
          l.done

          res = false
          while !res
              res = BlackStack::Leads::Export.archive(self.id, 200, l)
          end

          l.logs 'flag archiving end... '
          self.flag_archive_end
          l.done
      rescue => e
          l.log "error: #{e.message}"

          l.logs 'flag archiving error... '
          self.flag_archive_end(false, e.message)
          l.done
      end
    end


    # return a hash descriptor for the data.
    def to_hash
      {
        :id => self.id.to_guid,
        :filename => self.filename,
        :delete_time => self.delete_time,
        :deleted => self.delete_time.nil? ? false : true,
      }
    end

    # restart the `create_file_` flags of this export
    def restart()
      self.create_file_reservation_id = nil
      self.create_file_reservation_time = nil
      self.create_file_reservation_times = nil
      self.create_file_start_time = nil
      self.create_file_end_time = nil
      self.create_file_success = nil
      self.create_file_error_description = nil
      self.save
    end

    # restart exports who have finished, but have leads added manually after their last processing, so the file is not up to date
    # restart exports with `continious_restarting==true` and `create_file_end_time` aged than 15 minutes,
    def self.restart(l=nil)
      l = BlackStack::DummyLogger.new(nil) if l.nil?

      # restart exports who have finished, but have leads added manually after their last processing, so the file is not up to date
      l.logs "Restarting exports with new leads to add manually to the file... "
      q = "
        SELECT DISTINCT e.id
        FROM fl_export e
        JOIN fl_export_lead el ON ( el.id_export = e.id AND el.create_time > e.create_file_end_time )
        WHERE e.delete_time IS NULL
        AND e.create_file_end_time IS NOT NULL
      "
      DB[q].all { |row| 
        l.logs "Restarting export #{row[:id]}... "
        BlackStack::Leads::Export.where(:id=>row[:id]).first.restart
        l.done
        # release resources
        GC.start
        DB.disconnect
      }
      l.done
    end

    # calculate how many more records can be added to the export,
    # based on 
    # 1. the number of credits available for the export,
    # 2. the number of records already exported, and
    # 3. the number of records requested by the export
    def left
      # number of results alreday present in the export
      n = BlackStack::Leads::ExportLead.where(:id_export=>self.id).count
      # number of results requested by the export
      m = self.number_of_records
      # credits available for the export
      c = nil
      if BlackStack::Extensions.exists?(:'dfy-leads') && self.fl_search.id_order
        # if the user is exporting leads from his own dfy-leads order... 
        # then, return the number of results requested in the export, 
        # or the number of results of the order.
        #
        # TODO: optimize the time required by this query, because it is loading all the objects in memory.
        #
        c = BlackStack::DfyLeads::Order.where(:id=>self.fl_search.id_order).first.dfyl_stat_leads_appended.to_i
      elsif self.fl_search.private_only == true
        # if the user is exporting leads owned by him (because he uploaded 
        # them) or because he got them from a dfy-leads order, then return 
        # the number of private leads of the user's account.
        c = BlackStack::Leads::Lead.where(:id_user=>self.user.account.users.map { |u| u.id }).count
      else
        c = BlackStack::I2P::Account.where(:id=>self.user.account.id).first.credits('leads') 
      end
      # total number of results to add
      m.nil? ? c : [c-n, m-n].min
    end

    # Returns SQL code to get the leads that I still can add to the export
    # For internal use only. User shouldn't call this method.
    def query_leads_to_add
      "SELECT DISTINCT gen_random_uuid(), CAST('#{now}' AS TIMESTAMP), '#{self.id}' as id_export, v.id as id_lead
      FROM (
        SELECT l.id
        #{self.fl_search.core}
        EXCEPT
        -- este lead no tuvo que haber sido exportado a esta lista antes
        SELECT DISTINCT el.id_lead
        FROM fl_export_lead el
        WHERE el.id_export='#{self.id}'
        /*
        EXCEPT
        -- este lead no tuvo que haber sido exportado a ninguna otra lista de esta cuenta
        SELECT DISTINCT el.id_lead
        FROM fl_export_lead el
        JOIN fl_export e ON ( e.id = el.id_export ) -- AND e.delete_time IS NULL
        JOIN \"user\" u ON ( u.id = e.id_user AND u.id_account = '#{self.user.id_account}' )
        --WHERE el.id_export='#{self.id}'
        */
      ) AS v "
    end

    # Returns number of leads that I still can add to the export
    def total_leads_to_add
      DB["
        SELECT COUNT(DISTINCT v.id_lead) as total
        FROM (
        #{self.query_leads_to_add}
        ) AS v
      "].first[:total]
    end

    # add `left` records to the export
    def flood(l=nil)
      l = BlackStack::DummyLogger.new(nil) if l.nil?
      n = 50 # batch size
      x = -1 # number of leads in the list last time I checked
      y = BlackStack::Leads::ExportLead.where(:id_export=>self.id).count
      # flood the export
      while x != y
        # add leads to the export
        l.logs "Adding #{n} leads to the export... "
        q = "
          INSERT INTO fl_export_lead ( id, create_time, id_export, id_lead )
          #{self.query_leads_to_add}
          LIMIT #{n.to_s}
        "
        DB.execute(q)
        x = y
        y = BlackStack::Leads::ExportLead.where(:id_export=>self.id).count
        l.logf "#{y} leads in the list."
      end # while
    end

    # return a string with the CSV content
    def write_file(f, l=nil)
      l = BlackStack::DummyLogger.new(nil) if l.nil?
      batch_size = 500
      ret = ""

      # write header
      l.logs "Writing header... "
      ret += "LEAD_ID,"
      ret += "LEAD_NAME,"
      ret += "LEAD_FIRST_NAME,"
      ret += "LEAD_LAST_NAME,"
      ret += "LEAD_JOB_POSITION,"
      ret += "LEAD_LINKEDIN_URL,"
      ret += "COMPANY_NAME,"
      ret += "COMPANY_LINKEDIN_URL,"
      ret += "LEAD_INDUSTRY,"
      ret += "LEAD_LOCATION,"
      ret += "LEAD_CITY,"
      ret += "LEAD_STATE,"
      ret += "LEAD_COUNTRY,"
      ret += "LEAD_METRO_AREA,"
      ret += "LEAD_SCOPE,"
      #ret += "DATA_TYPE,"
      
      ret += "EMAIL1,"
      ret += "VERIFIED1,"
      ret += "TRUST_RATE1,"
      ret += "EMAILLISTVERIFY_STATUS1,"
      ret += "ZEROBOUNCE_STATUS1,"
      ret += "DEBOUNCE_STATUS1,"

      ret += "EMAIL2,"
      ret += "VERIFIED2,"
      ret += "TRUST_RATE2,"
      ret += "EMAILLISTVERIFY_STATUS2,"
      ret += "ZEROBOUNCE_STATUS2,"
      ret += "DEBOUNCE_STATUS2,"

      ret += "EMAIL3,"
      ret += "VERIFIED3,"
      ret += "TRUST_RATE3,"
      ret += "EMAILLISTVERIFY_STATUS3,"
      ret += "ZEROBOUNCE_STATUS3,"
      ret += "DEBOUNCE_STATUS3,"

      ret += "PHONE1,"
      ret += "PHONE2,"
      ret += "PHONE3,"

      ret += "COMPANY_INSIGHT1,"
      ret += "COMPANY_INSIGHT2,"
      ret += "COMPANY_INSIGHT2,"

      ret += "LEAD_INSIGHT1,"
      ret += "LEAD_INSIGHT2,"
      ret += "LEAD_INSIGHT3,"

      ret += "COMPANY_WEBISTE_TITLE,"
      ret += "COMPANY_WEBISTE_META_KEYWORDS,"
      ret += "COMPANY_WEBISTE_META_DESCRIPTION,"

      ret += "\n"
      f.write(ret)
      f.flush
      l.done

      ret = ""

      l.logs "Getting list of unique id_lead... "
      ids = self.fl_export_leads.map { |o| o.id_lead }.uniq
      l.logf "done (#{ids.size})"

      l.logs "Getting batches of id_lead... "
      ids = ids.each_slice(batch_size).to_a
      l.logf "done (#{ids.size})"

      batch_number = 0
      ids.each { |batch|
        batch_number += 1
  
        l.logs "Loading leads from batch #{batch_number.to_s}... "
        leads = BlackStack::Leads::Lead.where(:id=>batch).all
        l.logf "done (#{leads.size})"

        l.logs "Loading datas from batch #{batch_number.to_s}... "
        batch_datas = BlackStack::Leads::Data.where(:id_lead=>batch).all
        l.logf "done (#{batch_datas.size})"

        l.logs "Loading companies from batch #{batch_number.to_s}... "
        batch_companies = BlackStack::Leads::Company.where(:id=>leads.select { |o| !o.id_company.nil? }.map { |o| o.id_company }).all
        l.logf "done (#{batch_companies.size})"

        l.logs "Writing batch #{batch_number.to_s}.... "
        leads.each { |lead|
          #l.logs "Writing lead #{lead.id}... "
          datas = batch_datas.select { |o| o.id_lead==lead.id }
          company = batch_companies.select { |o| o.id==lead.id_company }.first

          lead_linkedin_url = batch_datas.select { |d| d.id_lead==lead.id && d.type==BlackStack::Leads::Data::TYPE_LINKEDIN }.map { |d| d.value }.join(',')
          company_linkedin_url = company.nil? ? nil : company.linkedin_url

          ret += "#{lead.id},"
          ret += "\"#{lead.name.to_s.gsub('"', '')}\","
          ret += "\"#{lead.first_name.to_s.gsub('"', '').capitalize}\","
          ret += "\"#{lead.last_name.to_s.gsub('"', '').capitalize}\","
          ret += "\"#{lead.position.to_s.gsub('"', '')}\","
          ret += "\"#{lead_linkedin_url.to_s.gsub('"', '')}\","
          ret += "\"#{lead.stat_company_name.to_s.gsub('"', '')}\","
          ret += "\"#{company_linkedin_url.to_s.gsub('"', '')}\","
          ret += "\"#{lead.stat_industry_name.to_s.gsub('"', '')}\","
          ret += "\"#{lead.stat_location_name.to_s.gsub('"', '')}\","
          ret += "\"#{lead.stat_city_name.to_s.gsub('"', '')}\","
          ret += "\"#{lead.stat_state_name.to_s.gsub('"', '')}\","
          ret += "\"#{lead.stat_country_name.to_s.gsub('"', '')}\","
          ret += "\"#{lead.stat_area_name.to_s.gsub('"', '')}\","
          ret += "\"#{lead.id_user ? 'private' : 'public'}\","

          i = 0
          datas.select { |d| d.type == BlackStack::Leads::Data::TYPE_EMAIL }.each { |d|
            i += 1
            break if i>3
            ret += "\"#{d.value.to_s.gsub('"', '')}\","
            ret += "\"#{d.verified ? 'verified' : ''}\","
            if d.verified
              ret += "\"100%\","
            else
              ret += "\"#{d.trust_rate ? "#{d.trust_rate.to_s}%" : ''}\","
            end
            ret += "\"#{d.ev_status}\","
            ret += "\"#{d.zb_status}\","
            ret += "\"#{d.db_status}\","
          }
          while i<3
            i += 1
            ret += '"","","","","","",'
          end

          i = 0
          datas.select { |d| d.type == BlackStack::Leads::Data::TYPE_PHONE }.each { |d|
            i += 1
            break if i>3
            ret += "\"#{d.value.to_s.gsub('"', '')}\","
          }
          while i<3
            i += 1
            ret += '"",'
          end

          i = 0
          batch_company_insights.select { |o| o.id_company == company.id }.each { |o|
            i += 1
            break if i>3
            ret += "\"#{o.response.to_s.gsub('"', '')}\","
          }
          while i<3
            i += 1
            ret += '"",'
          end

          i = 0
          batch_lead_insights.select { |o| o.id_lead == lead.id }.each { |o|
            i += 1
            break if i>3
            ret += "\"#{o.response.to_s.gsub('"', '')}\","
          }
          while i<3
            i += 1
            ret += '"",'
          end

          ret += "\"#{company.title.to_s.gsub('"', '')}\","
          ret += "\"#{company.meta_keywords.to_s.gsub('"', '')}\","
          ret += "\"#{company.meta_description.to_s.gsub('"', '')}\","

          ret += "\n"

          #l.done
          # release resources
          GC.start
          DB.disconnect
        } # leads.each { |l|

        #l.logs "Writing batch... "
        f.write(ret)
        ret = ""
        f.flush
        #l.done

        l.done # "Writing batch #{batch_number.to_s}... done"
      } # ids.each { |batch|
    end

    # create the storage folder of the account
    # bulld the fullfilename = path + filename
    # delete any existing file with this name, in case that this is a re-processing
    # create the file
    def generate_file(l=nil)
      l = BlackStack::DummyLogger.new(nil) if l.nil?
      # create the storage folder of the account
      self.user.account.create_storage
      # bulld the fullfilename = path + filename
      # convert string to (valid) filename
      # reference: https://ruby-talk.ruby-lang.narkive.com/qOq73iiK/string-to-valid-filename
      newfilename = "#{self.filename.strip.gsub('&', '_').gsub(' ', '_').gsub('  ', '_').gsub('-', '_').gsub('"', '_')}.#{self.id}"
      fullfilename = "/tmp/#{newfilename}.csv"
      # delete any existing file with this name, in case that this is a re-processing
      File.delete(fullfilename) if File.exists?(fullfilename)
      # create the file
      f = File.open(fullfilename, 'w')
      self.write_file(f, l)
      f.close
      # upload file to dropbox using my-dropbox-api
      res = BlackStack::DropBox.dropbox_upload_file(fullfilename, "/.leads.exports/#{newfilename}.csv")
      # delete the file
      File.delete(fullfilename)
      # get the file link
      # update the file link
      self.download_url = BlackStack::DropBox.get_file_url("/.leads.exports/#{newfilename}.csv")
      self.save
    end

    # return the unique companies in the export
    def count_companies
      q = "
        SELECT COUNT(DISTINCT l.id_company) AS n
        FROM fl_export_lead el
        JOIN fl_lead l ON ( l.id = el.id_lead )
        WHERE el.id_export = '#{self.id}'
      "
      DB[q].first[:n]
    end

    # if the lead is not belonging this export, then add the lead to this export.
    # restart the export for generate the file.
    # return the object ExportLead.
    def add(lead)
      # find existing export_lead record
      x = BlackStack::Leads::ExportLead.where(:id_export=>self.id, :id_lead=>lead.id).first
      return if x
      # create new export_lead record
      x = BlackStack::Leads::ExportLead.new()
      x.id = guid
      x.create_time = now
      x.id_export = self.id 
      x.id_lead = lead.id
      x.save
      # request `create_file` reprocessing
      self.restart
      # return
      x
    end

  end
end
end