# This script is to measure the expenses of CRDB under different queries.

# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
require 'version'
DB = BlackStack::CRDB::connect
require 'lib/skeletons'

# TODO: dfy-leads extension should require leads extension as a dependency
require 'extensions/leads/lib/skeletons'
require 'extensions/leads/main'

require 'extensions/scraper/lib/skeletons'
require 'extensions/scraper/main'

require 'extensions/dfy-leads/lib/skeletons'
require 'extensions/dfy-leads/main'

# add required extensions
BlackStack::Extensions.append :i2p
BlackStack::Extensions.append :leads
BlackStack::Extensions.append :scraper
BlackStack::Extensions.append :'dfy-leads'

l = BlackStack::LocalLogger.new('./cost.log')

=begin
while (true)
    BlackStack::DfyLeads::Order.all do |o|
        l.logs "#{o.name}... "
        l.logf "done"
    end
    l.logs "sleep 1 second... "
    sleep 1
    l.done
end
=end

while (true)
    DB["SELECT o.id, o.name FROM scr_order o"].all do |o|
        l.logs "#{o[:name]}... "
        l.logf "done"
    end
    l.logs "sleep 1 second... "
    sleep 1
    l.done
end
