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
  }, {
    :name=>'skip', 
    :mandatory=>false, 
    :description=>"If the file already exists, then skip it. Otherwise, replace it. Activate this flag when the process was interrumpted, and you don't want to resume from the beginning. Note: If the process is interrumpted while the downloading of a file, such a file is in your filesystem, but not complteded or corrupted. Default: false.", 
    :type=>BlackStack::SimpleCommandLineParser::BOOL,
    :default=>false
  }]
)

log = BlackStack::LocalLogger.new('./download.log')

# parameters
foldername = parser.value('from') # '.appending' 
destination = parser.value('to') # '/root/.appending'

BlackStack::BackUp.dropbox_folder_files(foldername).each { |filename|
  # if filename aleady exists in destination folder, delete it.
  # deletion is necessary because if the process has been interrupted, the file may be have downloaded partially.
  exists = File.exists?("#{destination}/#{filename}") 
  if exists && !parser.value('skip')
    # delete the existing temfile
    log.logs "Deleting old #{foldername}/#{filename}... "
    File.delete("#{destination}/#{filename}")
    log.done
  end
  # download the file as `tempfile`
  log.logs "Restoring #{foldername}/#{filename}... "
  if exists && parser.value('skip')
    log.logf 'skipped'
  else
    BlackStack::BackUp.dropbox_download_file(
      foldername,
      filename,
      destination
    )
    log.done
  end
}