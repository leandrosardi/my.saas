# MySaaS Configuration File.
# Author: Leandro D. Sardi.
# Date: Oct-2022.
#
# Never push the file to the repository.
# Be sure this file is always included in the .gitignore.
#
# To save config.rb and other critical files, use the CLI
# command `backup`. I will create a backup of the current
# files into a cloud storage specified by you.
#

# CODE_PATH may be different in production and development environments.
CODE_PATH = BlackStack.sandbox? ? '/home/leandro/code/freeleadsdata' : '/home/ubuntu/code/freeleadsdata'
CS_API_KEY = '118f3c32-****-****-****-************'
DB_REFRESH_TOKEN = 'h6wRt9et****-****BgDj'

BlackStack::Funnel.set({
    # Goolge Analytics
    #
    # Find your Google Analytics UTM tracking 
    # code by following the steps in this tutorial:
    # https://www.monsterinsights.com/docs/where-to-find-utm-tracking-code-results-data-in-google-analytics
    # 
    :ga => BlackStack.sandbox? ? 'G-*****LRH' : 'G-XXXXXXXXXX',
})

# Funnel Configuration
BlackStack::Funnel.add({
    :name => 'funnels.main',
    # decide if go to one-time-offer screen, or 
    # to the plans screen. Return the URL to go.    
    :url_plans => Proc.new do |login, *args|
        '/plans?service=dfy-leads'
    end,
    # return the url to go after signup
    :url_after_signup => Proc.new do |login, *args|
        BlackStack::Funnel.url_after_login(login, 'funnels.main')
    end,
    # return the url to go after login
    :url_after_login => Proc.new do |login, *args|
        '/dashboard'
    end,
    # return the url to go if the user
    # choose to go for free in the plans
    # screen.
    :url_to_go_free => Proc.new do |login, *args|
        '/dashboard'
    end,
})

# setting up breakpoints for backend processes.
# enabling/disabling the flag  will enable/disable the function 
BlackStack::Debugging::set({
  :allow_breakpoints => BlackStack.sandbox?,
})

# DB ACCESS - KEEP IT SECRET
# 
# For running a CockroachDB instance in your local computer:
# - cockroach start-single-node --insecure
# 
# Either you use a local (demo) database, or a cloud (serverless) database, always find a connection string like this:
# - postgresql://demo:demo7343@127.0.0.1:26257/movr?sslmode=require
# - postgresql://root@dev1:26257/defaultdb?sslmode=disable
# Then, map the parameters of such a connection string here.
# 
BlackStack::CRDB::set_db_params({ 
  :db_url => BlackStack.sandbox? ? '127.0.0.1' : '<serverless instance IP here>', 
  :db_port => '26257', 
  :db_cluster => BlackStack.sandbox? ? nil : '<serverless cluster ID here>', # this parameter is optional. Use this when using CRDB serverless.
  :db_name => '<db name here>', 
  :db_user => '<db user here>', 
  :db_password => '<db password here>',
  :db_sslmode => BlackStack.sandbox? ? 'disable' : 'verify-full',
})

# Setup connection to the API, in order get bots requesting and pushing data to the database.
# TODO: write your API-Key here. Refer to this article about how to create your API key:
# https://sites.google.com/expandedventure.com/knowledge/
#
# TODO: Switch back to HTTPS when the emails.leads.uplaod.ingest process is migrated to DropBox for elastic storage.
# 
BlackStack::API::set_api_url({
  # IMPORTANT: It is strongly recommended that you 
  # use the api_key of an account with prisma role, 
  # and assigned to the central division too.
  :api_key => '118f3c32-****-****-****-************', 
  # IMPORTANT: It is stringly recommended that you 
  # write the URL of the central division here. 
  :api_protocol => BlackStack.sandbox? ? 'http' : 'https',
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
  :api_domain => BlackStack.sandbox? ? '127.0.0.1' : '<your saas domain here>', 
  :api_port => BlackStack.sandbox? ? '3000' : '443',
  :api_less_secure_port => '3000',
})

# IMPORTANT NOTE: This value should have a format like FOO.COM. 
# => Other formats can generate bugs in the piece of codes where 
# => this constant is concatenated. 
APP_DOMAIN = BlackStack.sandbox? ? '127.0.0.1' : '<your saas domain here>' 
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
TERMS_URL = 'https://connectionsphere.com/seminars/pub/legal/terms-of-service' # Terms and Conditions URL.
PRIVACY_URL = 'https://connectionsphere.com/seminars/pub/legal/privacy-policy' # Privacy Policy URL.
CANCEL_URL = 'https://connectionsphere.com/seminars/pub/help/how-to-cancel-subscription' # Article explaining how to cancel the service.
HELPDESK_URL = 'https://connectionsphere.com/seminars/pub/help/getting-started' # Helpdesk URL.

