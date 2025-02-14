begin
  print 'Loading libraries... '
  require 'colorize'
  require 'sinatra'
  require 'mysaas'
  require 'lib/stubs'
  puts 'done'.green

  # --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # Parsing command line parameters.
  #
  print 'Parsing command line parameters... '
  parser = BlackStack::SimpleCommandLineParser.new(
    :description => 'This command will launch a Sinatra-based BlackStack webserver.',
    :configuration => [{
      :name=>'port',
      :mandatory=>false,
      :description=>'Listening port.',
      :type=>BlackStack::SimpleCommandLineParser::INT,
      :default => 3000,
    }, {
      :name=>'config',
      :mandatory=>false,
      :description=>'Name of the configuration file.',
      :type=>BlackStack::SimpleCommandLineParser::STRING,
      :default => 'config',
    }]
  )
  puts 'done'.green

  #
  print 'Loading configuration... '
  require parser.value('config')
  puts 'done'.green

  print 'Loading version information... '
  require 'version'
  puts 'done'.green

  print 'Connecting database... '
  DB = BlackStack.db_connect
  puts 'done'.green

  print 'Loading models... '
  require 'lib/skeletons'
  puts 'done'.green

  print 'Loading helpers... '
  # helper to redirect with the params
  # TODO: move this to a helper
  def redirect2(url, params)
    redirect url + '?' + params.reject { |key, value| key=='agent' }.map{|key, value| "#{key}=#{value}"}.join("&")
  end

  def nav1(name1, beta=false)
    login = BlackStack::MySaaS::Login.where(:id=>session["login.id"]).first
    user = BlackStack::MySaaS::User.where(:id=>login.id_user).first

    ret =
    "<p>" +
    "<a class='simple' href='/'><b>#{CGI.escapeHTML(user.account.name.encode_html)}</b></a>" +
    " <i class='icon-chevron-right'></i> " +
    CGI.escapeHTML(name1)

    ret += "  <span class='badge badge-mini badge-important'>beta</span>" if beta

    ret += "</p>"
  end

  def nav2(name1, url1, name2)
    login = BlackStack::MySaaS::Login.where(:id=>session["login.id"]).first
    user = BlackStack::MySaaS::User.where(:id=>login.id_user).first

    "<p>" +
    "<a class='simple' href='/'><b>#{user.account.name.encode_html}</b></a>" +
    " <i class='icon-chevron-right'></i> " +
    "<a class='simple' href='#{url1}'>#{CGI.escapeHTML(name1)}</a>" +
    " <i class='icon-chevron-right'></i> " +
    CGI.escapeHTML(name2) +
    "</p>"
  end

  def nav3(name1, url1, name2, url2, name3)
    login = BlackStack::MySaaS::Login.where(:id=>session["login.id"]).first
    user = BlackStack::MySaaS::User.where(:id=>login.id_user).first
    "<p>" +
    "<a class='simple' href='/'><b>#{user.account.name.encode_html}</b></a>" +
    " <i class='icon-chevron-right'></i> " +
    "<a class='simple' href='#{url1}'>#{CGI.escapeHTML(name1)}</a>" +
    " <i class='icon-chevron-right'></i> " +
    "<a class='simple' href='#{url2}'>#{CGI.escapeHTML(name2)}</a>" +
    " <i class='icon-chevron-right'></i> " +
    name3 +
    "</p>"
  end

  def nav4(name1, url1, name2, url2, name3, url3, name4)
    login = BlackStack::MySaaS::Login.where(:id=>session["login.id"]).first
    user = BlackStack::MySaaS::User.where(:id=>login.id_user).first
    "<p>" +
    "<a class='simple' href='/'><b>#{user.account.name.encode_html}</b></a>" +
    " <i class='icon-chevron-right'></i> " +
    "<a class='simple' href='#{url1}'>#{CGI.escapeHTML(name1)}</a>" +
    " <i class='icon-chevron-right'></i> " +
    "<a class='simple' href='#{url2}'>#{CGI.escapeHTML(name2)}</a>" +
    " <i class='icon-chevron-right'></i> " +
    "<a class='simple' href='#{url3}'>#{CGI.escapeHTML(name3)}</a>" +
    " <i class='icon-chevron-right'></i> " +
    name4 +
    "</p>"
  end

  def nav5(name1, url1, name2, url2, name3, url3, name4, url4, name5)
    login = BlackStack::MySaaS::Login.where(:id=>session["login.id"]).first
    user = BlackStack::MySaaS::User.where(:id=>login.id_user).first
    "<p>" +
    "<a class='simple' href='/'><b>#{user.account.name.encode_html}</b></a>" +
    " <i class='icon-chevron-right'></i> " +
    "<a class='simple' href='#{url1}'>#{CGI.escapeHTML(name1)}</a>" +
    " <i class='icon-chevron-right'></i> " +
    "<a class='simple' href='#{url2}'>#{CGI.escapeHTML(name2)}</a>" +
    " <i class='icon-chevron-right'></i> " +
    "<a class='simple' href='#{url3}'>#{CGI.escapeHTML(name3)}</a>" +
    " <i class='icon-chevron-right'></i> " +
    "<a class='simple' href='#{url4}'>#{CGI.escapeHTML(name4)}</a>" +
    " <i class='icon-chevron-right'></i> " +
    name5 +
    "</p>"
  end

  def nav6(name1, url1, name2, url2, name3, url3, name4, url4, name5, url5, name6)
    login = BlackStack::MySaaS::Login.where(:id=>session["login.id"]).first
    user = BlackStack::MySaaS::User.where(:id=>login.id_user).first
    "<p>" +
    "<a class='simple' href='/'><b>#{user.account.name.encode_html}</b></a>" +
    " <i class='icon-chevron-right'></i> " +
    "<a class='simple' href='#{url1}'>#{CGI.escapeHTML(name1)}</a>" +
    " <i class='icon-chevron-right'></i> " +
    "<a class='simple' href='#{url2}'>#{CGI.escapeHTML(name2)}</a>" +
    " <i class='icon-chevron-right'></i> " +
    "<a class='simple' href='#{url3}'>#{CGI.escapeHTML(name3)}</a>" +
    " <i class='icon-chevron-right'></i> " +
    "<a class='simple' href='#{url4}'>#{CGI.escapeHTML(name4)}</a>" +
    " <i class='icon-chevron-right'></i> " +
    "<a class='simple' href='#{url5}'>#{CGI.escapeHTML(name5)}</a>" +
    " <i class='icon-chevron-right'></i> " +
    name6 +
    "</p>"
  end
  puts 'done'.green

  # --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # Buffering some tables required in some screens.
  #
  print 'Buffering timezone table... '
  TIMEZONES = BlackStack::MySaaS::Timezone.order(:offset, :short_description).all
  puts 'done'.green + " (#{TIMEZONES.size.to_s.blue} records)"

  print 'Buffering country table... '
  COUNTRIES = BlackStack::MySaaS::Country.order(:name).all
  puts 'done'.green + " (#{COUNTRIES.size.to_s.blue} records)"

  # --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # Run webserver.
  #
  puts '

  /\ "-./  \   /\ \_\ \   /\  ___\   /\  __ \   /\  __ \   /\  ___\
  \ \ \-./\ \  \ \____ \  \ \___  \  \ \  __ \  \ \  __ \  \ \___  \
   \ \_\ \ \_\  \/\_____\  \/\_____\  \ \_\ \_\  \ \_\ \_\  \/\_____\
    \/_/  \/_/   \/_____/   \/_____/   \/_/\/_/   \/_/\/_/   \/_____/

  Welcome to MySaaS '+MYSAAS_VERSION.green+'.

  ---> '+'https://github.com/leandrosardi/my.saas'.blue+' <---

  Sandbox Environment: '+(BlackStack.sandbox? ? 'yes'.green : 'no'.red)+'.

  '

  #print "Saving PID... "
  #File.open('./app.pid', 'w') { |f| f.write(Process.pid) }
  #puts "done."

  print 'Loading extensions configuration... '
  # include the libraries of the extensions
  # reference: https://github.com/leandrosardi/mysaas/issues/33
  BlackStack::Extensions.extensions.each { |e|
    require "extensions/#{e.name.downcase}/main"
  }
  puts 'done'.green

  print 'Loading extensions models... '
  # Load skeleton classes
  BlackStack::Extensions.extensions.each { |e|
    require "extensions/#{e.name.downcase}/lib/skeletons"
  }
  puts 'done'.green

  print 'Setting up Sinatra... '
  PORT = parser.value("port")

  configure { set :server, :puma }
  set :bind, '0.0.0.0'
  set :port, PORT
  enable :sessions
  enable :static

  configure do
    enable :cross_origin
  end

  before do
    headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
  end

  set :protection, false

  # Setting the root of views and public folders in the `~/code` folder in order to have access to extensions.
  # reference: https://stackoverflow.com/questions/69028408/change-sinatra-views-directory-location
  set :root,  File.dirname(__FILE__)
  set :views, Proc.new { File.join(root) }

  # Setting the public directory of MySaaS, and the public directories of all the extensions.
  # Public folder is where we store the files who are referenced from HTML (images, CSS, JS, fonts).
  # reference: https://stackoverflow.com/questions/18966318/sinatra-multiple-public-directories
  # reference: https://github.com/leandrosardi/mysaas/issues/33
  use Rack::TryStatic, :root => 'public', :urls => %w[/]
  BlackStack::Extensions.extensions.each { |e|
    use Rack::TryStatic, :root => "extensions/#{e.name.downcase}/public", :urls => %w[/]
  }

  # page not found redirection
  not_found do
    if !logged_in?
      redirect '/'
    else
      redirect '/404'
    end
    #redirect "/404?url=#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}#{CGI::escape(request.path_info)}"
  end

  # unhandled exception redirectiopn
  error do
    max_lenght = 8000
    s = "message=#{CGI.escape(env['sinatra.error'].to_s)}&"
    s += "backtrace_size=#{CGI.escape(env['sinatra.error'].backtrace.size.to_s)}&"
    i = 0
    env['sinatra.error'].backtrace.each { |a|
      a = "backtrace[#{i.to_s}]=#{CGI.escape(a.to_s)}&"
      and_more = "backtrace[#{i.to_s}]=..."
      if (s+a).size > max_lenght - and_more.size
        s += and_more
        break
      else
        s += a
      end
      i += 1
    }
    redirect "/500?#{s}"
  end

  # use this modifier for internal pages, who cannot be shown if there IS NOT a logged-in user
  # condition: if there is not authenticated user on the platform, then redirect to the signup page
  set(:auth) do |*roles|
