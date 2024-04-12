# setup deploying rutines
BlackStack::Deployer::add_routine({
  :name => 'extension',
  :commands => [{
    :command => '
      echo "" >>'+OUTPUT_FILE+' 2>&1
      echo "-------------------------------------------------------------------------" >>'+OUTPUT_FILE+' 2>&1
      echo "Updating Extension %extension_name% at: `date`" >>'+OUTPUT_FILE+' 2>&1

      echo "" >>'+OUTPUT_FILE+' 2>&1
      echo "Creating exension folder..." >>'+OUTPUT_FILE+' 2>&1
      mkdir ~/code/%code_folder%/extensions/%extension_name% >>'+OUTPUT_FILE+' 2>&1

      # backup old code folder
      #echo "" >>'+OUTPUT_FILE+' 2>&1
      #echo "Backup old code folder..." >>'+OUTPUT_FILE+' 2>&1
      #[ -d ~/code/%code_folder%/extensions/%extension_name% ] && mv ~/code/%code_folder%/extensions/%extension_name% ~/code/%code_folder%/extensions/%extension_name%.%timestamp% >>'+OUTPUT_FILE+' 2>&1

      # clone the project
      echo "" >>'+OUTPUT_FILE+' 2>&1
      echo "Cloning the project..." >>'+OUTPUT_FILE+' 2>&1
      git clone %repo_url% ~/code/%code_folder%/extensions/%extension_name% >>'+OUTPUT_FILE+' 2>&1

      # pull the last version of the source code
      echo "" >>'+OUTPUT_FILE+' 2>&1
      echo "Pulling the last version of the source code..." >>'+OUTPUT_FILE+' 2>&1
      cd ~/code/%code_folder%/extensions/%extension_name%
      git config --global credential.helper store >>'+OUTPUT_FILE+' 2>&1
      git fetch --all >>'+OUTPUT_FILE+' 2>&1
      git reset --hard origin/%repo_branch% >>'+OUTPUT_FILE+' 2>&1
    ',
  }],
});

