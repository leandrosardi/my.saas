# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
DB = BlackStack.db_connect
require 'lib/skeletons'

BlackStack::Emails::delivery(
    :receiver_name => 'Leandro D. Sardi',
    :receiver_email => 'demo@massprospecting.com',
    :subject => 'Welcome to MassProspecting',
    :body => '<h1>Welcome to MassProspecting</h1>',
)