#binding.pry
    condition do
      if !logged_in?
        # remember the internal page I have to return to after login or signup
        session['redirect_on_success'] = "#{request.path_info.to_s}?#{request.query_string.to_s}"
        redirect "/login"
      elsif unavailable?
        redirect "/unavailable"
      else
        # parameters into a JSON strucutre received by an AJAX end-point
        @body = nil
        begin
          @body = JSON.parse(request.body.read)
        rescue
          # request.body.read has not a valid json syntax
        end
        # get super-user
        @su = BlackStack::MySaaS::Account.where(:api_key=>SU_API_KEY).first
        # rendered to convert markdown to html
        @md = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, fenced_code_blocks: true, highlight: true)
        # current logged-in user
        @login = BlackStack::MySaaS::Login.where(:id=>session["login.id"]).first
        @user = @login.user
        @account = @user.account
        # current service switched into the SaaS
        @service = @login.user.preference('service', SERVICE_NAME.to_s, params[:service])
      end
    end
  end

  # use this modifier for external pages, who cannot be shown if there IS a logged-in user
  # condition: if there is not authenticated user on the platform, then redirect to the / page
  set(:noauth) do |*roles|
#binding.pry
    condition do
      if logged_in?
        redirect "/"
      elsif unavailable?
        redirect "/unavailable"
      end
    end
  end

  # condition: if there is not authenticated user on the platform
  # it must either be a sysadmin or has a subecription (active or not);
  # Otherwise, redirect to /offer
  set(:premium) do |*roles|
    condition do
      if !logged_in?
        redirect "/plans"
      else
        a = BlackStack::I2P::Account.where(:id=>@login.user.id_account).first
        if !a.premium?
          redirect "/plans?err=You+must+have+a+premium+subscription+to+unlock+that+feature."
        end
      end
    end
  end

  # condition: only super-user can access this access point
  # use this condition right after :api_key
  set(:su) do |*roles|
    condition do
      @return_message = {}

      @return_message[:status] = 'success'

      # this is already proccessed in the :api_key condition
      #@body = JSON.parse(request.body.read)

      validation_api_key = @body['api_key'].to_s.to_guid.downcase

      if validation_api_key != SU_API_KEY.to_s.to_guid.downcase
        # libero recursos
        DB.disconnect
        GC.start
        @return_message[:status] = "api_key of the super-user only is allowed for this access point."
        @return_message[:value] = ""
        halt @return_message.to_json
      end
    end
  end

  # condition: api_key parameter is required too for the access points
  set(:api_key) do |*roles|
    condition do
      @return_message = {}

      @return_message[:status] = 'success'

      # validate: the pages using the :api_key condition must work as post only.
      if request.request_method != 'POST'
        @return_message[:status] = 'Pages with an `api_key` parameter are only available for POST requests.'
        @return_message[:value] = ""
        halt @return_message.to_json
      end

      @body = JSON.parse(request.body.read)

      if !@body.has_key?('api_key')
        # libero recursos
        DB.disconnect
        GC.start
        @return_message[:status] = "api_key is required on #{@body.to_s}"
        @return_message[:value] = ""
        halt @return_message.to_json
      end

      if !@body['api_key'].guid?
        # libero recursos
        DB.disconnect
        GC.start

        @return_message[:status] = "Invalid api_key (#{@body['api_key']}))"
        @return_message[:value] = ""
        halt @return_message.to_json
      end

      validation_api_key = @body['api_key'].to_guid.downcase

      @account = BlackStack::MySaaS::Account.where(:api_key => validation_api_key).first
      if @account.nil?
        # libero recursos
        DB.disconnect
        GC.start
        #
        @return_message[:status] = 'Api_key not found'
        @return_message[:value] = ""
        halt @return_message.to_json
      end
    end
  end
  puts 'done'.green

  # --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # Demo Screens

  get "/demo" do
    redirect '/demo/01_layout'
  end
  get "/demo/" do
    redirect '/demo/01_layout'
  end

  get '/demo/01_layout', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/01_layout', :layout => :'/views/layouts/full'
  end
  get '/demo/01a_2pools', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/01a_2pools', :layout => :'/views/layouts/full'
  end
  get '/demo/01b_3pools', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/01b_3pools', :layout => :'/views/layouts/full'
  end

  get '/demo/02_selectorws', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/02_selectrows', :layout => :'/views/layouts/full'
  end

  get '/demo/03_tags', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/03_tags', :layout => :'/views/layouts/full'
  end

  get '/demo/04_profiles', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/04_profiles', :layout => :'/views/layouts/full'
  end

  get '/demo/05_single_editable_fields', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/05_single_editable_fields', :layout => :'/views/layouts/full'
  end

  get '/demo/06_multiple_editable_fields', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/06_multiple_editable_fields', :layout => :'/views/layouts/full'
  end

  get '/demo/07_filters', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/07_filters', :layout => :'/views/layouts/full'
  end

  get '/demo/08_images', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/08_images', :layout => :'/views/layouts/full'
  end

  get '/demo/09_data', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/09_data', :layout => :'/views/layouts/full'
  end

  get '/demo/10_reminders', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/10_reminders', :layout => :'/views/layouts/full'
  end

  get '/demo/11_chat', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/11_chat', :layout => :'/views/layouts/full'
  end

  get '/demo/12_table', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/12_table', :layout => :'/views/layouts/full'
  end

  get '/demo/13_ajax', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/13_ajax', :layout => :'/views/layouts/full'
  end

  get '/demo/14_pagination', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/14_pagination', :layout => :'/views/layouts/full'
  end

  get '/demo/15_waiting', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/15_waiting', :layout => :'/views/layouts/full'
  end

  get '/demo/16_alerts', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/16_alerts', :layout => :'/views/layouts/full'
  end

  get '/demo/17_guid', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/17_guid', :layout => :'/views/layouts/full'
  end

  get '/demo/18_gpt', :auth => true, :agent => /(.*)/ do
    erb :'views/demo/18_gpt', :layout => :'/views/layouts/full'
  end

  # --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # Setup user preferences

  post '/ajax/ping.json', :auth => true, :agent => /(.*)/ do
    erb :'views/ajax/ping'
  end

  post '/ajax/set_preference.json', :auth => true, :agent => /(.*)/ do
    erb :'views/ajax/set_preference'
  end

  post '/ajax/set_many_preference.json', :auth => true, :agent => /(.*)/ do
    erb :'views/ajax/set_many_preference'
  end

  post '/ajax/get_preference.json', :auth => true, :agent => /(.*)/ do
    erb :'views/ajax/get_preference'
  end

  post '/ajax/get_many_preference.json', :auth => true, :agent => /(.*)/ do
    erb :'views/ajax/get_many_preference'
  end

  # --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # Objects management

  post "/ajax/:object/page.json", :auth => true, :agent => /(.*)/ do
    erb :"views/ajax/page"
  end

  post "/ajax/:object/count.json", :auth => true, :agent => /(.*)/ do
    erb :"views/ajax/count"
  end

  post "/ajax/:object/get.json", :auth => true, :agent => /(.*)/ do
    erb :"views/ajax/get"
  end

  post "/ajax/:object/get_many.json", :auth => true, :agent => /(.*)/ do
    erb :"views/ajax/get_many"
  end

  post "/ajax/:object/errors.json", :auth => true, :agent => /(.*)/ do
    erb :"views/ajax/errors"
  end

  post "/ajax/:object/insert.json", :auth => true, :agent => /(.*)/ do
    erb :"views/ajax/insert"
  end

  post "/ajax/:object/update.json", :auth => true, :agent => /(.*)/ do
    erb :"views/ajax/update"
  end

  post "/ajax/:object/delete.json", :auth => true, :agent => /(.*)/ do
    erb :"views/ajax/delete"
  end

  post "/ajax/:object/upsert.json", :auth => true, :agent => /(.*)/ do
    erb :"views/ajax/upsert"
  end

  # --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # External pages: pages that don't require login

  print 'Setting up entries of external pages... '

  get '/', :agent => /(.*)/ do
    if logged_in?
      redirect BlackStack::Funnel.url_root(@login, 'funnels.main')
    else
      redirect BlackStack::Funnel.url_landing(@login, 'funnels.main')
    end
  end

  get '/404', :agent => /(.*)/ do
    erb :'views/404', :layout => :'/views/layouts/public'
  end

  get '/500', :agent => /(.*)/ do
    erb :'views/500', :layout => :'/views/layouts/public'
  end

  get '/unavailable' do
    erb :'views/unavailable', :layout => :'/views/layouts/public'
  end

  get '/login', :noauth => true, :agent => /(.*)/ do
    erb :'views/login', :layout => :'/views/layouts/public'
  end
  post '/login' do
    erb :'views/filter_login'
  end
  get '/filter_login' do
    erb :'views/filter_login'
  end

  get '/signup', :noauth => true, :agent => /(.*)/ do
    erb :'views/signup', :layout => :'/views/layouts/public'
  end
  post '/signup' do
    erb :'views/filter_signup'
  end

  get '/confirm/:nid' do
    erb :'views/filter_confirm'
  end

  get '/logout' do
    erb :'views/filter_logout'
  end

  get '/recover', :noauth => true, :agent => /(.*)/ do
    erb :'views/recover', :layout => :'/views/layouts/public'
  end
  post '/recover' do
    erb :'views/filter_recover'
  end

  get '/reset/:nid', :agent => /(.*)/ do
    erb :'views/reset', :layout => :'/views/layouts/public'
  end
  post '/reset' do
    erb :'views/filter_reset'
  end

  # --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # User welcome
  print 'Setting up entries of internal pages... '

  get '/survey', :auth => true, :agent => /(.*)/ do
    erb :'views/survey', :layout => :'/views/layouts/classic'
  end

  get '/welcome', :auth => true, :agent => /(.*)/ do
    erb :'views/welcome', :layout => :'/views/layouts/classic'
  end

  get '/new', :auth => true, :agent => /(.*)/ do
    erb :'views/search', :layout => :'/views/layouts/classic'
  end

  get '/edit/:sid', :auth => true, :agent => /(.*)/ do
    erb :'views/search', :layout => :'/views/layouts/classic'
  end

  get '/delete/:sid', :auth => true, :agent => /(.*)/ do
    erb :'views/delete'
  end

  post '/filter_edit', :auth => true, :agent => /(.*)/ do
    erb :'views/filter_edit'
  end

  post '/filter_new', :auth => true, :agent => /(.*)/ do
    erb :'views/filter_new'
  end

  get '/filter_copy', :auth => true, :agent => /(.*)/ do
    erb :'views/filter_copy'
  end

  get '/filter_delete', :auth => true, :agent => /(.*)/ do
    erb :'views/filter_delete'
  end

  get '/filter_pause', :auth => true, :agent => /(.*)/ do
    erb :'views/filter_pause'
  end

  get '/filter_play', :auth => true, :agent => /(.*)/ do
    erb :'views/filter_play'
  end

  # --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # Configuration screens

  # main configuration screen
  get '/settings', :auth => true do
    redirect '/settings/dashboard'
  end
  get '/settings/', :auth => true do
    redirect '/settings/dashboard'
  end
  get '/settings/dashboard', :auth => true, :agent => /(.*)/ do
    erb :'views/settings/dashboard', :layout => :'/views/layouts/classic'
  end

  # account information
  get '/settings/account', :auth => true, :agent => /(.*)/ do
    erb :'views/settings/account', :layout => :'/views/layouts/classic'
  end
  post '/settings/filter_account', :auth => true do
    erb :'views/settings/filter_account'
  end
