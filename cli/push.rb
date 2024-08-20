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
    }]
)

l = BlackStack::LocalLogger.new('push.log')
dirname = File.expand_path(File.dirname(File.dirname(__FILE__)))

verbose = parser.value('verbose')
output = "#{dirname}/#{parser.value('output')}"
component = parser.value('component')
redirect = verbose ? nil : " >> #{output} 2>&1"

COMPONENTS[:list].select { |c|
    c[:name] == parser.value('component') || parser.value('component') == '-'
}.each { |c|
    from = "#{dirname}/#{c[:name]}/config.rb"
    
    secret_folder = "#{dirname}/secret"
    to = "#{secret_folder}/config-#{c[:name]}.rb"
    
    l.logs "Copying #{from.blue} to #{to.blue}... "
    success = system("cp #{from} #{to} #{redirect}")
    l.done if success
    l.error if !success

    l.logs "Push #{to.blue} to secret repository... "
    success = system("cd #{secret_folder}; git add config-#{c[:name]}.rb #{redirect}; git commit -m 'Update config-#{c[:name]}.rb' #{redirect}; git push #{redirect}")
    l.done if success
    l.error if !success
}
