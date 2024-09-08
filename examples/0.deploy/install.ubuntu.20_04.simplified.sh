# install.ubuntu.20_04.sh
# Description:
# - This script is used to install the required packages for the BlackStack project.
# Parameters:
# - $1: password for linux user blackstack, and postgres user blackstack either.
# - $2: hostname for the server.
#

# Set GTM-3 timezone
timedatectl set-timezone "America/Argentina/Buenos_Aires" 

# add user with password
useradd -p $(openssl passwd -1 "$2") blackstack -s /bin/bash -d /home/blackstack -m  

# add blackstack to sudoers
usermod -aG sudo blackstack 

# change hostname
hostname "$1" 

# edit /etc/ssh/sshd_config, enable the line "PasswordAuthentication yes"
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config 

# restart ssh service
service ssh restart 

# update packages
sudo apt -y update 
sudo apt -y upgrade 

# backup old .postgresql folder
sudo mv -p ~/.postgresql ~/.postgresql.$(date +%s)
sudo mkdir -p ~/.postgresql

# install PostgreSQL dev package with header of PostgreSQL
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

sudo apt install -y jq # install jq - required by the Zyte API
sudo apt install -y net-tools
sudo apt install -y gnupg2
sudo apt install -y nginx
sudo apt install -y sshpass
sudo apt install -y bc
sudo apt install -y unzip
sudo apt install -y curl
sudo apt-get -y install certbot

# install cockroach CLI for local development environments
curl https://binaries.cockroachdb.com/cockroach-v21.2.10.linux-amd64.tgz | tar -xz && sudo cp cockroach-v21.2.10.linux-amd64/cockroach /usr/local/bin/;

# install git
sudo apt install -y git

# get private key for RVM
gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

# move into a writable location such as the /tmp to download RVM
# download RVM
curl -sSL https://get.rvm.io -o rvm.sh

# install the latest stable Rails version
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
source /etc/profile.d/rvm.sh
type rvm | head -n 1 # if you read "rvm is a function, that means the installation is fine.

# fix: 
# Warning: can not check `/etc/sudoers` for `secure_path`, falling back to call via `/usr/bin/env`, this breaks rules from `/etc/sudoers`.
# Run `export rvmsudo_secure_path=1` to avoid the warning, put it in shell initialization to make it persistent.
export rvmsudo_secure_path=1

# install and run Ruby 3.1.2
# reference: https://superuser.com/questions/376669/why-am-i-getting-rvm-command-not-found-on-ubuntu
rvmsudo rvm install 3.1.2

# set 3.1.2 as default Ruby version
rvm --default use 3.1.2

# check ruby installed
ruby -v

# create the code directory
mkdir -p ~/code
cd ~/code

# Add the line 'deb http://archive.ubuntu.com/ubuntu focal-updates main' into '/etc/apt/sources.list'
# Reference: 
echo "deb http://archive.ubuntu.com/ubuntu focal-updates main" | sudo tee -a /etc/apt/sources.list
sudo apt update

# Install AdsPower
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
sudo apt-get update
sudo apt-get install -y xvfb

# allow adspower browsers and any other process to execute `downloadImage` javascript function.
sudo chmod 777 /home/blackstack/Downloads
sudo chmod 777 /home/blackstack/.config/adspower_global/cwd_global

# write a flag in the file /home/blackstack/.blackstack
touch /home/blackstack/.blackstack

