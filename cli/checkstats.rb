# encoding: utf-8

# statcheck.rb : check the congruency of all the `stat_*` fields in the database.
# Author: Leandro D. Sardi (https://github.com/leandrosardi).
#

require 'mysaas'
require 'lib/stubs'

# 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command upload secret files to DropBox.', 
  :configuration => [{
    :name=>'verbose', 
    :mandatory=>false, 
    :description=>'If show the output of the API calls. Default is no.', 
    :type=>BlackStack::SimpleCommandLineParser::BOOL,
    :default => false,
  }]
)

l = BlackStack::BaseLogger.new('checkstats.log')

require 'config'
l.logs 'Connecting the database... '
DB = BlackStack::CRDB::connect
require 'lib/skeletons'
require 'extensions/leads/lib/skeletons'
l.done

l.logs 'Checking... '
BlackStack::Leads.check_stats(l).size.to_s
l.done