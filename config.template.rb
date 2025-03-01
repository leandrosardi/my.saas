﻿A# MySaaS Configuration File.
# Author: Leandro D. Sardi.
# Date: Oct-2022.
#
# Never push the file to the repository.
# Be sure this file is always included in the .gitignore.
#
# To save config.rb and other critical files, use the CLI
# command `backup.rb`. It will create a backup of the current
# files into a cloud storage specified in this file.
#
# Guidelines:
# - Use $HOME instead of ~.
#

# Setup logging options. 
BlackStack::Logger.set(
  min_size: 10*1024*1024, # 10MB
  max_size: 20*1024*1024, # 20MB
  show_nesting_level: false,
  show_nesting_caller: false,
  colorize: true,
  nesting_assertion: true
)

# Where am I running?
hostname = IO.popen(['hostname']).read.strip

# --------------------------------------------------------------
# --------------------------------------------------------------
# CONSTANTS
# --------------------------------------------------------------
# --------------------------------------------------------------

# max size allowed to upload from a form.
MAX_FILE_SIZE = 10 # GBs

=begin
# components to deploy
SLAVE = false
COMPONENTS = {
    :list => [
        {
            :name => 'master',
            :repo => 'leandrosardi/my.saas', 
            :branch => 'main',
            :extensions => [
                { :name => 'mass.commons', :repo => 'massprospecting/mass.commons', :branch => 'main' },
                { :name => 'mass.account', :repo => 'massprospecting/mass.account', :branch => 'main' },
                { :name => 'i2p', :repo => 'leandrosardi/i2p', :branch => 'master' },
                { :name => 'content', :repo => 'leandrosardi/content', :branch => 'main' },
                { :name => 'monitoring', :repo => 'leandrosardi/monitoring', :branch => 'main' },
                #{ :name => 'affiliates', :repo => 'leandrosardi/affiliates', :branch => 'main' },
                { :name => 'dropbox-token-helper', :repo => 'leandrosardi/dropbox-token-helper', :branch => 'main' },
            ]    
        }, {
            :name => 'slave',
            :repo => 'leandrosardi/my.saas', 
            :branch => 'main',
            :extensions => [
                { :name => 'mass.commons', :repo => 'massprospecting/mass.commons', :branch => 'main' },
                { :name => 'mass.subaccount', :repo => 'massprospecting/mass.subaccount', :branch => 'main' },
                { :name => 'selectrowsjs', :repo => 'leandrosardi/selectrowsjs', :branch => 'main' },
                { :name => 'filtersjs', :repo => 'leandrosardi/filtersjs', :branch => 'main' },
            ]    
        }, {
            :name => 'sdk',
            :repo => 'massprospecting/mass-sdk', 
            :branch => 'main',
            :extensions => []
        }        
    ]
}
=end

# run an extension as a service
SERVICE_NAME = nil

# choose a custom image to show when a page is loading, or when an AJAX content is loading
LOADING_IMAGE_PATH = '/core/images/loading.png'

# deployment routines will write in this file, in hard drive of the node where deploying.
OUTPUT_FILE = '$HOME/deployment.log'

# CODE_PATH may be different in production and development environments.
CODE_PATH = '$HOME/code/my.saas'

# Integration with TinyMCE
# - Reference: https://www.tiny.cloud/docs/tinymce/latest/invalid-api-key
#TINYMCE_API_KEY='<place your TinyMCE api key here>'

# Integration with OpenAI
# - Reference: https://platform.openai.com/docs/quickstart
#OPENAI_API_KEY = '<place your OpenAI api key here>'
OPENAI_MODEL = 'gpt-4-1106-preview' #'gpt-3.5-turbo-16k-0613'

# Integration with AdsPower
# - Reference: https://help.adspower.com/docs/api
#ADSPOWER_API_KEY = '<place your AdsPower api key here>'

# Integration: Zyte API key 
# - Reference: https://docs.zyte.com/scrapy-cloud/usage/reference/http/index.html
#ZYTE_API_KEY = '<place your Zyte api key here>'

# my.saas api-key of the su user
# default value is '4db9d88c-dee9-4b5a-8d36-134d38e9f763'.
# it is recommended you change it in production, with the password of the su user too.
#VYMECO_API_KEY = '4db9d88c-dee9-4b5a-8d36-134d38e9f763'

