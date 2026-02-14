# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
DB = BlackStack.db_connect
require 'lib/skeletons'

BlackStack::Emails::delivery(
    :receiver_name => 'Leandro D. Sardi',
    :receiver_email => 'leandro.sardi9@bue.edu.ar',
    :subject => 'Welcome to ConnectionSphere',
    :body => '<h1>Welcome to ConnectionSphere</h1><p>Welcome to ConnectionSphere</p>',
)