# app url
CS_HOME_PAGE_PROTOCOL = BlackStack.sandbox? ? 'http' : 'https'
CS_HOME_PAGE_DOMAIN = BlackStack.sandbox? ? '127.0.0.1' : '<your saas domain here>'
CS_HOME_PAGE_PORT = BlackStack.sandbox? ? '3000' : '443'
CS_HOME_WEBSITE = CS_HOME_PAGE_PROTOCOL+'://'+CS_HOME_PAGE_DOMAIN+':'+CS_HOME_PAGE_PORT

# default timezone
DEFAULT_TIMEZONE_SHORT_DESCRIPTION='Buenos Aires'

# parameters for emails delivery
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

# declare production nodes.
# .BlackStack.sandbox? flag doesn't play here.
# both cs.pem file and config.rb file are always taken from the local dev machine (leandro).
BlackStack::Deployer::add_nodes([{
    # use this command to connect from terminal: ssh -i 'cs.pem' ubuntu@ec2-34-234-83-88.compute-1.amazonaws.com
    :name => 'web-server', 
    # ssh
    :net_remote_ip => BlackStack.sandbox? ? '127.0.0.1' : '54.157.239.98',  
    :ssh_username => 'ubuntu',
    :ssh_port => 22,
    #:ssh_password => ssh_password,
    :ssh_private_key_file => BlackStack.sandbox? ? '/home/leandro/code/my.saas/cli/cs.pem' : '$HOME/code/my.saas/cli/cs.pem',
    # git
    :git_branch => 'main',
    :git_username => 'leandrosardi',
    :git_password => '****',
    # code folder
    :code_folder => BlackStack.sandbox? ? '/home/leandro/code/my.saas' : '/ubuntu/code/my.saas',
    # name of the LAN interface
    :laninterface => 'eth0',
    # sinatra
    :web_port => 3000,
    # config.rb content - always using dev-environment here
    :config_rb_content => File.read(BlackStack.sandbox? ? '/home/leandro/code/my.saas/config.rb' : '$HOME/code/my.saas/config.rb'),
    # default deployment routine for this node
    :deployment_routine => 'deploy-my.saas',
    # setup stand-alone processes
    # setup worker processes
    :pampa => {
        :max_workers => 0,
        :procs => [
            {
                :name => 'leads.export',
                :logfile => '$HOME/code/my.saas/export.log',
                :params => [
                    { :name=>'foo', :value=>'bar' },
                    { :name=>'foo2', :value=>'bar2'},
                ],
                #:command => 'cd ~ & nohup ruby ~/code/my.saas/extensions/leads/p/export.rb >/dev/null 2>&1 &',
                :min_cycle_seconds => 60,
                :processing_function => Proc.new do |*args|
                    # TODO: Code Me!
                end,
            },
        ],
    },
}])

# Reference: https://github.com/leandrosardi/my-dropbox-api
BlackStack::DropBox.set({
  :connectionsphere_api_key => CS_API_KEY,
  :dropbox_refresh_token => DB_REFRESH_TOKEN,
})

# Manage backup of secret files
# Reference: https://github.com/leandrosardi/my.saas/blob/main/docu/03.secret-files-management.md
BlackStack::BackUp.set({
    # different cloud folders to upload differt local folders 
    :bucket => [{
      # configuration file.
      :name => 'mysaas-configuration',
      # drop box folder where to store this backup
      :folder => 'freeleadsdata.app',
      # must be absolute paths
      :path => CODE_PATH + '/app',
      # pattern of files to find in the :path_origin
      :files => ['config.rb'],
    }, {
      # certification file for connecting serverless CockroackDB.
      :name => 'postgres-certificate',
      :folder => 'freeleadsdata.app',
      :path => '~/.postgresql',
      :files => ['root.crt'],
    }, {
      # certificate to connect AWS instances.
      :name => 'aws-certificate',
      :folder => 'freeleadsdata.app',
      :path => CODE_PATH + '/my.saas/cli',
      :files => ['fld.pem'],
    }, {
      # database deploying .lock files for SQL migrations
      :name => 'deploying-lockfiles',
      :folder => 'freeleadsdata.app',
      :path => CODE_PATH + '/my.saas/cli',
      :files => [
        'my-ruby-deployer.lock', 
        'my-ruby-deployer.i2p.lock', 
        'my-ruby-deployer.monitoring.lock',
        'my-ruby-deployer.content.lock',
      ],
    }, {
      # SSL certificaties.
      :name => 'ssl-Certificates',
      :folder => 'freeleadsdata.app',
      :path => CODE_PATH + '/my.saas/ssl',
      :files => ['prod.crt', 'prod.key'],
    }]
})

