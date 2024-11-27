#!/bin/bash

# Load RVM into a shell session
source /etc/profile.d/rvm.sh

# Use the default Ruby version
rvm --default use 3.1.2

# Set the RUBYLIB environment variable
export RUBYLIB=/home/!!ssh_username/code1/!!code_folder

# Change to the application directory
cd /home/!!ssh_username/code1/!!code_folder

# Execute the Ruby application
exec ruby app.rb port=!!port