# my.saas api-key of the su user
# default value is '4db9d88c-dee9-4b5a-8d36-134d38e9f763'.
# it is recommended you change it in production, with the password of the su user too.
SU_API_KEY = '4db9d88c-dee9-4b5a-8d36-134d38e9f763' 

# Integration: DropBox Access Token
# - Reference: https://github.com/leandrosardi/my-dropbox-api
#DROPBOX_REFRESH_TOKEN = '<place your DropBox refresh token here>'

# Integration: Apollo
# - Reference: https://knowledge.apollo.io/hc/en-us/articles/4415734629773-Configure-Access-to-the-Apollo-REST-API
#APOLLO_API_KEY = '<place your Apollo api key here>'


BlackStack::Funnel.set({
    # Goolge Analytics
    #
    # Find your Google Analytics UTM tracking 
    # code by following the steps in this tutorial:
    # https://www.monsterinsights.com/docs/where-to-find-utm-tracking-code-results-data-in-google-analytics
    # 
    # Comment the line below if you don't want google analytics.
    #
    :ga => BlackStack.sandbox? ? nil : nil,

    # reCaptcha v2 keys
    # 
    # Create your keys here: https://www.google.com/recaptcha/admin/create
    # Find your analytics here: https://www.google.com/recaptcha/admin
    #
    # Comment the lines below if you don't want reCaptcha v2.
    #  
    :recaptcha2_site_key => nil,
    :recaptcha2_secret_key => nil,
})


# Funnel Configuration
# Build your funnel logic here.
#
BlackStack::Funnel.add({
    :name => 'funnels.main',
    # decide what is the screen to show in the root of the app.
    :url_root => Proc.new do |login, *args|
        '/login'
    end,
    # Decide if go to one-time-offer screen, or 
    # to the plans screen. Return the URL to go.    
    # 
    :url_plans => Proc.new do |login, *args|
        '/plans'
    end,
    # Return the url to go after signup.
    # 
    :url_after_signup => Proc.new do |login, *args|
        BlackStack::Funnel.url_after_login(login, 'funnels.main')
    end,
    # Return the url to go after login.
    # 
    :url_after_login => Proc.new do |login, *args|
        '/welcome'
    end,
    # Return the url to go if the user
    # choose to go for free in the plans
    # screen.
    # 
    :url_to_go_free => Proc.new do |login, *args|
        '/welcome'
    end,
})

# setting up breakpoints for backend processes.
# enabling/disabling the flag  will enable/disable the function 
BlackStack::Debugging::set({
  :allow_breakpoints => BlackStack.sandbox?,
})

# Setup connection to the API, in order get bots requesting and pushing data to the database.
# TODO: write your API-Key here. Refer to this article about how to create your API key:
# https://sites.google.com/expandedventure.com/knowledge/
#
# TODO: Switch back to HTTPS when the emails.leads.uplaod.ingest process is migrated to DropBox for elastic storage.
# 
BlackStack::API::set_client({
  # IMPORTANT: It is strongly recommended that you 
  # use the api_key of an account with prisma role, 
  # and assigned to the central division too.
  :api_key => SU_API_KEY, 
  # IMPORTANT: It is stringly recommended that you 
  # write the URL of the central division here. 
  :api_protocol => 'http',
  # IMPORTANT: Even if you are running process in our LAN, 
  # don't write a LAN IP here, since bots are designed to
  # run anywhere worldwide.
  #
  # IMPORTANT: This is the only web-node where files are 
  # being stored. Never change this IP by the TLD.
  # References: 
  # - https://github.com/leandrosardi/leads/issues/110
  # - https://github.com/leandrosardi/emails/issues/142
  # 
  :api_domain => '127.0.0.1', 
  :api_port => '3000',
})

# IMPORTANT NOTE: This value should have a format like FOO.COM. 
# => Other formats can generate bugs in the piece of codes where 
# => this constant is concatenated. 
APP_DOMAIN = '127.0.0.1' 
APP_NAME = '<your saas name here>'
APP_SHORT_NAME = '<your saas short name here>'

# Email to contact support
HELPDESK_EMAIL = 'support@<your saas domain here>'

