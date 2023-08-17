# get the path of the current executing file.
path = "#{File.expand_path(File.dirname(__FILE__))}/.."
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
`sudo kill -9 $(ps aux | grep nginx | grep -v grep | awk '{print $2}')`
# run sinatra webserver listening port 3000
`sudo kill -9 $(ps aux | grep puma | grep -v grep | awk '{print $2}')`
