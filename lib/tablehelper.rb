module BlackStack
    module TableHelper

        # This method resolves the pagination problem.
        #
        # Parameters:
        # - a: It is a Sequel dataset like `DB["SELECT name FROM users"]`
        # - p: Is the page number.
        # - z: Is the page size.
        # - cls: Is the class of the objects that will be returned.
        #
        # Return a hash with the following keys:
        # - from_row: The first row of the dataset.
        # - to_row: The last row of the dataset.
        # - t: The total number of pages in the dataset.
        # - p: The real page number you receive, in case the requested p is out of scope.
        # 
        def self.page(a:, p:, z:, cls:)
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

            a = a.limit(page_size, (page_number.to_i - 1) * page_size.to_i)
            ids = a.all.map { |row| row[:id] }
            objects = cls.where(:id=>ids).all

            #
            h = {
                :from_row => from_row,
                :to_row => to_row,
                :t => total_pages,
                :p => page_number,
                :objects => objects

            }

            #
            return h
        end
    
    end # module TableHelper
end # module BlackStack