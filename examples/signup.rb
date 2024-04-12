# load gems and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
require 'version'
DB = BlackStack.db_connect
require 'lib/skeletons'

# create a new l
l = BlackStack::LocalLogger.new('signup.log')

begin

    l.log "Number of existing accounts: #{BlackStack::MySaaS::Account::count.to_s.blue}"

    # signup a new account
    l.logs 'Signup a new account... '
    BlackStack::MySaaS::Account::signup(
        :companyname => 'VyMECO', 
        :username => 'leandro.sardi',
        :email => 'leandro@vymeco.com', 
        :password => 'your.password123',
        :phone => '555-5555'
    )
    l.logf 'done'.green

    l.log "Number of existing accounts: #{BlackStack::MySaaS::Account::count.to_s.blue}"

# catch the case when the process is interrupted
rescue Interrupt => e
    l.logf e.message.red
    l.logf e.backtrace.join("\n")

# catch the case when an exception is raised
rescue Exception => e
    l.logf e.message.red
    l.logf e.backtrace.join("\n")

# ensure releasing of resources and the execution of any other mandatory code
ensure
    GC.start
    DB.disconnect

    # TODO: add any other mandatory code here.

    l.log 'process finished'.green
end
