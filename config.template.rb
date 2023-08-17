
# constante auxiliar
DEFAULT_SERVICE = 'emails'

# Funnel Configuration
# DFY-Leads + DFY-Outreach System
BlackStack::Funnel.add({
    :name => 'funnels.main',
# TODO: add descriptor about the email marketing automation
# TODO: add descriptor about which transactional emails activate for this funnel
# TODO: add A/B testing of screens (landing, offer, plans, etc)
    # decide if go to one-time-offer screen, or 
    # to the plans screen. Return the URL to go.    
    :url_plans => Proc.new do |login, *args|
        url = '/offer?service=emails'
        url = '/plans?service=emails' if login.user.account.disabled_trial
        url
    end,
    # return the url to go after signup
    :url_after_signup => Proc.new do |login, *args|
        BlackStack::Funnel.url_plans(login, 'funnels.main')
    end,
    # return the url to go after login
    :url_after_login => Proc.new do |login, *args|
      '/dashboard?service=emails'
    end,
    # return the url to go if the user
    # choose to go for free in the plans
    # screen.
    :url_to_go_free => Proc.new do |login, *args|
        '/step1?service=emails'
    end,
})

# setting up breakpoints for backend processes.
# enabling/disabling the flag `:alloow_brakpoints` will enable/disable the function `binding.pry`
BlackStack::Debugging::set({
  :allow_breakpoints => SANDBOX,
})

# DB ACCESS - KEEP IT SECRET
# Connection string to the demo database: export DATABASE_URL="postgresql://demo:<ENTER-SQL-USER-PASSWORD>@free-tier14.aws-us-east-1.cockroachlabs.cloud:26257/mysaas?sslmode=verify-full&options=--cluster%3Dmysaas-demo-6448"
BlackStack::CRDB::set_db_params({ 
  :db_url => 'free-tier14.aws-us-east-1.cockroachlabs.cloud', # always working with production database 
  :db_port => '26257', 
  :db_cluster => 'blackstack-4545',
  :db_name => 'blackstack', 
  :db_user => 'blackstack', 
  :db_password => '(write your db password here)',
})

# Setup connection to the API, in order get bots requesting and pushing data to the database.
# TODO: write your API-Key here. Refer to this article about how to create your API key:
# https://sites.google.com/expandedventure.com/knowledge/
BlackStack::API::set_api_url({
  # IMPORTANT: It is strongly recommended that you 
  # use the api_key of an account with prisma role, 
  # and assigned to the central division too.
  :api_key => '4db9d88c-dee9-4b5a-8d36-134d38e9f763', 
  # IMPORTANT: It is stringly recommended that you 
  # write the URL of the central division here. 
  :api_protocol => SANDBOX ? 'http' : 'https',
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
  :api_domain => SANDBOX ? '127.0.0.1' : '54.157.239.98', 
  :api_port => SANDBOX ? '3000' : '443',
  :api_less_secure_port => '3000',
})

# storage configuration of new accounts
# 
# Every account has assigned a folder where are stored 
# files regarding the different services of the platform. Here you
# can setup the location of the clients' folder, and also the list
# of subfolders to manage for each client.
#
# If you remove a folder from set_storage_sub_folders, it will not 
# be deleted from the filesystem. But if you add a folder to the 
# array set_storage_sub_folders it should be added to every new 
# client automatically. This feature is pending.
# 
# By now, to update the storage forder of an account, you should use
# the method `Account::update_storage_folder`. 
#
BlackStack::Storage::set_storage({
  :storage_folder => SANDBOX ? '~/code/mysaas/public/clients' : '/home/ubuntu/code/mysaas/public/clients',
  :storage_default_max_allowed_kilobytes => 15 * 1024,
  :storage_sub_folders => [
    'downloads', 'uploads', 'logs'
  ],
})

# IMPORTANT NOTE: This value should have a format like FOO.COM. 
# => Other formats can generate bugs in the piece of codes where 
# => this constant is concatenated. 
APP_DOMAIN = SANDBOX ? '127.0.0.1' : 'connectionsphere.com' 
APP_NAME = '@app_name@'

# Email to contact support
HELPDESK_EMAIL = 'tickets@expandedventure.com'

