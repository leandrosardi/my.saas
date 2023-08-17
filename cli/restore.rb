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
    :mandatory=>true, 
    :description=>'The timestamps of the backup you want to restore. E.g.: 20221120183545UTC.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }, {
  # web server installation
    :name=>'folders', 
    :mandatory=>false, 
    :description=>'Regular expresion to filter the folders to process. Default: .*', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => '.*',
  }]
)

log = BlackStack::LocalLogger.new('./restore.log')

timestamp = parser.value('t')
BlackStack::BackUp.destinations.select { |d| d[:folder]=~/#{parser.value('folders')}/ }.each { |d|
    # parameters
    foldername = d[:folder] # how to name this backup in dropbox 
    source = d[:source] # source folder to backup
    destination = source.gsub(/#{Regexp.escape(source.split('/').last)}/, '')

    log.logs "Restoring #{foldername}... "
    BlackStack::BackUp.restore(
        "#{timestamp}.#{foldername}",
        log,
        'tempy.zip',
        true,
        destination,
        true
    )
    log.done
}

