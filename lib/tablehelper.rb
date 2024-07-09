module BlackStack
    module TableHelper

        # This method resolves the pagination problem.
        #
        # Parameters:
        # - a: It is a Sequel dataset like `DB["SELECT name FROM users"]`
        # - p: Is the page number.
        # - z: Is the page size.
        # - sort_column: Is the column to sort the dataset. Default: nil.
        # - sort_order: Is the order to sort the dataset. Default: :asc.
        # - cls: Is the class of the objects that will be returned.
        #
        # Return a hash with the following keys:
        # - from_row: The first row of the dataset.
        # - to_row: The last row of the dataset.
        # - t: The total number of pages in the dataset.
        # - p: The real page number you receive, in case the requested p is out of scope.
        # 
        def self.page(a:, p:, z:, sort_column: nil, sort_order: :asc, cls:)
            raise "TableHelper error: the parameter `sort_order` allows the values:asc and :desc only." if sort_order != :asc && sort_order != :desc

            # pagination
            # `LIMIT #{page_size.to_s} OFFSET #{((page_number.to_i - 1) * page_size.to_i).to_s}`
            # TODO: create re-utilizable functions for this.
            page_size = z
            total_rows = a.count
            page_number = p
            from_row = nil
            to_row = nil
            if total_rows>0
                total_pages = (total_rows.to_f/page_size.to_f).ceil
                # if there is a GET parameters `number` on the URL, update the user preference regarding the page number on this screen
                # then, get user preferences regarding the page number on this screen
                # pagination correction to prevent glitches
                page_number = 1 if page_number < 1
                page_number = total_pages if page_number > total_pages
                # calculate info for showing at the bottom of the table
                from_row = (page_number.to_i-1) * page_size.to_i + 1
                to_row = [page_number*page_size, total_rows].min
            else
                total_pages = 1
                page_number = 1
                from_row = 0
                to_row = 0
            end
#binding.pry
            a = DB["#{a.sql}\nORDER BY #{sort_column} ASC"] if sort_column && sort_order == :asc
            a = DB["#{a.sql}\nORDER BY #{sort_column} DESC"] if sort_column && sort_order == :desc

            a = a.limit(page_size, (page_number.to_i - 1) * page_size.to_i)
            all = a.all
            raise "Error: the query did not the :id field required by TableHelper." if all[0] && all[0][:id].nil?
            ids = all.map { |row| row[:id] }
            objects = cls.where(:id=>ids).all

            # sort the objects in the same order as the ids
            objects = ids.map { |id| objects.find { |o| o.id == id } }

            #
            h = {
                :from_row => from_row,
                :to_row => to_row,
                :total_rows => total_rows,
                :total_pages => total_pages,
                :p => page_number,
                :objects => objects
            }

            #
            return h
        end
    
    end # module TableHelper
end # module BlackStack