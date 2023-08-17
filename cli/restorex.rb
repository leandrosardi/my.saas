# encoding: utf-8

# restorex.rb : download any folder from dropbox.
# Author: Leandro D. Sardi (https://github.com/leandrosardi).
#

require 'mysaas'
require 'lib/stubs'
require 'config'

# 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command download any folder from DropBox.', 
  :configuration => [{
    :name=>'from', 
    :mandatory=>true, 
    :description=>'The name of the folder in dropbox you want to download. E.g.: .appending.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }, {
    :name=>'to', 
    :mandatory=>true, 
    :description=>'Location in your local drive where you want to place the downloaded folder. E.g.: ~/.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }]
)

log = BlackStack::LocalLogger.new('./restorex.log')

# parameters
foldername = parser.value('from') 
destination = parser.value('to')

log.logs "Restoring #{foldername}... "
BlackStack::BackUp.restore(
  "#{foldername}",
  log,
  'tempy.zip',
  true,
  destination,
  true
)
log.done


