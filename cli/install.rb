# This script clone the source code of all the component of massprospecting in the local computer.
#
# For installing the source code you need access to all the repostiories of https://github.com/MassProspecting.
# The required repositories of https://github.com/leandrosardi are alrady public.
#
# The computer where you run this script should be a fresh Ubuntu 20.04 with our [standard environment](https://github.com/leandrosardi/environment) installed.
# 

require 'simple_cloud_logging'
require 'simple_command_line_parser'
require 'highline'
require 'config'

parser = BlackStack::SimpleCommandLineParser.new(
    :description => 'This command will run automation of one specific profile.', 
    :configuration => [{
        :name=>'component', 
        :mandatory=>false, 
        :description=>"Name of the component you want to install. Keep in blank to install all components. E.g.: master. Default: `'-'`.", 
        :type=>BlackStack::SimpleCommandLineParser::STRING,
        :default=>'-',
    }, {
        :name=>'ask', 
        :mandatory=>false, 
        :description=>"Show warning messages and ask the user to continue or not. Default: true.", 
        :type=>BlackStack::SimpleCommandLineParser::BOOL,
        :default=>true,
    }, {
        :name=>'secrets', 
        :mandatory=>false, 
        :description=>"Download the configuration file of the component. Warning: Existing configuration file will be overwritten. Default: false.", 
        :type=>BlackStack::SimpleCommandLineParser::BOOL,
        :default=>true,
    }, {
        :name=>'update', 
        :mandatory=>false, 
        :description=>"Update source code by running `git fetch` and `git update` commands.", 
        :type=>BlackStack::SimpleCommandLineParser::BOOL,
        :default=>false,
    }, {
        :name=>'verbose',
        :mandatory=>false,
        :description=>'Show the output of the commands executed.. Default: no.', 
        :type=>BlackStack::SimpleCommandLineParser::BOOL,
        :default=>false,
    }, {
        :name=>'output',
        :mandatory=>false,
        :description=>'File where redirect the output of all the commands executed. Default: deploy-output.log.', 
        :type=>BlackStack::SimpleCommandLineParser::STRING,
        :default=>'deploy-output.log',
    }, {
        :name=>'github_username',
        :mandatory=>true,
        :description=>'Github username to access the private repositories. Mandatory.', 
        :type=>BlackStack::SimpleCommandLineParser::STRING,
    }, {
        :name=>'github_password',
        :mandatory=>true,
        :description=>'Github password to access the private repositories. Mandatory.', 
        :type=>BlackStack::SimpleCommandLineParser::STRING,
    }]
)

l = BlackStack::LocalLogger.new('install.log')
dirname = File.expand_path(File.dirname(File.dirname(__FILE__)))

gitu = parser.value('github_username')
gitp = parser.value('github_password')

update = parser.value('update')
verbose = parser.value('verbose')
output = "#{dirname}/#{parser.value('output')}"
secrets = parser.value('secrets')
ask = parser.value('ask')

redirect = verbose ? nil : " >> #{output} 2>&1"

# Warnings
exit(0) if ask && secrets && !HighLine.agree("Warning: The secrets will be overwritten. Do you want to continue?".red)
exit(0) if ask && update && !HighLine.agree("Warning: Any change to the source code that is not pushed to the repositories will be removed. Do you want to continue?".red)

## Secret
folder = "#{dirname}/secret"
l.logs "Clonning #{folder.blue}... "
if !secrets
    l.skip
else
    success = system("git clone https://#{gitu}:#{gitp}@github.com/massprospecting/secret --single-branch --branch main #{folder} #{redirect}")
    success ||= File.exists?(folder)
    l.done if success
    l.error if !success

    l.logs "Updating code of #{folder.blue}... "
    success = system("cd #{folder};git fetch --all #{redirect};git reset --hard origin/main #{redirect}")
    l.done if success
    l.error if !success
end

## Components
COMPONENTS[:list].select { |c|
    c[:name] == parser.value('component') || parser.value('component') == '-'
}.each { |c|
    folder = "#{dirname}/#{c[:name]}"
    l.logs "Clonning #{folder.blue}... "
    success = system("git clone https://#{gitu}:#{gitp}@github.com/#{c[:repo]} --single-branch --branch #{c[:branch]} #{folder} #{redirect}")
    success ||= File.exists?(folder)
    l.done if success
    l.error if !success

    l.logs "Updating code of #{folder.blue}... "
    if !update
        l.skip
    else
        success = system("cd #{folder};git fetch --all #{redirect};git reset --hard origin/#{c[:branch]} #{redirect}")
        l.done if success
        l.error if !success
    end

    l.logs "Updating gems for #{folder.blue}... "
    success = system("cd #{folder};bundler update #{redirect}")
    l.done if success
    l.error if !success

    l.logs "Creating secret for #{folder.blue}... "
    if !secrets
        l.skip
    else
        # copy file from dirname/secret/config-#{c[:name]}.rb to #{folder}/config.rb
        success = system("cp #{dirname}/secret/config-#{c[:name]}.rb #{folder}/config.rb #{redirect}")
        l.done if success
        l.error if !success
    end

    c[:extensions].each { |e|
        folder = "#{dirname}/#{c[:name]}/extensions/#{e[:name]}"
        l.logs "Clonning #{folder.blue}... "
        success = system("git clone https://#{gitu}:#{gitp}@github.com/#{e[:repo]} --single-branch --branch #{e[:branch]} #{folder} #{redirect}")
        success ||= File.exists?(folder)
        l.done if success
        l.error if !success
    }

    c[:extensions].each { |e|
        folder = "#{dirname}/#{c[:name]}/extensions/#{e[:name]}"
        l.logs "Updating code of #{folder.blue}... "
        if !update
            l.skip
        else
            success = system("cd #{folder};git fetch --all #{redirect};git reset --hard origin/#{e[:branch]} #{redirect}")
            l.done if success
            l.error if !success
        end
    }
}
