# load gem and connect database
require 'mysaas'
require 'lib/stubs'
#require 'config'
#DB = BlackStack.db_connect
#require 'lib/skeletons'

l = BlackStack::LocalLogger.new('deploy-examples.log')

begin
    l.logs('Executing command... ')
    out = BlackStack::Deployment.execute_command('ls -l /')
    l.logf out.blue
rescue => e
    l.logf e.message.red
end