require 'mysaas'
# 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command will launch a Sinatra-based BlackStack webserver.', 
  :configuration => [{
    :name=>'config', 
    :mandatory=>false, 
    :description=>'Name of the configuration file. Default is config.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => 'config',
  }, {
    :name=>'env', 
    :mandatory=>false, 
    :description=>'Name of the environment (desa, prod). Default is prod.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => 'prod',
  }]
)
# get the path of the current executing file.
path = "#{File.expand_path(File.dirname(__FILE__))}/.."
# setup RUBYLIB environment variable
`export RUBYLIB=#{path}`
# allow non-root user to run nginx and write the log files - error.log is written here
`sudo touch /var/log/nginx/access.log`
`sudo touch /var/log/nginx/error.log`
`sudo chmod ugo+rwx /var/log/nginx/access.log`
`sudo chmod ugo+rwx /var/log/nginx/error.log`
# allow non-root user to run nginx and write the log files - access.log & error.log are written here.
`sudo touch /usr/share/nginx/access.log`
`sudo touch /usr/share/nginx/error.log`
`sudo chmod ugo+rwx /usr/share/nginx/access.log`
`sudo chmod ugo+rwx /usr/share/nginx/error.log`
# allow non-root user to run nginx and write the log files - secure.access.log & secure.error.log are written here.
`sudo touch /usr/share/nginx/secure.access.log`
`sudo touch /usr/share/nginx/secure.error.log`
`sudo chmod ugo+rwx /usr/share/nginx/secure.access.log`
`sudo chmod ugo+rwx /usr/share/nginx/secure.error.log`
# allow non-root user to run nginx and write the pid files
`sudo touch /run/nginx.pid`
`sudo chmod ugo+rwx /run/nginx.pid`
# run nginx if you want to enable HTTPS
`nginx -c #{path}/nginx/#{parser.value('env')}.conf`
# run sinatra webserver listening port 3000
`cd #{path}/; ruby app.rb port=3000 config=#{parser.value('config')}`
