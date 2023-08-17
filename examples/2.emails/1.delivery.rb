# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
DB = BlackStack::CRDB::connect
require 'lib/skeletons'

BlackStack::Emails::delivery(
    :receiver_name => 'Leandro D. Sardi',
    :receiver_email => 'leandro.sardi@expandedventure.com',
    :subject => 'Welcome to ConnectionSphere',
    :body => '<h1>Welcome to ConnectionSphere</h1>',
)