# Company Information
COMPANY_NAME = '@company_name@'
COMPANY_TYPE = 'LLC'
COMPANY_ADDRESS = '@company_address@'
COMPANY_PHONE = '@company_phone@'
COMPANY_URL = '@company_url@'

# Useful URLs
TERMS_URL = '@terms_url@' # Terms and Conditions URL.
PRIVACY_URL = '@privacy_url@' # Privacy Policy URL.
CANCEL_URL = '@cancel_url@' # Article explaining how to cancel the service.
HELPDESK_URL = '@helpdesk_url@' # Helpdesk URL.

# app url
CS_HOME_PAGE_PROTOCOL = 'https'
CS_HOME_PAGE_DOMAIN = SANDBOX ? '127.0.0.1' : 'connectionsphere.com'
CS_HOME_PAGE_PORT = '443'
CS_HOME_WEBSITE = CS_HOME_PAGE_PROTOCOL+'://'+CS_HOME_PAGE_DOMAIN+':'+CS_HOME_PAGE_PORT

# default timezone
DEFAULT_TIMEZONE_SHORT_DESCRIPTION='Buenos Aires'

=begin
# parameters for emails delivery
BlackStack::Emails.set(
  # smtp request sender information
  :sender_email => 'tickets@expandedventure.com',
  :from_email => 'tickets@expandedventure.com', 
  :from_name => 'ConnectionSphere',
  
  # smtp request connection information
  :smtp_url => 'smtp.postmarkapp.com',
  :smtp_port => '25',
  :smtp_user => '******',
  :smtp_password => '******',
)

# parameters for end user notifications
BlackStack::Notifications.set(  
  :logo_url => CS_HOME_WEBSITE + '/core/images/logo/logo-128-01.png',
  :signature_picture_url => CS_HOME_WEBSITE + '/core/images/logo/owner.jpg',
  :signature_name => 'Leandro D. Sardi',
  :signature_position => 'Founder & CEO',
)

# declare nodes for automated deploying
BlackStack::Deployer::add_nodes([{
    # use this command to connect from terminal: ssh -i 'plank.pem' ubuntu@ec2-34-234-83-88.compute-1.amazonaws.com
    :name => 'sinatra1',
 
    # ssh
    :net_remote_ip => '44.203.58.26',  
    :ssh_username => 'ubuntu',
    :ssh_port => 22,
    #:ssh_password => ssh_password,
    :ssh_private_key_file => SANDBOX ? '/home/leandro/code/mysaas/plank.pem' : '/home/ubuntu/code/mysaas/plank.pem',
 
    # git
    :git_branch => 'main',

    # name of the LAN interface
    :laninterface => 'eth0',

    # cockroachdb
    :crdb_hostname => SANDBOX ? '127.0.0.1' : '44.203.58.26',
    :crdb_database_certs_path => SANDBOX ? '/home/ubuntu' : '/home/ubuntu',
    :crdb_database_password => 'bsws2022',
    :crdb_database_port => 26257,
    :crdb_dashboard_port => 8080,

    # sinatra
    :web_port => 81,

    # config.rb content
    :config_rb_content => File.read(SANDBOX ? '/home/leandro/code/mysaas/config.rb' : '/home/ubuntu/code/mysaas/config.rb'),

    # default deployment routine for this node
    :deployment_routine => 'deploy-mysaas',
}])

# add required extensions
BlackStack::Extensions.append :leads

# Dropbox mysaas-backups access tocken
# If you have a Dropbox account, you can integrate it with MySaaS for upload backups of the storage folder and database.
# Grab your access token from here: https://www.dropbox.com/developers/apps/info/lnystcoayzse5at
# 
# More information here: https://github.com/leandrosardi/mysaas/issues/94
# 
BlackStack::BackUp.set({
    :dropbox_refresh_token => '*******',
    # different cloud folders to upload differt local folders 
    :destinations => [{
      # name for the cloud folder
      :folder => SANDBOX ? 'dev.clients' : 'prod.clients',
      # path of the local folder to upload
      :source => SANDBOX ? '/home/leandro/code/mysaas/public/clients' : '/home/ubuntu/code/mysaas/public/clients',
    }],
})
=end
