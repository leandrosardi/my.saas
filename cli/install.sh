# need a login shell for running rvm and ruby
# reference: https://stackoverflow.com/questions/9336596/rvm-installation-not-working-rvm-is-not-a-function
#
# If you connect via SSH, run this file using the following command:
# /bin/bash --login install.sh

# update packages
echo "update packages"
sudo apt -y update
sudo apt -y upgrade

# install other required packages
echo "install other required packages"
sudo apt install -y net-tools
sudo apt install -y gnupg2
sudo apt install -y nginx
sudo apt install -y sshpass
sudo apt install -y xterm
sudo apt install -y bc
sudo apt install -y unzip

# install cockroach CLI
echo "download cockroach CLI"
curl https://binaries.cockroachdb.com/cockroach-v21.2.10.linux-amd64.tgz | tar -xz && sudo cp cockroach-v21.2.10.linux-amd64/cockroach /usr/local/bin/;

# get private key for RVM
echo "get private key for RVM"
gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
# move into a writable location such as the /tmp to download RVM
# download RVM
echo "download rvm"
cd /tmp
curl -sSL https://get.rvm.io -o rvm.sh
# install the latest stable Rails version
echo "install rvm"
bash /tmp/rvm.sh
# install and run Ruby 3.1.2
echo "install Ruby 3.1.2"
~/.rvm/bin/rvm install 3.1.2
# set 3.1.2 as default Ruby version
echo "set 3.1.2 as default Ruby version"
rvm --default use 3.1.2
# check ruby installed
#ruby -v

# install git
echo "install git"
sudo apt install -y git
# install PostgreSQL dev package with header of PostgreSQL
echo "install PostgreSQL dev package with header of PostgreSQL"
sudo apt-get install -y libpq-dev
# install bundler
echo "install bundler"
gem install bundler -v '2.3.7'

# backup old .postgresql folder
echo "backup old .postgresql folder"
mv -p ~/.postgresql ~/.postgresql.$(date +%s) > /dev/null 2>&1
mkdir -p ~/.postgresql

# create the code directory
echo "create the code directory"
mkdir -p ~/code
cd ~/code
# rename existing ~/code/my.saas to ~/code/my.saas.<timestamp>
echo "backup existing ~/code/my.saas"
mv my.saas my.saas.$(date +%s)
# clone the my.saas repo
echo "clone the my.saas repo"
git clone https://github.com/leandrosardi/my.saas

# install gems
echo "install gems"
cd ~/code/my.saas
bundler update

# setup RUBYLIB environment variable
echo "setup RUBYLIB environment variable"
export RUBYLIB=~/code/my.saas

# copy .postgresql file 
# --> DEPRECATED (leandrosardi/cs#64)
#cp -p ~/code/my.saas/.postgresql/root.crt ~/.postgresql

# allow non-root user to run nginx and write the log files - error.log is written here
# --> DEPRECATED (leandrosardi/cs#64)
#sudo touch /var/log/nginx/access.log
#sudo touch /var/log/nginx/error.log
#sudo chmod ugo+rwx /var/log/nginx/access.log
#sudo chmod ugo+rwx /var/log/nginx/error.log
# allow non-root user to run nginx and write the log files - access.log & error.log are written here.
# --> DEPRECATED (leandrosardi/cs#64)
#sudo touch /usr/share/nginx/access.log
#sudo touch /usr/share/nginx/error.log
#sudo chmod ugo+rwx /usr/share/nginx/access.log
#sudo chmod ugo+rwx /usr/share/nginx/error.log
# allow non-root user to run nginx and write the log files - secure.access.log & secure.error.log are written here.
# --> DEPRECATED (leandrosardi/cs#64)
#sudo touch /usr/share/nginx/secure.access.log
#sudo touch /usr/share/nginx/secure.error.log
#sudo chmod ugo+rwx /usr/share/nginx/secure.access.log
#sudo chmod ugo+rwx /usr/share/nginx/secure.error.log
# allow non-root user to run nginx and write the pid files
# --> DEPRECATED (leandrosardi/cs#64)
#sudo touch /run/nginx.pid
#sudo chmod ugo+rwx /run/nginx.pid
# allow nginx to use ports < 1024, even when working as non-root user
# --> DEPRECATED (leandrosardi/cs#64)
#sudo setcap 'cap_net_bind_service=+ep' `which nginx`
# run nginx if you want to enable HTTPS
# --> DEPRECATED (leandrosardi/cs#64)
#nginx -c ~/code/my.saas/nginx/desa.conf > /dev/null 2>&1 &
# run sinatra webserver listening port 3000
# --> DEPRECATED (leandrosardi/cs#64)
#ruby app.rb port=3000 config=config.template env=desamv