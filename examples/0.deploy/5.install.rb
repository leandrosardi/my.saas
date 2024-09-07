# load gem and connect database
#require 'mysaas'
#require 'lib/stubs'

require_relative '/home/leandro/code/blackstack-nodes/lib/blackstack-nodes.rb'
require_relative '/home/leandro/code/my.saas/models/stub/deployment/deployment.rb'
require 'config'

#DB = BlackStack.db_connect
#require 'lib/skeletons'

l = BlackStack::LocalLogger.new('deploy-examples.log')

begin
    BlackStack::Deployment.install(
        'demo-node',
        logger: l
    )
rescue => e
    l.error(e)
end