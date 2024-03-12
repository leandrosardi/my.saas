# encoding: utf-8

# restore.rb : this command download files and folders from dropbox.
# Author: Leandro D. Sardi (https://github.com/leandrosardi).
#

require 'mysaas'
require 'lib/stubs'
require 'config'

# 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command download secret files from DropBox.', 
  :configuration => [{
    :name=>'t', 
    :mandatory=>false, 
    :description=>'The timestamps of the backup you want to restore. E.g.: 20221120183545UTC. Default: nil', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => '-',
  }, {
    # web server installation
    :name=>'buckets', 
    :mandatory=>false, 
    :description=>'Regular expresion to filter the buckets to process. Default: .*', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => '.*',
=begin
  }, {
  # DropBox
    :name=>'cs-api-key', 
    :mandatory=>false, 
    :description=>'API key to connect ConnectionSphere and process the DropBox refresh token. Default: Use the value in config.rb', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => '-',
  }, {
    :name=>'db-refresh-token', 
    :mandatory=>false, 
    :description=>'DropBox refresh token. Default: Use the value in config.rb', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => '-',
=end
  }]
)

l = BlackStack::LocalLogger.new('./restore.log')

t = parser.value('t')
t = nil if t=='-'

BlackStack::BackUp.restore(t, l)