=begin
  #
  # UNDER CONSTRUCTION
  #
  # white label configuration
  get '/settings/whitelabel', :auth => true, :agent => /(.*)/ do
    erb :'views/settings/whitelabel', :layout => :'/views/layouts/classic'
  end
  post '/settings/filter_whitelabel', :auth => true do
    erb :'views/settings/filter_whitelabel'
  end
=end
  # change password
  get '/settings/password', :auth => true, :agent => /(.*)/ do
    erb :'views/settings/password', :layout => :'/views/layouts/classic'
  end
  post '/settings/filter_password', :auth => true do
    erb :'views/settings/filter_password'
  end

  # change password
  get '/settings/apikey', :auth => true, :agent => /(.*)/ do
    erb :'views/settings/apikey', :layout => :'/views/layouts/classic'
  end
  post '/settings/filter_apikey', :auth => true do
    erb :'views/settings/filter_apikey'
  end

  ## users management screen
  get '/settings/users', :auth => true, :agent => /(.*)/ do
    erb :'views/settings/users', :layout => :'/views/layouts/classic'
  end

  get '/settings/filter_users_add', :auth => true do
    erb :'views/settings/filter_users_add'
  end
  post '/settings/filter_users_add', :auth => true do
    erb :'views/settings/filter_users_add'
  end

  get '/settings/filter_users_delete', :auth => true do
    erb :'views/settings/filter_users_delete'
  end
  post '/settings/filter_users_delete', :auth => true do
    erb :'views/settings/filter_users_delete'
  end

  get '/settings/filter_users_update', :auth => true do
    erb :'views/settings/filter_users_update'
  end
  post '/settings/filter_users_update', :auth => true do
    erb :'views/settings/filter_users_update'
  end

  get '/settings/filter_users_send_confirmation_email', :auth => true do
    erb :'views/settings/filter_users_send_confirmation_email'
  end
  post '/settings/filter_users_send_confirmation_email', :auth => true do
    erb :'views/settings/filter_users_send_confirmation_email'
  end

  get '/settings/filter_users_set_account_owner', :auth => true do
    erb :'views/settings/filter_users_set_account_owner'
  end
  post '/settings/filter_users_set_account_owner', :auth => true do
    erb :'views/settings/filter_users_set_account_owner'
  end
  puts 'done'.green

  # --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # API access points
  print 'Setting up entries of API access points... '

  # ping
  get '/api1.0/ping.json', :api_key => true do
    erb :'views/api1.0/ping'
  end
  post '/api1.0/ping.json', :api_key => true do
    erb :'views/api1.0/ping'
  end

  # Standard MySaaS API - URL resolution for subaccounts
  #
  post "/api1.0/resolve/get.json", :api_key => true do
    erb :"views/api1.0/resolve/get"
  end

  # Standard MySaaS API - Managing subaccounts
  #
  post "/api1.0/subaccount/get_subaccount_assigned_to_profile.json", :api_key => true, :su => true do
    erb :"views/api1.0/subaccount/get_subaccount_assigned_to_profile"
  end

  post "/api1.0/subaccount/get.json", :api_key => true, :su => true do
    erb :"views/api1.0/subaccount/get"
  end

  post "/api1.0/subaccount/create.json", :api_key => true, :su => true do
    erb :"views/api1.0/subaccount/create"
  end

  post "/api1.0/subaccount/delete.json", :api_key => true, :su => true do
    erb :"views/api1.0/subaccount/delete"
  end

  # Standard MySaaS API - Getting account attribute
  #
  post '/api1.0/account_value.json', :api_key => true do
    erb :'views/api1.0/account_value'
  end


  # Standard MySaaS API - Managing objects
  #
  post "/api1.0/:object/page.json", :api_key => true do
    erb :"views/api1.0/page"
  end

  post "/api1.0/:object/count.json", :api_key => true do
    erb :"views/api1.0/count"
  end

  post "/api1.0/:object/get.json", :api_key => true do
    erb :"views/api1.0/get"
  end

  post "/api1.0/:object/get_many.json", :api_key => true do
    erb :"views/api1.0/get_many"
  end

  post "/api1.0/:object/errors.json", :api_key => true do
    erb :"views/api1.0/errors"
  end

  post "/api1.0/:object/insert.json", :api_key => true do
    erb :"views/api1.0/insert"
  end

  post "/api1.0/:object/update.json", :api_key => true do
    erb :"views/api1.0/update"
  end

  post "/api1.0/:object/delete.json", :api_key => true do
    erb :"views/api1.0/delete"
  end

  post "/api1.0/:object/update_status.json", :api_key => true do
    erb :"views/api1.0/update_status"
  end

  post "/api1.0/:object/upsert.json", :api_key => true do
    erb :"views/api1.0/upsert"
  end

  # https://github.com/MassProspecting/docs/issues/378
  # 
  post "/api1.0/:object/upsert2.json", :api_key => true do
    erb :"views/api1.0/upsert2"
  end


  # notifications
  get '/api1.0/notifications/open.json' do
    erb :'views/api1.0/notifications/open'
  end
  post '/api1.0/notifications/open.json' do
    erb :'views/api1.0/notifications/open'
  end

  get '/api1.0/notifications/click.json' do
    erb :'views/api1.0/notifications/click'
  end
  post '/api1.0/notifications/click.json' do
    erb :'views/api1.0/notifications/click'
  end

  puts 'done'.green

  # --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # Require the app.rb file of each one of the extensions.
  # reference: https://github.com/leandrosardi/mysaas/issues/33
  print 'Setting up extensions entries... '
  BlackStack::Extensions.extensions.each { |e|
    require "extensions/#{e.name.downcase}/app.rb"
  }
  puts 'done'.green

  # --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # adding storage sub-folders
  # DEPRECATED
  #BlackStack::Extensions.add_storage_subfolders

rescue LoadError => e
  puts "Failed to load required file: #{e.message}"
  # You can add additional error handling here, such as exiting the script
  exit(2)

rescue => e
  puts e.to_s
  exit(1)
end
