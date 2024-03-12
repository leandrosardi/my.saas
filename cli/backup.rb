# encoding: utf-8

# backupf.rb : this command upload files and folders to dropbox.
# Author: Leandro D. Sardi (https://github.com/leandrosardi).
#

require 'mysaas'
require 'lib/stubs'
require 'config'

# 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command upload secret files to DropBox.', 
  :configuration => [
=begin
  {
    :name=>'verbose', 
    :mandatory=>false, 
    :description=>'If show the output of the API calls. Default is no.', 
    :type=>BlackStack::SimpleCommandLineParser::BOOL,
    :default => false,
  },
=end
  ]
)

l = BlackStack::LocalLogger.new('./backup.log')

BlackStack::BackUp.backup(l)
