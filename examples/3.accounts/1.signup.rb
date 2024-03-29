# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
require 'version'
DB = BlackStack.db_connect
require 'lib/skeletons'

# signup a new account
BlackStack::MySaaS::Account::signup(
    :companyname => 'name of your company', 
    :username => 'your name',
    :email => 'linkedin@expandedventure.com', 
    :password => 'your.password123',
    :phone => '555-5555'
)
