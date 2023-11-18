# load gem and connect database
require 'app/mysaas'
require 'app/lib/stubs'
require 'app/config'
require 'app/version'
DB = BlackStack::CRDB::connect
require 'app/lib/skeletons'
require 'app/extensions/i2p/lib/skeletons'

# add required extensions
BlackStack::Extensions.append :i2p

l = BlackStack::LocalLogger.new('./export.log')

while true
  i = 0 

  begin

    # restart exports who have finished, but have leads added after their last processing
    l.logs 'Restarting... '
    BlackStack::Leads::Export::restart(l)
    l.done

    # iterate all exports with no start time, and a search.
    exports = BlackStack::Leads::Export.where(:create_file_success=>nil, :delete_time=>nil, :archive_success=>nil, :archive_start_time=>nil).all
    exports.each do |export|
        i += 1

      l.logs "Processing export #{export.id}"
      begin
        l.logs 'Flag start_time... '
        export.create_file_start_time = now
        export.save
        l.done

        l.logs 'Flood export... '
        if export.id_search.nil?
          l.logf 'No search specified'
        else
          export.flood(l)
          l.done
        end
# deprecated by now
=begin
        l.logs 'Generate file... '
        # https://github.com/leandrosardi/cs/issues/27
        export.generate_file(l)
        l.done
=end
        l.logs 'Flag end_time... '
        export.no_of_results = export.fl_export_leads.count
        export.no_of_companies = export.count_companies
        export.create_file_end_time = now
        export.create_file_success=true
        export.save
        l.done
      rescue => e
        l.logf "Error: #{e.message}"

        l.logs 'Flag error... '
        export.create_file_end_time = now
        export.create_file_success = false
        export.create_file_error_description = e.message
        export.save
        l.done
      end
      l.done

    end # exports.each 
  rescue => e
    l.logf "Error: #{e.message}"
  end 

  l.logs 'Sleeping... '
  if i==0
    sleep(60)
    l.done
  else
    l.no
  end

end # while true