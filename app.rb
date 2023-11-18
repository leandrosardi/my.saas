begin
  print 'Loading libraries... '
  require 'sinatra'
  require 'app/mysaas'
  require 'app/lib/stubs'
  puts 'done'.green

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
      :default => 'app/config',
    }]
  )
  puts 'done'.green

  #
  print 'Loading configuration... '
  require parser.value('config')
  puts 'done'.green

  print 'Loading version information... '
  require 'app/version'
  puts 'done'.green

  print 'Connecting database... '
  DB = BlackStack::CRDB::connect
  puts 'done'.green

  print 'Loading models... '
  require 'app/lib/skeletons'
  puts 'done'.green

  print 'Loading helpers... '
  # helper to redirect with the params
  # TODO: move this to a helper
  def redirect2(url, params)
    redirect url + '?' + params.reject { |key, value| key=='agent' }.map{|key, value| "#{key}=#{value}"}.join("&")
  end

  def nav1(name1, beta=false)
    login = BlackStack::MySaaS::Login.where(:id=>session['login.id']).first
    user = BlackStack::MySaaS::User.where(:id=>login.id_user).first  

    ret = 
    "<p>" + 
    "<a class='simple' href='/dashboard'><b>#{CGI.escapeHTML(user.account.name.encode_html)}</b></a>" + 
    " <i class='icon-chevron-right'></i> " + 
    CGI.escapeHTML(name1)

    ret += "  <span class='badge badge-mini badge-important'>beta</span>" if beta
    
    ret += "</p>"
  end

  def nav2(name1, url1, name2)
    login = BlackStack::MySaaS::Login.where(:id=>session['login.id']).first
    user = BlackStack::MySaaS::User.where(:id=>login.id_user).first  

    "<p>" + 
    "<a class='simple' href='/dashboard'><b>#{user.account.name.encode_html}</b></a>" + 
    " <i class='icon-chevron-right'></i> " + 
    "<a class='simple' href='#{url1}'>#{CGI.escapeHTML(name1)}</a>" + 
    " <i class='icon-chevron-right'></i> " + 
    CGI.escapeHTML(name2) +
    "</p>"
  end

  def nav3(name1, url1, name2, url2, name3)
    login = BlackStack::MySaaS::Login.where(:id=>session['login.id']).first
    user = BlackStack::MySaaS::User.where(:id=>login.id_user).first  
    "<p>" + 
    "<a class='simple' href='/dashboard'><b>#{user.account.name.encode_html}</b></a>" + 
    " <i class='icon-chevron-right'></i> " + 
    "<a class='simple' href='#{url1}'>#{CGI.escapeHTML(name1)}</a>" + 
    " <i class='icon-chevron-right'></i> " + 
    "<a class='simple' href='#{url2}'>#{CGI.escapeHTML(name2)}</a>" + 
    " <i class='icon-chevron-right'></i> " + 
    name3 +
    "</p>"
  end

  def nav4(name1, url1, name2, url2, name3, url3, name4)
    login = BlackStack::MySaaS::Login.where(:id=>session['login.id']).first
    user = BlackStack::MySaaS::User.where(:id=>login.id_user).first  
    "<p>" + 
    "<a class='simple' href='/dashboard'><b>#{user.account.name.encode_html}</b></a>" + 
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
    login = BlackStack::MySaaS::Login.where(:id=>session['login.id']).first
    user = BlackStack::MySaaS::User.where(:id=>login.id_user).first  
    "<p>" + 
    "<a class='simple' href='/dashboard'><b>#{user.account.name.encode_html}</b></a>" + 
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
    login = BlackStack::MySaaS::Login.where(:id=>session['login.id']).first
    user = BlackStack::MySaaS::User.where(:id=>login.id_user).first  
    "<p>" + 
    "<a class='simple' href='/dashboard'><b>#{user.account.name.encode_html}</b></a>" + 
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

  # enable this line if you want to work with the live version of blackstack-core.
  #require_relative '../blackstack-core/lib/blackstack-core' 

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
    require "app/extensions/#{e.name.downcase}/main"
  }
  puts 'done'.green

  print 'Loading extensions models... '
  # Load skeleton classes
  BlackStack::Extensions.extensions.each { |e|
    require "app/extensions/#{e.name.downcase}/lib/skeletons"
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

  # condition: if there is not authenticated user on the platform, then redirect to the signup page 
  set(:auth) do |*roles|
    condition do
      if !logged_in?
        # remember the internal page I have to return to after login or signup
        session['redirect_on_success'] = "#{request.path_info.to_s}?#{request.query_string.to_s}"
        redirect "/login"
      elsif unavailable?
        redirect "/unavailable"      
      else
        @login = BlackStack::MySaaS::Login.where(:id=>session['login.id']).first
        @service = @login.user.preference('service', '', params[:service])
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
  # External pages: pages that don't require login

  print 'Setting up entries of external pages... '
  # TODO: here where you have to develop notrial? feature
  get '/', :agent => /(.*)/ do
    # decide to which landing redirect, based on the extensions and configuration
    # reference: https://github.com/leandrosardi/i2p/issues/3
    #redirect '/landing'
    redirect '/free'
  end

  get '/404', :agent => /(.*)/ do
    erb :'views/404', :layout => :'/views/layouts/public'
  end

  get '/500', :agent => /(.*)/ do
    erb :'views/500', :layout => :'/views/layouts/public'
  end

  get '/login', :agent => /(.*)/ do
    # TODO: decide to which landing redirect, based on the extensions and configuration
    # reference: https://github.com/leandrosardi/i2p/issues/3
    erb :'views/login', :layout => :'/views/layouts/public'
  end
  post '/login' do
    erb :'views/filter_login'
  end
  get '/filter_login' do
    erb :'views/filter_login'
  end

  get '/signup', :agent => /(.*)/ do
    # TODO: decide to which landing redirect, based on the extensions and configuration
    # reference: https://github.com/leandrosardi/i2p/issues/3
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

  get '/recover', :agent => /(.*)/ do
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

  get '/unavailable' do
    erb :'views/unavailable', :layout => :'/views/layouts/public'
  end

  # --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # Funnel
  # 
  get '/' do
    erb :'views/free', :layout => :'/views/layouts/public'
  end

  get '/free' do
    erb :'views/free', :layout => :'/views/layouts/public'
  end

  get '/wizard', :auth => true do
    erb :'views/step1', :layout => :'/views/layouts/public'
  end

  get '/wizard/', :auth => true do
    erb :'views/step1', :layout => :'/views/layouts/public'
  end

  get '/step1', :auth => true do # job positions
    erb :'views/step1', :layout => :'/views/layouts/public'
  end

  get '/step2', :auth => true do # headcount
    erb :'views/step2', :layout => :'/views/layouts/public'
  end

  get '/step3', :auth => true do # industry
    erb :'views/step3', :layout => :'/views/layouts/public'
  end

  get '/filter_step1', :auth => true, :agent => /(.*)/ do
    erb :'views/filter_step1'
  end
  post '/filter_step1', :auth => true, :agent => /(.*)/ do
    erb :'views/filter_step1'
  end

  get '/filter_step2', :auth => true, :agent => /(.*)/ do
    erb :'views/filter_step2'
  end
  post '/filter_step2', :auth => true, :agent => /(.*)/ do
    erb :'views/filter_step2'
  end

  get '/filter_step3', :auth => true, :agent => /(.*)/ do
    erb :'views/filter_step3'
  end
  post '/filter_step3', :auth => true, :agent => /(.*)/ do
    erb :'views/filter_step3'
  end

  get '/offer', :auth => true, :agent => /(.*)/ do
    erb :'views/offer', :layout => :'/views/layouts/public'
  end

  get '/plans', :auth => true, :agent => /(.*)/ do
    erb :'views/plans', :layout => :'/views/layouts/public'
  end
  puts 'done'.green

  # --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # Configuration screens
  print 'Setting up entries of settings... '

  # main configuration screen
  get '/settings', :auth => true do
    redirect '/settings/dashboard'
  end
  get '/settings/', :auth => true do
    redirect '/settings/dashboard'
  end
  get '/settings/dashboard', :auth => true, :agent => /(.*)/ do
    erb :'views/settings/dashboard', :layout => :'/views/layouts/core'
  end

  # account information
  get '/settings/account', :auth => true, :agent => /(.*)/ do
    erb :'views/settings/account', :layout => :'/views/layouts/core'
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
    erb :'views/settings/whitelabel', :layout => :'/views/layouts/core'
  end
  post '/settings/filter_whitelabel', :auth => true do
    erb :'views/settings/filter_whitelabel'
  end
=end
  # change password
  get '/settings/password', :auth => true, :agent => /(.*)/ do
    erb :'views/settings/password', :layout => :'/views/layouts/core'
  end
  post '/settings/filter_password', :auth => true do
    erb :'views/settings/filter_password'
  end

  # change password
  get '/settings/apikey', :auth => true, :agent => /(.*)/ do
    erb :'views/settings/apikey', :layout => :'/views/layouts/core'
  end
  post '/settings/filter_apikey', :auth => true do
    erb :'views/settings/filter_apikey'
  end

  ## users management screen
  get '/settings/users', :auth => true, :agent => /(.*)/ do
    erb :'views/settings/users', :layout => :'/views/layouts/core'
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
  # User dashboard
  print 'Setting up entries of internal pages... '

  get '/dashboard', :auth => true, :agent => /(.*)/ do
    erb :'views/dashboard', :layout => :'/views/layouts/core'
  end

  # leads/results
  get '/leads', :auth => true, :agent => /(.*)/ do
    erb :'views/leads/results', :layout => :'/views/layouts/core'
  end

  get '/leads/results/:sid', :auth => true, :agent => /(.*)/ do
    erb :'views/leads/results', :layout => :'/views/layouts/core'
  end

  post '/leads/filter_results', :auth => true, :agent => /(.*)/ do
    erb :'views/leads/filter_results'
  end

=begin
  get '/leads/filter_delete', :auth => true, :agent => /(.*)/ do
    erb :'views/leads/filter_delete'
  end
=end

  # leads/results ajax
  get "/ajax/leads/get_lists_linked_to_lead.json", :auth => true do
    erb :"views/ajax/leads/get_lists_linked_to_lead"
  end
  post "/ajax/leads/get_lists_linked_to_lead.json", :auth => true do
    erb :"views/ajax/leads/get_lists_linked_to_lead"
  end

  post "/ajax/leads/create_export_list_and_add_lead.json", :auth => true do
    erb :"views/ajax/leads/create_export_list_and_add_lead"
  end

  get "/ajax/leads/add_lead_to_export_list.json", :auth => true do
    erb :"views/ajax/leads/add_lead_to_export_list"
  end
  post "/ajax/leads/add_lead_to_export_list.json", :auth => true do
    erb :"views/ajax/leads/add_lead_to_export_list"
  end

  get "/ajax/leads/add_lead_to_export_list.json", :auth => true do
    erb :"views/ajax/leads/add_lead_to_export_list"
  end
  post "/ajax/leads/remove_lead_from_export_list.json", :auth => true do
    erb :"views/ajax/leads/remove_lead_from_export_list"
  end

  get "/ajax/leads/get_lead_data.json", :auth => true do
    erb :"views/ajax/leads/get_lead_data"
  end
  post "/ajax/leads/get_lead_data.json", :auth => true do
    erb :"views/ajax/leads/get_lead_data"
  end

  get "/ajax/leads/get_lead_reminders.json", :auth => true do
    erb :"views/ajax/leads/get_lead_reminders"
  end
  post "/ajax/leads/get_lead_reminders.json", :auth => true do
    erb :"views/ajax/leads/get_lead_reminders"
  end

  get "/ajax/leads/add_data.json", :auth => true do
    erb :"views/ajax/leads/add_data"
  end
  post "/ajax/leads/add_data.json", :auth => true do
    erb :"views/ajax/leads/add_data"
  end

  get "/ajax/leads/remove_data.json", :auth => true do
    erb :"views/ajax/leads/remove_data"
  end
  post "/ajax/leads/remove_data.json", :auth => true do
    erb :"views/ajax/leads/remove_data"
  end

  get "/ajax/leads/add_reminder.json", :auth => true do
    erb :"views/ajax/leads/add_reminder"
  end
  post "/ajax/leads/add_reminder.json", :auth => true do
    erb :"views/ajax/leads/add_reminder"
  end

  get "/ajax/leads/remove_reminder.json", :auth => true do
    erb :"views/ajax/leads/remove_reminder"
  end
  post "/ajax/leads/remove_reminder.json", :auth => true do
    erb :"views/ajax/leads/remove_reminder"
  end

  get "/ajax/leads/mark_reminder_as_done.json", :auth => true do
    erb :"views/ajax/leads/mark_reminder_as_done"
  end
  post "/ajax/leads/mark_reminder_as_done.json", :auth => true do
    erb :"views/ajax/leads/mark_reminder_as_done"
  end

  get "/ajax/leads/mark_reminder_as_pending.json", :auth => true do
    erb :"views/ajax/leads/mark_reminder_as_pending"
  end
  post "/ajax/leads/mark_reminder_as_pending.json", :auth => true do
    erb :"views/ajax/leads/mark_reminder_as_pending"
  end

  # leads/new
  get '/leads/new', :auth => true, :agent => /(.*)/ do
    erb :'views/leads/new', :layout => :'/views/layouts/core'
  end

  post '/leads/filter_new', :auth => true, :agent => /(.*)/ do
    erb :'views/leads/filter_new'
  end

  # leads/upload
  get '/leads/uploads', :auth => true, :agent => /(.*)/ do
    erb :'views/leads/uploads/jobs', :layout => :'/views/layouts/core'
  end

  get '/leads/uploads/new', :auth => true, :agent => /(.*)/ do
    erb :'views/leads/uploads/new', :layout => :'/views/layouts/core'
  end

  post '/leads/uploads/mapping', :auth => true, :agent => /(.*)/ do
    erb :'views/leads/uploads/mapping', :layout => :'/views/layouts/core'
  end

  post '/leads/uploads/filter_new_upload_job', :auth => true, :agent => /(.*)/ do
    erb :'views/leads/uploads/filter_new_upload_job'
  end

  # leads/exports
  get '/leads/exports', :auth => true, :agent => /(.*)/ do
    erb :'views/leads/exports', :layout => :'/views/layouts/core'
  end

  get '/leads/filter_view_export_results', :auth => true, :agent => /(.*)/ do
    erb :'views/leads/filter_view_export_results'
  end

  post '/leads/filter_export_contacts', :auth => true, :agent => /(.*)/ do
    erb :'views/leads/filter_export_contacts'
  end

  # leads/searches
  get '/leads/searches', :auth => true, :agent => /(.*)/ do
    erb :'views/leads/searches', :layout => :'/views/layouts/core'
  end

  post '/leads/filter_save_search', :auth => true, :agent => /(.*)/ do
    erb :'views/leads/filter_save_search'
  end

  # emails/addresses
  get "/emails/addresses", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/addresses", :layout => :"/views/layouts/core"
  end

  get "/emails/addresses/new", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/new_address", :layout => :"/views/layouts/core"
  end

  get "/emails/addresses/new/gmail", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/new_gmail_address", :layout => :"/views/layouts/core"
  end

  get "/emails/addresses/new/custom", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/new_custom_address", :layout => :"/views/layouts/core"
  end

  get "/emails/addresses/:aid/edit", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/edit_address", :layout => :"/views/layouts/core"
  end
=begin
  get "/emails/addresses/uploads/new", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/new_upload_addresses", :layout => :"/views/layouts/core"
  end

  post "/emails/addresses/uploads/mapping", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/mapping_upload_addresses", :layout => :"/views/layouts/core"
  end

  post "/emails/filter_new_upload_addresses_job", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/filter_new_upload_addresses_job"
  end

  get "/emails/addresses/uploads", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/upload_addresses_jobs", :layout => :"/views/layouts/core"
  end

  get "/emails/addresses/uploads/:id", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/upload_addresses_job", :layout => :"/views/layouts/core"
  end
=end
  # internal app screens - campaigns
  get "/emails/campaigns", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/campaigns", :layout => :"/views/layouts/core"
  end

  get "/emails/campaigns/new", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/new_campaign", :layout => :"/views/layouts/core"
  end

  get "/emails/campaigns/:gid/edit", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/edit_campaign", :layout => :"/views/layouts/core"
  end

  get "/emails/campaigns/:gid/report/:report", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/report", :layout => :"/views/layouts/core"
  end

  # schedules
  get "/emails/campaigns/:gid/schedules", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/schedules", :layout => :"/views/layouts/core"
  end
  get "/emails/campaigns/:gid/schedules/new", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/new_schedule", :layout => :"/views/layouts/core"
  end
  post "/emails/filter_new_schedule", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/filter_new_schedule"
  end
  get "/emails/filter_delete_schedule", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/filter_delete_schedule"
  end

  # followups
  get "/emails/campaigns/:gid/followups", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/followups", :layout => :"/views/layouts/core"
  end

  get "/emails/campaigns/:gid/followups/new", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/new_followup", :layout => :"/views/layouts/core"
  end

  get "/emails/campaigns/:gid/followups/:fid/edit", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/edit_followup", :layout => :"/views/layouts/core"
  end

  get "/emails/campaigns/:gid/followups/:fid/report/:report", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/report", :layout => :"/views/layouts/core"
  end

  post "/emails/filter_new_followup", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/filter_new_followup"
  end
  get "/emails/filter_delete_followup", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/filter_delete_followup"
  end
  post "/emails/filter_edit_followup", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/filter_edit_followup"
  end

  # activities
  get "/emails/activity", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/report", :layout => :"/views/layouts/core"
  end

  get "/emails/activity/", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/report", :layout => :"/views/layouts/core"
  end

  get "/emails/activity/:report", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/report", :layout => :"/views/layouts/core"
  end

  # actions / rules / automations
  get "/emails/actions", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/actions", :layout => :"/views/layouts/core"
  end

  get "/emails/actions/new", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/new_action", :layout => :"/views/layouts/core"
  end

  get "/emails/actions/:aid/edit", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/edit_action", :layout => :"/views/layouts/core"
  end

  get "/emails/actions/:aid/view", :auth => true, :agent => /(.*)/ do # log
    erb :"views/emails/view_action", :layout => :"/views/layouts/core"
  end

  post "/emails/filter_new_action", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/filter_new_action"
  end
  get "/emails/filter_delete_action", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/filter_delete_action"
  end
  get "/emails/filter_play_action", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/filter_play_action"
  end
  get "/emails/filter_pause_action", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/filter_pause_action"
  end
  post "/emails/filter_edit_action", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/filter_edit_action"
  end

  # filters
  post "/emails/filter_new_campaign", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/filter_new_campaign"
  end

  post "/emails/filter_edit_campaign", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/filter_edit_campaign"
  end

  get "/emails/filter_delete_campaign", :auth => true, :agent => /(.*)/ do
    erb :"views/emails/filter_delete_campaign"
  end

  post "/emails/filter_test_followup", :auth => true do
    erb :"views/emails/filter_test_followup"
  end
  get "/emails/filter_test_followup", :auth => true do
    erb :"views/emails/filter_test_followup"
  end

  post "/emails/filter_play_followup", :auth => true do
    erb :"views/emails/filter_play_followup"
  end
  get "/emails/filter_play_followup", :auth => true do
    erb :"views/emails/filter_play_followup"
  end

  post "/emails/filter_pause_followup", :auth => true do
    erb :"views/emails/filter_pause_followup"
  end
  get "/emails/filter_pause_followup", :auth => true do
    erb :"views/emails/filter_pause_followup"
  end

  post "/emails/filter_new_address", :auth => true do
    erb :"views/emails/filter_new_address"
  end

  post "/emails/filter_edit_address", :auth => true do
    erb :"views/emails/filter_edit_address"
  end
  get "/emails/filter_edit_address", :auth => true do
    erb :"views/emails/filter_edit_address"
  end

  post "/emails/filter_edit_addresses", :auth => true do
    erb :"views/emails/filter_edit_addresses"
  end
  get "/emails/filter_edit_addresses", :auth => true do
    erb :"views/emails/filter_edit_addresses"
  end

  get "/emails/filter_delete_address", :auth => true do
    erb :"views/emails/filter_delete_address"
  end

  # AJAX 
  post "/ajax/emails/upload_picture.json", :auth => true do
    erb :"views/ajax/emails/upload_picture"
  end

  post "/ajax/emails/load_deliveries.json", :auth => true do
    erb :"views/ajax/emails/load_deliveries"
  end

  post "/ajax/emails/unsubscribe.json", :auth => true do
    erb :"views/ajax/emails/unsubscribe"
  end

  post "/ajax/emails/resubscribe.json", :auth => true do
    erb :"views/ajax/emails/resubscribe"
  end

  post "/ajax/emails/mark_positive.json", :auth => true do
    erb :"views/ajax/emails/mark_positive"
  end

  post "/ajax/emails/unmark_positive.json", :auth => true do
    erb :"views/ajax/emails/unmark_positive"
  end

  post "/ajax/emails/create_delivery.json", :auth => true do
    erb :"views/ajax/emails/create_delivery"
  end

  # API
  get "/api1.0/emails/open.json" do
    erb :"views/api1.0/emails/open"
  end

  get "/api1.0/emails/click.json" do
    erb :"views/api1.0/emails/click"
  end

  get "/api1.0/emails/unsubscribe.json" do
    erb :"views/api1.0/emails/unsubscribe"
  end

  puts 'done'.green


  # --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # Require the app.rb file of each one of the extensions.
  # reference: https://github.com/leandrosardi/mysaas/issues/33
  print 'Setting up extensions entries... '
  BlackStack::Extensions.extensions.each { |e|
    require "app/extensions/#{e.name.downcase}/app.rb"
  }
  puts 'done'.green
  
  # --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  # adding storage sub-folders
  # DEPRECATED
  #BlackStack::Extensions.add_storage_subfolders

rescue => e
  puts e.to_console.red
  exit(1)
end