# Company Information for invoicing
COMPANY_NAME = '<your company name here>'
COMPANY_TYPE = 'LLC'
COMPANY_ADDRESS = '1287 Bellaustegui Street, Office 3B, Buenos Aires, Argentina'
COMPANY_PHONE = '+54 11 15 5061 2148'
COMPANY_URL = 'https://<your saas domain here>'

# Useful URLs
TERMS_URL = '<URL of service terms here>' # Terms and Conditions URL.
PRIVACY_URL = '<URL of private policy here>' # Privacy Policy URL.
CANCEL_URL = '<URL of cancel policy here>' # Article explaining how to cancel the service.
HELPDESK_URL = '<HelpDesk URL here>' # Helpdesk URL.

# app url
CS_HOME_PAGE_PROTOCOL = 'http'
CS_HOME_PAGE_DOMAIN = '127.0.0.1'
CS_HOME_PAGE_PORT = '3000'
CS_HOME_WEBSITE = CS_HOME_PAGE_PROTOCOL+'://'+CS_HOME_PAGE_DOMAIN+':'+CS_HOME_PAGE_PORT
CS_HOME_LOGO = CS_HOME_WEBSITE + '/core/images/logo.png'
CS_HOME_FAVICON = CS_HOME_WEBSITE + '/core/images/favicon.png'
CS_HOME_TITLE = "My.SaaS - <Your Title Here>"

# default timezone
DEFAULT_TIMEZONE_SHORT_DESCRIPTION='Buenos Aires'

=begin
# parameters to deliver transactional emails
BlackStack::Emails.set(
  # postmark api key
  :postmark_api_key => '1499e037-****-****-****-************',

  # smtp request sender information
  :sender_email => '<your email here>',
  :from_email => '<your email here>', 
  :from_name => '<your name here>',
  
  # smtp request connection information
  :smtp_url => 'smtp.postmarkapp.com',
  :smtp_port => '25',
  :smtp_user => 'e9c83429-****-****-****-************',
  :smtp_password => 'e9c83429-****-****-****-************',

  # default tracking domain
  :tracking_domain_protocol => 'http',
  :tracking_domain_tld => '<your saas domain here>',
  :tracking_domain_port => 3000,
)

# parameters for end user notifications
BlackStack::Notifications.set(  
  :logo_url => CS_HOME_WEBSITE + '/core/images/logo.png',
  :signature_picture_url => CS_HOME_WEBSITE + '/core/images/logo/sheldon.jpg',
  :signature_name => 'Sheldon Cooper',
  :signature_position => 'Founder & CEO',
)

# set api client, in case you run stub instances in the same machine.
#
BlackStack::API.set_client(
    api_key: '4db9d88c-dee9-****-8d36-********',
    api_url: 'http://127.0.0.1',
    api_port: 3000,
    api_version: '1.0',
    backtrace: BlackStack.sandbox?
)
=end

