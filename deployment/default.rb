# setup deploying rutines
BlackStack::Deployer::add_routine({
  :name => 'default',
  :commands => [{
    :command => '
      echo "" >>'+OUTPUT_FILE+' 2>&1
      echo "-------------------------------------------------------------------------" >>'+OUTPUT_FILE+' 2>&1
      echo "Updating Source Code at: `date`" >>'+OUTPUT_FILE+' 2>&1

      # Activate RVM
      echo "" >>'+OUTPUT_FILE+' 2>&1
      echo "Activating RVM..." >>'+OUTPUT_FILE+' 2>&1      
      source /etc/profile.d/rvm.sh >>'+OUTPUT_FILE+' 2>&1

      # Activate Ruby 3.1.2
      echo "" >>'+OUTPUT_FILE+' 2>&1
      echo "Activate Ruby 3.1.2..." >>'+OUTPUT_FILE+' 2>&1      
      rvm --default use 3.1.2

      # create code folder
      echo "" >>'+OUTPUT_FILE+' 2>&1
      echo "Creating code folder..." >>'+OUTPUT_FILE+' 2>&1
      mkdir -p ~/code >>'+OUTPUT_FILE+' 2>&1

      # backup old code folder
      # TODO: activate this if you want to backup the code folder.
      #echo "" >>'+OUTPUT_FILE+' 2>&1
      #echo "Backup old code folder..." >>'+OUTPUT_FILE+' 2>&1
      #[ -d ~/code/%code_folder% ] && mv ~/code/%code_folder% ~/code/%code_folder%.%timestamp% >>'+OUTPUT_FILE+' 2>&1

      # clone the project
      echo "" >>'+OUTPUT_FILE+' 2>&1
      echo "Cloning the project..." >>'+OUTPUT_FILE+' 2>&1
      git clone https://%git_username%:%git_password%@github.com/%git_repository% ~/code/%code_folder% >>'+OUTPUT_FILE+' 2>&1

      # pull the last version of the source code
      echo "" >>'+OUTPUT_FILE+' 2>&1
      echo "Pulling the last version of the source code..." >>'+OUTPUT_FILE+' 2>&1
      cd ~/code/%code_folder%
      git config --global credential.helper store >>'+OUTPUT_FILE+' 2>&1
      git fetch --all >>'+OUTPUT_FILE+' 2>&1
      git reset --hard origin/%git_branch% >>'+OUTPUT_FILE+' 2>&1

      # upload configuration file
      # TODO: activate the mv command if you want to backup the configuration file.
      echo "" >>'+OUTPUT_FILE+' 2>&1
      echo "Uploading configuration file..." >>'+OUTPUT_FILE+' 2>&1
      cd ~/code/%code_folder% >>'+OUTPUT_FILE+' 2>&1
      #[ -f ./config.rb ] && mv ./config.rb ./config.%timestamp%.rb >>'+OUTPUT_FILE+' 2>&1 
      echo "%config_rb_content%" > ./config.rb 
      
      # update gems
      echo "" >>'+OUTPUT_FILE+' 2>&1
      echo "Updating gems..." >>'+OUTPUT_FILE+' 2>&1
      cd ~/code/%code_folder% >>'+OUTPUT_FILE+' 2>&1
      bundler update >>'+OUTPUT_FILE+' 2>&1
    ',
  }],
});