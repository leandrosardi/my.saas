module BlackStack
  module Renderer
    @@scripts = []
    @@pages = []

    class NavBar
      # TODO: Code Me!
    end # NavBar

    class NavBarButton
      # TODO: Code Me!
    end # NavBarButton

    class NavBarFilter
      # TODO: Code Me!
    end # NavBarFilter

    class Table
      # TODO: Code Me!
    end # Table

    class Page
      attr_accessor :path, :title, :navbar, :tables

      def self.validate_descriptor(h)
        err = []
        # validation: path is mandatory
        err << 'path is mandatory' if h[:path].nil?
        # validation: path must be a string
        err << 'path must be a string' unless h[:path].is_a?(String)
        # validation: path must be a valid route
        #err << 'path must be a valid route' unless h[:path].match(/^[a-zA-Z0-9_\-\/]+$/)
        # validation: path must be unique
        err << 'path must be unique' unless BlackStack::Renderer.pages.select { |p| h[:path] == p.path  }.first.nil?
        # validation: title is mandatory
        err << 'title is mandatory' if h[:title].nil?
        # validation: title must be a string
        err << 'title must be a string' unless h[:title].is_a?(String)
        # TODO: write all the other validations
        # return
        err
      end

      def initialize(h)
        err = BlackStack::Renderer::Page.validate_descriptor(h)
        # raise error if any
        raise err.join(', ') unless err.empty?
        # set attributes
        @path = h[:path]
        @title = h[:title]
        # TODO: Map the rest of the attributes
        #@navbar = h[:navbar]
        #@tables = h[:tables]
      end

      def to_hash
        # TODO: Code Me!
      end

      def content
        "<h1>#{self.title}</h1>"
      end # def content

    end # class Page

    def self.pages
      @@pages
    end

    def self.add_page(h)
      @@pages << BlackStack::Renderer::Page.new(h)
    end

    def self.get_page(path)
      @@pages.each do |page|
        return page if page.path == path
      end
      return nil
    end

    # get the HTML of a page
    def self.render(path)
      # remove all pages
      @@pages = []
      # load file to variable
      script = File.open('/home/leandro/code/mysaas/screens.rb').read
      # evaluate script
      eval(script)
      # get page
      page = get_page(path)
      return 'unknown path' if page.nil?

      # render page
      page.content
    end

    # create the entry point in the webserver
    def self.define_routes()
      # TODO: Code Me!
    end

  end # Renderer
end # BlackStack
  