# declare production nodes.
# .BlackStack.sandbox? flag doesn't play here.
# both cs.pem file and config.rb file are always taken from the local dev machine (leandro).
BlackStack::Deployer::add_nodes([
  {
    # unique name to identify a host (a.k.a.: node)
    #
    :name => 'dev2', 

    # ssh connection parameters
    # use either `ssh_password` or `ssh_private_key_file` for identification.
    # 
    :net_remote_ip => '127.0.0.1',  
    :ssh_username => 'blackstack',
    :ssh_port => 22,
    :ssh_password => 'blackstack123',
    #:ssh_private_key_file => BlackStack.sandbox? ? '/home/leandro/code/my.saas/cli/cs.pem' : '$HOME/code/my.saas/cli/cs.pem',

    # database hosted by this node
    :db_type => :pg,
    :db_port => 5432,
    :db_name => 'blackstack',
    :db_user => 'blackstack',
    :db_password => 'blackstack123',

    # database to connect
    :db_host => 'dev2',

    # github credentials
    # 
    # Generate GitHub app password following the instructions here:
    # https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens 
    # 
    :git_repository => 'leandrosardi/my.saas',
    :git_branch => 'dev-1.6.7',
    :git_username => '<your github username here>',
    :git_password => '****',

    # code folder
    # name of the folder where source code is placed
    # 
    :code_folder => 'my.saas',

    # name of the LAN interface
    :laninterface => 'eth0',

    # sinatra
    :web_port => 3000,

    # config.rb content - always using dev-environment here
    #
    # Escape the double-quotes (") to make it embeddeable in the bash script generated by /deployment/default.rb.
    # (`echo "%config_rb_content%"` > ./config.rb)
    #
    # Don't call `File.read("$RUBYLIB/config.rb")` because the `$RUBYLIB` is not managed by the File module.
    # Use the `ENV` array instead.
    #
    # Don't use ``cat $RUBYLIB/config.rb`` because it won't be mapped to production,
    # because my-ruby-deployer will remove any text between ``.
    # 
    # Don't use the `sandbox?` method here, because the commands in the /cli folder must run with no `.sandbox` flag.
    # 
    :config_rb_content => File.read(ENV['RUBYLIB']+'/config.rb').gsub(/"/, '\"'),
    # default deployment routine for this node
    # 
    :deployment_routine => 'default',
    # this is always the folder where the app.rb file is located,
    # and from where you will run all the processes who run in this node.
    # 
    :rubylib => "$HOME/code/my.saas",
    # processes to run on this node
    # all these processes are run in the background
    # all the processes are located into the $RUBYLIB folder
    # all these
    # 
    :processes => [
      # Webserver
      #
      'app.rb port=3000 config=./config.rb',
      
      # Look for new records in the table event. 
      # Apply AI to detect opportunities and craft direct messages. 
      # Insert into outbox.
      # 
      #'p/filter.rb',
      
      # Look for new records in the table outbox. 
      # Look for available profiles. 
      # Update outbox.id_profile.
      # 
      #'p/plan.rb',
    ],
    # logfiles to watch
    # 
    :logfiles => [
      OUTPUT_FILE, # '$HOME/deployment.log',
      #'$RUBYLIB/filter.log',
      #'$RUBYLIB/plan.log',
    ],
  }
])

# DB ACCESS - KEEP IT SECRET
# 
# Connecting to PostgreSQL database in your local machine.
#
# Refere to this tutorial for installing a local environment:
# https://github.com/leandrosardi/environment
# 
node_me = BlackStack::Deployer.nodes.select { |n| n.name==hostname.strip }.first
node_db_host = BlackStack::Deployer.nodes.select { |n| n.name==node_me.parameters[:db_host] }.first
BlackStack::PostgreSQL::set_db_params({
  :db_url => node_db_host.net_remote_ip,
  :db_port => node_db_host.parameters[:db_port],
  :db_name => node_db_host.parameters[:db_name],
  :db_user => node_db_host.parameters[:db_user],
  :db_password => node_db_host.parameters[:db_password],
})
=begin
# For running a CockroachDB instance in your local computer:
# - cockroach start-single-node --insecure
# 
# Either you use a local (demo) database, or a cloud (serverless) database, always find a connection string like this:
# - postgresql://demo:demo7343@127.0.0.1:26257/movr?sslmode=require
# - postgresql://root@dev1:26257/defaultdb?sslmode=disable
# Then, map the parameters of such a connection string here.
# 
BlackStack::CRDB::set_db_params({ 
  :db_url => node_db_host.net_remote_ip,
  :db_cluster => node_db_host.parameters[:db_cluster],
  :db_sslmode => node_db_host.parameters[:db_sslmode],
  :db_port => node_db_host.parameters[:db_port],
  :db_name => node_db_host.parameters[:db_name],
  :db_user => node_db_host.parameters[:db_user],
  :db_password => node_db_host.parameters[:db_password],
})
=end

=begin
# Using Pampa for parallel processing.
# Reference: https://github.com/leandrosardi/pampa

# Setup cluster of nodes (computers) where to launch Pampa worker processes.
# Reference: https://github.com/leandrosardi/pampa?tab=readme-ov-file#3-define-your-cluster
# 
BlackStack::Pampa.add_nodes(
  [
    {
      :name => 'local'
      # setup SSH connection parameters
      :net_remote_ip => '127.0.0.1',  
      :ssh_username => '<your ssh username>', # example: root
      :ssh_port => 22,
      :ssh_password => '<your ssh password>',
      # setup max number of worker processes
      :max_workers => 2,
    },
  ]
)

# Setup the Pampa job.
# Reference: https://github.com/leandrosardi/pampa?tab=readme-ov-file#4-define-a-job
# 
BlackStack::Pampa.add_job({
  :name => 'search_odd_numbers',

  # Minimum number of tasks that a worker must have in queue.
  # Default: 5
  :queue_size => 5, 
  
  # Maximum number of minutes that a task should take to process.
  # If a tasks didn't finish X minutes after it started, it is restarted and assigned to another worker.
  # Default: 15
  :max_job_duration_minutes => 15,  
  
  # Maximum number of times that a task can be restarted.
  # Default: 3
  :max_try_times => 3,

  # Define the tasks table: each record is a task.
  # The tasks table must have some specific fields for handling the tasks dispatching.
  :table => :numbers, # Note, that we are sending a class object here
  :field_primary_key => :value,
  :field_id => :odd_checking_reservation_id,
  :field_time => :odd_checking_reservation_time, 
  :field_times => :odd_checking_reservation_times,
  :field_start_time => :odd_checking_start_time,
  :field_end_time => :odd_checking_end_time,
  :field_success => :odd_checking_success,
  :field_error_description => :odd_checking_error_description,

  # Function to execute for each task.
  :processing_function => Proc.new do |task, l, job, worker, *args|
    l.logs 'Checking if '+task[:value].to_s+' is odd... '
    if task[:value] % 2 == 0
      task[:is_odd] = false
      l.logf 'No.'.red
    else
      task[:is_odd] = true
      l.logf 'Yes.'.green
    end
    DB[:numbers].where(:value=>task[:value]).update(:is_odd=>task[:is_odd])
  end
})
=end

=begin
# Reference: https://github.com/leandrosardi/my-dropbox-api
#
# Dropbox will be deprecated in favor of AWS/S3.
# Reference: https://github.com/MassProspecting/docs/issues/320
#
#
BlackStack::DropBox.set({
  :vymeco_api_key => VYMECO_API_KEY,
  :dropbox_refresh_token => DROPBOX_REFRESH_TOKEN,
})
=end

=begin
# Manage backup of secret files
# Reference: https://github.com/leandrosardi/my.saas/blob/main/docu/03.secret-files-management.md
BlackStack::BackUp.set(
  {
    # leandro@vymeco.com
    :dropbox_refresh_token => DROPBOX_REFRESH_TOKEN,
    # different cloud folders to upload differt local folders 
    :destinations => [{
      # configuration file.
      :name => 'config',
      :folder => 'vymeco.config',
      :path =>  '$RUBYLIB',
      :files => ['config.rb'],
    }, {
      # certification file for connecting serverless CockroackDB.
      :name => 'postgresql',
      :folder => 'vymeco.postgresql',
      :path =>  '$HOME/.postgresql',
      :files => ['root.crt'],
    }, {
      # certificate to connect AWS instances.
      :name => 'aws',
      :folder => 'vymeco.cli.pem',
      :path =>  '$RUBYLIB/cli',
      :files => ['vymeco.pem'],
    }, {
      # database deploying .lock files.
      :name => 'lock',
      :folder => 'vymeco.cli.lock',
      :path =>  '$RUBYLIB/cli',
      :files => [
        'my-ruby-deployer.lock', 
        'my-ruby-deployer.i2p.lock', 
        'my-ruby-deployer.monitoring.lock',
        'my-ruby-deployer.content.lock',
      ],
    }, {
      # Website HTTPS certificaties.
      :name => 'ssl',
      :folder => 'vymeco.ssl',
      :path =>  '$RUBYLIB/ssl',
      :files => ['prod.crt', 'prod.key'],
    }]
  }
)
=end

# add required extensions
#BlackStack::Extensions.append :i2p
#BlackStack::Extensions.append :content, { :show_in_top_bar => false, :show_in_footer => false, :show_in_dashboard => false }
#BlackStack::Extensions.append :monitoring, { :show_in_top_bar => false, :show_in_footer => false, :show_in_dashboard => false }

# developer extensions
#BlackStack::Extensions.append :selectrowsjs, { :show_in_top_bar => false, :show_in_footer => true, :show_in_dashboard => false }
#BlackStack::Extensions.append :filtersjs, { :show_in_top_bar => false, :show_in_footer => true, :show_in_dashboard => false }
#BlackStack::Extensions.append :progressjs, { :show_in_top_bar => false, :show_in_footer => true, :show_in_dashboard => false }
#BlackStack::Extensions.append :templatesjs, { :show_in_top_bar => false, :show_in_footer => true, :show_in_dashboard => false }
#BlackStack::Extensions.append :listsjs, { :show_in_top_bar => false, :show_in_footer => true, :show_in_dashboard => false }
#BlackStack::Extensions.append :datasjs, { :show_in_top_bar => false, :show_in_footer => true, :show_in_dashboard => false }

=begin
#
# I2P Services & Plans
#
# I2P configuration
BlackStack::I2P::set({
  # In PROD environment: use your public domain.
  # IN DEV environment: user your ngrok domain. 
  #
  # ## Setting Up both Facilitator and Buyer accounts:
  # 1. Login to developer.paypal.com.
  # 2. Go to https://developer.paypal.com/developer/accounts
  #
  # ## Activate IPN:
  # 1. Login to your PayPal account (if you are working on dev, login to sandbox.paypal.com using your facilitator email address).
  # 2. Go Here: https://www.paypal.com/cgi-bin/customerprofileweb?cmd=_profile-ipn-notify
  # (or https://sandbox.paypal.com/cgi-bin/customerprofileweb?cmd=_profile-ipn-notify if you are in dev)
  # Reference: https://developer.paypal.com/api/nvp-soap/ipn/IPNTesting/
  #
  # ## How to Find the IPNs
  # 1. Login to your PayPal account (if you are working on dev, login to sandbox.paypal.com using your facilitator email address).
  # 2. Go Here: https://www.paypal.com/us/cgi-bin/webscr?cmd=_display-ipns-history
  # (or https://sandbox.paypal.com/us/cgi-bin/webscr?cmd=_display-ipns-history if you are in dev)
  #
  'paypal_ipn_listener' => ( BlackStack.sandbox? ? 'https://f7df-200-55-87-181.sa.ngrok.io' : CS_HOME_WEBSITE) + '/api1.0/i2p/ipn.json',

  # In PROD environment: use your paypal.com email account.
  # IN DEV environment: use your sandbox.paypal.con email address. 
  'paypal_business_email' => BlackStack.sandbox? ? 'sardi.leandro.daniel-facilitator@gmail.com' : 'sardi.leandro.daniel@gmail.com',
    
  # In PROD environment: use https://www.paypal.com.
  # In DEV environment: use https://www.sandbox.paypal.com.
  # More information here: https://developer.paypal.com/docs/business/test-and-go-live/sandbox/
  'paypal_orders_url' => BlackStack.sandbox? ? 'https://sandbox.paypal.com' : 'https://www.paypal.com',

  # TODO: add API communication in order to handle subscriptions cancelation
  # PayPal API access. 
  # 
  # Follow the steps below to get such information for PROD:
  # 1. Login to your account in either PayPal.com;
  # 2. Go to https://www.paypal.com/businessmanage/credentials/apiAccess;
  # 3. Click on Manage API credentials;
  # 4. Choose to generate an NVP/SOAP API Signature.
  # 
  # For DEV environment, follow the same steps, but loggin into sandbox.PayPal.com.
  # If you don't know the email and/or password of the fictitious Sandbox Accounts, 
  # you can get such informatioin here: https://developer.paypal.com/developer/accounts/  
  # 
  #:paypal_api_username => 'sardi.leandro.daniel-facilitator_api1.gmail.com',
  #:paypal_api_password => 'EPP7VD3GFBTUAXN3',
  #:paypal_signature => 'AKrdO3kt3BSAxRkptc13PKogax8XADsJf-6fRSDKm7J1yKHWf.MNYDro',
})

BlackStack::I2P::add_plans([
    {
        # which product is this plan belonging
        :service_code=>'leads', 
        # recurrent billing plan or one-time payments
        :type=>BlackStack::I2P::PAYMENT_SUBSCRIPTION,  
        # show this plan in the UI
        :public=>true,
        # is this a One-Time Offer?
        # true: this plan is available only if the account has not any invoice using this plan
        # false: this plan can be purchased many times
        :one_time_offer=>false,  
        # plan description
        :item_number=>'dfyl.1', 
        :name=>'Robin', 
        # trial configuration
        :trial_credits=>300, 
        :trial_fee=>1, 
        :trial_units=>3, 
        :trial_period=>'day',     
        # billing details
        :credits=>2611, 
        :normal_fee=>97, # cognitive bias: expensive fee to show it strikethrough, as the normal price. But it's a lie. 
        :fee=>47, # this is the fee that your will charge to the account, as a special offer price.
        :period=>'month',
        :units=>1, # billed monthy
        # Force credits expiration in the moment when the client 
        # renew with a new payment from the same subscription.
        # Activate this option for every allocation service.
        :expiration_on_next_payment => false, # default true
        # Additional period after the billing cycle - Extend 2 weeks after the billing cycle - Referemce: https://github.com/ExpandedVenture/ConnectionSphere/issues/283.
        :expiration_lead_period => 'day', #'M', # default day
        :expiration_lead_units => 365, #3, # default 0
        # bonus
        :bonus_plans=>[
            #{ :item_number => 'ces.lifetime', :period => 1 },
        ],
    }, {
        # which product is this plan belonging
        :service_code=>'leads', 
        # recurrent billing plan or one-time payments
        :type=>BlackStack::I2P::PAYMENT_SUBSCRIPTION,  
        # show this plan in the UI
        :public=>true,
        # is this a One-Time Offer?
        # true: this plan is available only if the account has not any invoice using this plan
        # false: this plan can be purchased many times
        :one_time_offer=>false,  
        # plan description
        :item_number=>'dfyl.2', 
        :name=>'Batman', 
        # trial configuration
        :trial_credits=>300, 
        :trial_fee=>1, 
        :trial_units=>3, 
        :trial_period=>'day',     
        # billing details
        :credits=>6062, 
        :normal_fee=>197, # cognitive bias: expensive fee to show it strikethrough, as the normal price. But it's a lie. 
        :fee=>97, # this is the fee that your will charge to the account, as a special offer price.
        :period=>'month',
        :units=>1, # billed monthy
        # Force credits expiration in the moment when the client 
        # renew with a new payment from the same subscription.
        # Activate this option for every allocation service.
        :expiration_on_next_payment => false, # default true
        # Additional period after the billing cycle - Extend 2 weeks after the billing cycle - Referemce: https://github.com/ExpandedVenture/ConnectionSphere/issues/283.
        :expiration_lead_period => 'day', #'M', # default day
        :expiration_lead_units => 365, #3, # default 0
        # bonus
        :bonus_plans=>[
            #{ :item_number => 'ces.lifetime', :period => 1 },
        ],
    }, {
        # which product is this plan belonging
        :service_code=>'leads', 
        # recurrent billing plan or one-time payments
        :type=>BlackStack::I2P::PAYMENT_SUBSCRIPTION,  
        # show this plan in the UI
        :public=>true,
        # is this a One-Time Offer?
        # true: this plan is available only if the account has not any invoice using this plan
        # false: this plan can be purchased many times
        :one_time_offer=>false,  
        # plan description
        :item_number=>'dfyl.3', 
        :name=>'Hulk', 
        # trial configuration
        :trial_credits=>300, 
        :trial_fee=>1, 
        :trial_units=>3, 
        :trial_period=>'day',     
        # billing details
        :credits=>14071, 
        :normal_fee=>397, # cognitive bias: expensive fee to show it strikethrough, as the normal price. But it's a lie. 
        :fee=>197, # this is the fee that your will charge to the account, as a special offer price.
        :period=>'month',
        :units=>1, # billed monthy
        # Force credits expiration in the moment when the client 
        # renew with a new payment from the same subscription.
        # Activate this option for every allocation service.
        :expiration_on_next_payment => false, # default true
        # Additional period after the billing cycle - Extend 2 weeks after the billing cycle - Referemce: https://github.com/ExpandedVenture/ConnectionSphere/issues/283.
        :expiration_lead_period => 'day', #'M', # default day
        :expiration_lead_units => 365, #3, # default 0
        # bonus
        :bonus_plans=>[
            #{ :item_number => 'ces.lifetime', :period => 1 },
        ],
    }
])
=end
