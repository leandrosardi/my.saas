# update packages
sudo apt -y update
sudo apt -y upgrade
# install other required packages
sudo apt install -y net-tools
sudo apt install -y gnupg2
sudo apt install -y nginx
sudo apt install -y sshpass
sudo apt install -y xterm
sudo apt install -y bc
sudo apt install -y unzip
# install cockroach CLI
curl https://binaries.cockroachdb.com/cockroach-v21.2.10.linux-amd64.tgz | tar -xz && sudo cp -i cockroach-v21.2.10.linux-amd64/cockroach /usr/local/bin/;
# get private key for RVM
gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
# move into a writable location such as the /tmp to download RVM
cd /tmp
# download RVM
curl -sSL https://get.rvm.io -o rvm.sh
# install the latest stable Rails version
cat /tmp/rvm.sh | bash -s stable --rails
# start RVM
source /usr/local/rvm/scripts/rvm
# install and run Ruby 3.1.2
rvm install 3.1.2
rvm --default use 3.1.2
ruby -v
# install git
sudo apt install -y git
# install PostgreSQL dev package with header of PostgreSQL
sudo apt-get install -y libpq-dev
# install bundler
gem install bundler -v '2.3.7'
# backup old .postgresql folder
mv -p ~/.postgresql ~/.postgresql.$(date +%s) > /dev/null 2>&1
mkdir -p ~/.postgresql
# create the code directory
mkdir -p ~/code
cd ~/code
# rename existing ~/code/mysaas to ~/code/mysaas.<timestamp>
mv mysaas mysaas.$(date +%s)
# clone the mysaas repo
git clone https://github.com/leandrosardi/mysaas
cd ~/code/mysaas
# install gems
bundler update
# setup RUBYLIB environment variable
export RUBYLIB=~/code/mysaas
# copy .postgresql file 
# --> DEPRECATED (leandrosardi/cs#64)
cp -p ~/code/mysaas/.postgresql/root.crt ~/.postgresql
# allow non-root user to run nginx and write the log files - error.log is written here
# --> DEPRECATED (leandrosardi/cs#64)
sudo touch /var/log/nginx/access.log
sudo touch /var/log/nginx/error.log
sudo chmod ugo+rwx /var/log/nginx/access.log
sudo chmod ugo+rwx /var/log/nginx/error.log
# allow non-root user to run nginx and write the log files - access.log & error.log are written here.
# --> DEPRECATED (leandrosardi/cs#64)
sudo touch /usr/share/nginx/access.log
sudo touch /usr/share/nginx/error.log
sudo chmod ugo+rwx /usr/share/nginx/access.log
sudo chmod ugo+rwx /usr/share/nginx/error.log
# allow non-root user to run nginx and write the log files - secure.access.log & secure.error.log are written here.
# --> DEPRECATED (leandrosardi/cs#64)
sudo touch /usr/share/nginx/secure.access.log
sudo touch /usr/share/nginx/secure.error.log
sudo chmod ugo+rwx /usr/share/nginx/secure.access.log
sudo chmod ugo+rwx /usr/share/nginx/secure.error.log
# allow non-root user to run nginx and write the pid files
# --> DEPRECATED (leandrosardi/cs#64)
sudo touch /run/nginx.pid
sudo chmod ugo+rwx /run/nginx.pid
# allow nginx to use ports < 1024, even when working as non-root user
# --> DEPRECATED (leandrosardi/cs#64)
sudo setcap 'cap_net_bind_service=+ep' `which nginx`
# run nginx if you want to enable HTTPS
# --> DEPRECATED (leandrosardi/cs#64)
#nginx -c ~/code/mysaas/nginx/desa.conf > /dev/null 2>&1 &
# run sinatra webserver listening port 3000
# --> DEPRECATED (leandrosardi/cs#64)
#ruby app.rb port=3000 config=config.template env=desa