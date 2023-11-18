module BlackStack
    # this module resolves most of the work when drawing a table with pagination.
    module TableHelper

    # return an array of hashes with the columns of the table
    def columns
        raise 'BlackStack::TableHelper::columns: method is abstract. Code it yourself in your child class.'
    end

    # This method works with the TableHelper module.
    # Return the FROM-WHERE part of the SQL query to retrieve the results of the table, with not pagination nor sorting, nor listed columns.
    # This method is used to build custom queries on other methods.
    def core(h={})
        raise 'BlackStack::TableHelper::core: method is abstract. Code it yourself in your child class.'
    end

    # TODO: move this to a super-module called BlackStack::MySaas::Paginable 
    def validate_pagination_descriptor(h)
        errors = []
  
        # validation: h must be a hash
        errors << "h must be a hash" if !h.is_a?(Hash)
  
        if h.is_a?(Hash)
            # validation: :page is required
            errors << "page is required" if h['page'].nil?
  
            # validation: :pagesize is required
            errors << "pagesize is required" if h['pagesize'].nil?
  
            # validation: :sortcolumn is required
            errors << "sortcolumn is required" if h['sortcolumn'].nil?
  
            # validation: :sortorder is required
            errors << "sortorder is required" if h['sortorder'].nil?
  
            # validation: the value of :sortcolumn must be a valid string
            errors << "sortcolumn must be a valid string" if !h['sortcolumn'].nil? && !h['sortcolumn'].is_a?(String)
  
            # validation: the value of :sortorder must be a valid string or nil
            errors << "sortorder must be a valid string" if !h['sortorder'].nil? && !h['sortorder'].is_a?(String)
  
            # validation: if :sortorder is a string, it must be either 'asc' or 'desc'
            if !h['sortorder'].nil? && h['sortorder'].is_a?(String)
                errors << "sortorder must be either 'asc' or 'desc'" if h['sortorder']!='asc' && h['sortorder']!='desc'
            end
  
            # validation: the value of :page must be a valid integer or nil
            errors << "page must be a valid integer" if !h['page'].nil? && !h['page'].is_a?(Integer)
  
            # validation: the value of :pagesize must be a valid integer or nil
            errors << "pagesize must be a valid integer" if !h['pagesize'].nil? && !h['pagesize'].is_a?(Integer)
        end
        # return the array of errors
        errors
    end
  
    def validate_columns_descriptor(h)
        errors = []
  
        # validate: h must be a hash
        errors << "columns must be a hash" if !h.is_a?(Hash)
  
        # other validations
        if h.is_a?(Hash)
            # validattion: :query_field is required
            errors << "query_field is required" if h['query_field'].nil?
  
            # validation: :query_field must be a string
            errors << "query_field must be a string" if !h['query_field'].nil? && !h['query_field'].is_a?(String)
        end
  
        # return
        errors
    end
  
    # total number of unique leads matching with this search
    def count(h={})
        q = "SELECT COUNT(*) AS n #{self.core(h)}"
        DB[q].first[:n]
    end
  
    # return a hash descriptor with the status of the pagination: row_from, row_to, total_rows, total_pages, page (after revision)
    def status(h={})
        # validate the pagination descriptor
        errors = self.validate_pagination_descriptor(h)
  
        # raise an exception if there are errors
        raise "Errors found:\n#{errors.join("\n")}" if errors.size>0
  
        # get parameters
        page_number = h['page'].to_i
        page_size = h['pagesize'].to_i
  
        total_rows = self.count
        total_pages = (total_rows.to_f/page_size.to_f).ceil.to_i

        if total_rows > 0
            # pagination correction to prevent glitches
            page_number = 1 if page_number < 1
            page_number = total_pages if page_number > total_pages
    
            # calculate info for showing at the bottom of the table
            from_row = (page_number.to_i-1) * page_size.to_i + 1
            to_row = [page_number*page_size, total_rows].min
        else
            page_number = 1
            from_row = 0
            to_row = 0
        end

        # return
        {
            'row_from' => from_row,
            'row_to' => to_row,
            'total_rows' => total_rows,
            'total_pages' => total_pages,
            'page' => page_number
        }
    end
  
    # return an array of leads, filtering by the parameters of this search, and paginating and sorting by the parameters received.
    def rows(h={})
        # validate the pagination descriptor
        errors = self.validate_pagination_descriptor(h)
  
        # raise an exception if there are errors
        raise "Errors found:\n#{errors.join("\n")}" if errors.size>0
  
        # get pagination status
        p = self.status(h)
  
        # get the list of leads
        column_names = self.columns(h).map {|c| c['query_field'] }
        q = "
            SELECT #{column_names.join(', ')}
            #{self.core(h)}
            -- sorting
            ORDER BY l.#{h['sortcolumn']} #{h['sortorder']}
            -- pagination
            LIMIT #{h['pagesize']}
            OFFSET #{(h['page'].to_i - 1) * h['pagesize'].to_i}
        "
        DB[q].all
      end 
    end # module TableHelper
end # module BlackStack