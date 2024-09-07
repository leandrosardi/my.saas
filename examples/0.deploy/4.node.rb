# load gem and connect database
#require 'mysaas'
#require 'lib/stubs'

require_relative '/home/leandro/code/blackstack-nodes/lib/blackstack-nodes.rb'
require_relative '/home/leandro/code/my.saas/models/stub/deployment/deployment.rb'

require 'config'

#require 'config'
#DB = BlackStack.db_connect
#require 'lib/skeletons'

l = BlackStack::LocalLogger.new('deploy-examples.log')

begin
    #l.logs('Validate SAASLIB environment... ')
    #BlackStack::Deployment.validate_saaslib_env
    #l.done

    l.logs('Add node demo-node... ')
    BlackStack::Deployment.add_node({
        # Unique name to identify a host (a.k.a.: node).
        # It is equal to the hostname of the node.
        #
        # Mandatory.
        #
        # Allowed values: string with a valid hostname.
        #
        :name => 'demo-node', 
        
        # Public Internet IP address of the node.
        # If `nil`, that means that no instance of a cloud server has been created yet for this node.
        #
        # Optional. Default: `nil`.
        #
        # Allowed values: string with a valid IP address.
        # 
        :net_remote_ip => '85.190.240.229',
        
        # Reference to another node where is hosted the database to work with.
        #
        # Mandatory.
        #
        # Allowed values: string with a valid PostgreSQL database name,
        # 
        :db_host => 'demo-node',    
    }.merge(
        T[:prod], 
        T[:web]
    ))
    l.done

    l.logs('Get node demo-node... ')
    n = BlackStack::Deployment.get_node('demo-node')
    l.done

      # switch user to root and create the node object
    l.logs "Creating node object... "
    new_ssh_username = n[:ssh_username]
    new_hostname = n[:name]
    n[:ssh_username] = 'root'
    n[:ssh_password] = n[:ssh_root_password]
    node = BlackStack::Infrastructure::Node.new(n)
    l.done

    l.logs('Connect to node demo-node... ')
    node.connect
    l.done
    # => n.ssh
    
    l.logs 'Valid command: `hostname`... ' 
    l.logf node.exec('hostname').blue
    # => 'dev1'

    l.logs 'Invalid command: `rm`... ' 
    l.logf node.exec('rm').blue
    # => 'dev1'

    l.logs 'Disconnect from node demo-node... '
    n.disconnect
    l.done
    # => nil

rescue => e
    l.error(e)
end