=begin
# add required extensions
BlackStack::Extensions.append :i2p
BlackStack::Extensions.append :content, { :show_in_top_bar => false, :show_in_footer => false, :show_in_dashboard => false }
BlackStack::Extensions.append :monitoring, { :show_in_top_bar => false, :show_in_footer => false, :show_in_dashboard => false }

# developer extensions
BlackStack::Extensions.append :selectrowsjs, { :show_in_top_bar => false, :show_in_footer => false, :show_in_dashboard => false }
BlackStack::Extensions.append :filtersjs, { :show_in_top_bar => false, :show_in_footer => false, :show_in_dashboard => false }
BlackStack::Extensions.append :progressjs, { :show_in_top_bar => false, :show_in_footer => false, :show_in_dashboard => false }
BlackStack::Extensions.append :templatesjs, { :show_in_top_bar => false, :show_in_footer => false, :show_in_dashboard => false }
BlackStack::Extensions.append :listsjs, { :show_in_top_bar => false, :show_in_footer => false, :show_in_dashboard => false }
BlackStack::Extensions.append :datasjs, { :show_in_top_bar => false, :show_in_footer => false, :show_in_dashboard => false }
=end

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

BlackStack::Workmesh.add_service({
    # unique service name
    :name => 'micro.data',
    # Define the tasks table: each record is a task.
    #
    # In this example, each account in our saas is assigned to a micr-service node.
    # In other words, the work is assigned at an account-level.
    #
    # Each account is stored in a row in the `account` table.
    # 
    :entity_table => :account,
    # Define what is the column in the table where I store the name of the assigned node.
    :entity_field_assignation => :'node_for_micro_dfyl_appending',

    # Defining assignation criteria
    :assignation => :roundrobin, # other choices are: `:entityweight`, `:roundrobin` and `:entitynumber`

    # Defining micro-service protocol.
    # This is the list of entities at the SaaS side.
    :protocols => [{
      :name => 'push_order',
      # I need to push all the emails delivered and received, including bounce reports.
      :entity_table => :scr_order,
      :entity_field_id => :id, # identify each record in the table uniquely
      :entity_field_sort => :create_time, # push/process/pull entities in this order - Workmesh uses this field to know which was the latest record pushed/processed/pulled.
      :push_function => Proc.new do |entity, node, l, *args|
        # entity: the entity to be pushed
        # node: the node where the entity will be pushed
        # l: the logger
        # args: additional arguments
        #
        res = nil
        b = BlackStack::I2P::Account.where(:id=>entity.user.id_account).first
        h = entity.to_hash
        # add the leads credits of the account
        b.update_balance
        h['credits'] = b.credits('leads')
        # apply transformations        
        h['insights'].each do |i|
          i['prompt1'] = BlackStack::Scraper::Insight.transform(i['prompt1']) if i['prompt1']
          i['prompt2'] = BlackStack::Scraper::Insight.transform(i['prompt2']) if i['prompt2']
        end
        # call access point
        url = 'http://'+node.net_remote_ip+':'+node.workmesh_port}/api1.0/orders/zi/push.json'
        begin
            params = {
                'api_key' => node.workmesh_api_key,
                'order' => h,
            }
            res = BlackStack::Netting::call_post(url, params)
            parsed = JSON.parse(res.body)
            raise parsed['status'] if parsed['status']!='success'
        rescue Errno::ECONNREFUSED => e
            raise 'Errno::ECONNREFUSED:' + e.message.red
        rescue => e2
            raise 'Exception:' + e2.message.red
        end
      end, # push_function
      :entity_field_push_time => :'micro_emails_delivery_push_time',
      :entity_field_push_success => :'micro_emails_delivery_push_success',
      :entity_field_push_error_description => :'micro_emails_delivery_push_error_description',
    }],
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

=begin
## 
## Micro Services - Nodes
## 
## 
BlackStack::Workmesh.add_node({
    :name => 'n02',
    # setup SSH connection parameters
    :net_remote_ip => '45.10.154.254',  
    :ssh_username => 'root', # example: root
    :ssh_port => 22,
    :ssh_password => 'SantaClara123',
    # workmesh parameters
    :workmesh_api_key => '118f3c32-c920-40c0-a938-22b7471f8d20', # keep this secret - don't push this to your repository.
    :workmesh_port => 3000, #BlackStack.sandbox? ? 3001 : 3000,  
    :workmesh_service => :'freeleadsdata/micro.data',
    # git
    :git_user => 'ConnectionSphere',
    :git_branch => 'main',
    # name of the LAN interface
    :laninterface => 'eth0',
    # config.rb content - always using dev-environment here
    :config_rb_content => File.read(BlackStack.sandbox? ? '/home/leandro/code/freeleadsdata/micro.data/config.rb' : '$HOME/code/freeleadsdata/micro.data/config.rb'),
    # deployment routine for this node
    :deployment_routine => 'deploy-micro.dfyl.appending',
})
=end