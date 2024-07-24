# install.ubuntu.20_04.sh
# Description:
# - This script is used to install the required packages for the BlackStack project.
# Parameters:
# - $1: password for linux user blackstack, and postgres user blackstack either.
# - $2: hostname for the server.
#

# remember to run this script with sudo 
echo 
echo "HOLA!"

# raise exception of $1 is empty
if [ -z "$1" ]
then
    echo "Parameter \$1 is empty"
    exit 1
fi

# raise exception of $2 is empty
if [ -z "$2" ]
then
    echo "Parameter \$2 is empty"
    exit 1
fi

echo "Hostname: $1"
echo "Password: $2"

# Set GTM-3 timezone
echo
echo "Set GTM-3 timezone"
timedatectl set-timezone "America/Argentina/Buenos_Aires" > /dev/null 2>&1 

# add user with password
echo
echo "Add user blackstack with password ***"
useradd -p $(openssl passwd -1 "$2") blackstack -s /bin/bash -d /home/blackstack -m > /dev/null 2>&1  

# add blackstack to sudoers
echo
echo "Add blackstack to sudoers"
usermod -aG sudo blackstack > /dev/null 2>&1 

# change hostname
echo
echo "Change hostname"
hostname "$1" > /dev/null 2>&1 

# edit /etc/ssh/sshd_config, enable the line "PasswordAuthentication yes"
echo
echo "Edit /etc/ssh/sshd_config, enable the line PasswordAuthentication yes"
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config > /dev/null 2>&1 

# restart ssh service
echo
echo "Restart ssh service"
service ssh restart > /dev/null 2>&1 

# update packages
echo
echo "update packages"
sudo apt -y update > /dev/null 2>&1 
sudo apt -y upgrade > /dev/null 2>&1 

# backup old .postgresql folder
echo
echo "backup old .postgresql folder"
sudo mv -p ~/.postgresql ~/.postgresql.$(date +%s) > /dev/null 2>&1
sudo mkdir -p ~/.postgresql

# install PostgreSQL dev package with header of PostgreSQL
echo
echo "install PostgreSQL dev package with header of PostgreSQL"
sudo apt-get install -y libpq-dev
sudo apt install -y postgresql-12 postgresql-contrib
sudo systemctl start postgresql.service
#sudo systemctl status postgresql

# edit /etc/postgresql/12/main/postgresql.sql: uncomment the line starting listen_addresses and set the velue listen_addresses='*'
sudo sed -i 's/#listen_addresses/listen_addresses/g' /etc/postgresql/12/main/postgresql.conf
sudo sed -i "s/listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/12/main/postgresql.conf
# grant edition rights to the user blackstack
sudo chmod 777 /etc/postgresql/12/main/pg_hba.conf
# edit /etc/postgresql/12/main/pg_hba.conf: add the line host all all
sudo echo "host all all 0.0.0.0/0   md5" >> /etc/postgresql/12/main/pg_hba.conf
# restart postgresql
sudo systemctl restart postgresql.service
# create postgresql user
sudo -u postgres createuser -s -i -d -r -l -w blackstack
# assign password to the user blackstack
sudo -u postgres psql -c "ALTER ROLE blackstack WITH PASSWORD '$2';"
# create new database called blackstack and owned by the user blackstack
sudo -u postgres createdb -O blackstack blackstack

echo
echo "install required packages"
sudo apt install -y jq # install jq - required by the Zyte API
sudo apt install -y net-tools
sudo apt install -y gnupg2
sudo apt install -y nginx
sudo apt install -y sshpass
sudo apt install -y bc
sudo apt install -y unzip
sudo apt install -y curl

# install cockroach CLI for local development environments
echo
echo "download cockroach CLI"
curl https://binaries.cockroachdb.com/cockroach-v21.2.10.linux-amd64.tgz | tar -xz && sudo cp cockroach-v21.2.10.linux-amd64/cockroach /usr/local/bin/;

# install bundler
#echo
#echo "install bundler"
#gem install bundler -v '2.3.7'

# Install Google Chrome
# Reference:
# - https://skolo.online/documents/webscrapping/#step-1-download-chrome
#
#echo
#echo "install chrome"
#wget http://mirror.cs.uchicago.edu/google-chrome/pool/main/g/google-chrome-stable/google-chrome-stable_114.0.5735.90-1_amd64.deb
#sudo dpkg -i google-chrome-stable_114.0.5735.90-1_amd64.deb
#sudo apt-get install -fy
#google-chrome --version

# Install Chrome Driver
# Reference:
# - https://stackoverflow.com/questions/50642308/webdriverexception-unk
#
#echo
#echo "install chrome-driver"
#wget https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip
#unzip chromedriver_linux64.zip
#sudo mv chromedriver /usr/bin/chromedriver
#sudo chown blackstack:blackstack /usr/bin/chromedriver
#sudo chmod +x /usr/bin/chromedriver

# install git
echo
echo "install git"
sudo apt install -y git

# get private key for RVM
echo
echo "get private key for RVM"
gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

# move into a writable location such as the /tmp to download RVM
# download RVM
echo
echo "download rvm"
curl -sSL https://get.rvm.io -o rvm.sh

# install the latest stable Rails version
echo
echo "install rvm"
sudo bash rvm.sh

# First you need to add all users that will be using rvm to 'rvm' group,
# and logout - login again, anyone using rvm will be operating with `umask u=rwx,g=rwx,o=rx`.
#
# reference: https://unix.stackexchange.com/questions/102678/making-ruby-available-to-all-users
#
sudo usermod -a -G rvm blackstack

# To start using RVM you need to run `source /etc/profile.d/rvm.sh` in all your open shell windows,
# Fix the issue "RVM is not a function"
# reference: https://stackoverflow.com/questions/9336596/rvm-installation-not-working-rvm-is-not-a-function
echo
echo "Run RVM script"
source /etc/profile.d/rvm.sh
type rvm | head -n 1 # if you read "rvm is a function, that means the installation is fine.

# fix: 
# Warning: can not check `/etc/sudoers` for `secure_path`, falling back to call via `/usr/bin/env`, this breaks rules from `/etc/sudoers`.
# Run `export rvmsudo_secure_path=1` to avoid the warning, put it in shell initialization to make it persistent.
export rvmsudo_secure_path=1

# install and run Ruby 3.1.2
# reference: https://superuser.com/questions/376669/why-am-i-getting-rvm-command-not-found-on-ubuntu
echo
echo "install Ruby 3.1.2"
rvmsudo rvm install 3.1.2

# set 3.1.2 as default Ruby version
echo
echo "set 3.1.2 as default Ruby version"
rvm --default use 3.1.2

# check ruby installed
echo
echo "Try Ruby"
ruby -v

# fix: why need to define source to RVM every time
# references: 
# - https://stackoverflow.com/questions/22917453/why-need-to-define-source-to-rvm-every-time
# - https://stackoverflow.com/questions/4842566/rvm-command-source-rvm-scripts-rvm?rq=1 
# 
#echo
#echo "Source RVM on login"
#echo "source /etc/profile.d/rvm.sh" >> ~/.bashrc
#echo "rvm --default use 3.1.2" >> ~/.bashrc

# create the code directory
echo
echo "create the code directory"
mkdir -p ~/code
cd ~/code

# Add the line 'deb http://archive.ubuntu.com/ubuntu focal-updates main' into '/etc/apt/sources.list'
# Reference: 
echo "deb http://archive.ubuntu.com/ubuntu focal-updates main" | sudo tee -a /etc/apt/sources.list
sudo apt update

# Install AdsPower
echo
echo "install AdsPower"
cd ~
sudo wget https://version.adspower.net/software/linux-x64-global/AdsPower-Global-5.9.14-x64.deb
sudo chmod 777 AdsPower-Global-5.9.14-x64.deb
sudo dpkg -i AdsPower-Global-5.9.14-x64.deb
sudo apt install -y ./AdsPower-Global-5.9.14-x64.deb

# Fix broken packages in case that AdsPower installation failed.
sudo apt -y --fix-broken install

# Remove AdsPower installer
sudo rm -rf ./AdsPower-Global-5.9.14-x64.deb

# Install Chrome Driver
# Reference:
# - https://stackoverflow.com/questions/50642308/webdriverexception-unk
#
echo
echo "install chrome-driver"
cd ~
sudo wget https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/116.0.5845.96/linux64/chromedriver-linux64.zip
sudo chmod 777 chromedriver-linux64.zip
unzip chromedriver-linux64.zip
sudo mv chromedriver-linux64/* /usr/bin
sudo chown blackstack:blackstack /usr/bin/chromedriver
sudo chmod +x /usr/bin/chromedriver
sudo rm -rf ./chromedriver-linux64.zip
sudo rm -rf ./chromedriver-linux64

# AdsPower requires access to a graphical environment 
# We need an X server or a similar display server running. 
# AdsPower will try to use GTK, a graphical toolkit, which in turn needs an active display connection that is not present in a headless setup.
echo 
echo "install xvfb"
sudo apt-get update
sudo apt-get install -y xvfb

# write a flag in the file /home/blackstack/.blackstack
echo
echo "write a flag in the file /home/blackstack/.blackstack"
touch /home/blackstack/.blackstack

echo ''
echo 'BYE!'
exit 0
