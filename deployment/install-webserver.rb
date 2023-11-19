# setup deploying rutines
BlackStack::Deployer::add_routine({
  :name => 'install-webserver',
  :commands => [{
    :command => '
      # remove old code folder
      rmdir -rf ~/code/app >>~/connectionsphere.app.output 2>&1

      # create code folder
      mkdir -p ~/code >>~/connectionsphere.app.output 2>&1
      mkdir -p ~/code/app >>~/connectionsphere.app.output 2>&1

      # clone the project
      git clone https://%git_username%:%git_password%@github.com/connectionsphere/app ~/code/app >>~/connectionsphere.app.output 2>&1

      # pull the last version of the source code
      cd ~/code/app
      git config --global credential.helper store >>~/connectionsphere.app.output 2>&1
      git fetch --all >>~/connectionsphere.app.output 2>&1
      git reset --hard origin/%git_branch% >>~/connectionsphere.app.output 2>&1

      # pull the last version of the source code
      git config --global credential.helper store >>~/connectionsphere.app.output 2>&1
      git fetch --all >>~/connectionsphere.app.output 2>&1
      git reset --hard origin/%git_branch% >>~/connectionsphere.app.output 2>&1

      # update extension i2p
      cd ~/code/app/extensions >>~/connectionsphere.app.output 2>&1
      git clone https://github.com/leandrosardi/i2p ~/code/app/extensions/i2p >>~/connectionsphere.app.output 2>&1
      git config --global credential.helper store >>~/connectionsphere.app.output 2>&1
      cd ~/code/app/extensions/i2p >>~/connectionsphere.app.output 2>&1
      git fetch --all >>~/connectionsphere.app.output 2>&1
      git reset --hard origin/master >>~/connectionsphere.app.output 2>&1

      # update extension monitoring
      cd ~/code/app/extensions >>~/connectionsphere.app.output 2>&1
      git clone https://github.com/leandrosardi/monitoring ~/code/app/extensions/monitoring >>~/connectionsphere.app.output 2>&1
      git config --global credential.helper store >>~/connectionsphere.app.output 2>&1
      cd ~/code/app/extensions/monitoring >>~/connectionsphere.app.output 2>&1
      git fetch --all >>~/connectionsphere.app.output 2>&1
      git reset --hard origin/main >>~/connectionsphere.app.output 2>&1

      # update extension content
      cd ~/code/app/extensions >>~/connectionsphere.app.output 2>&1
      git clone https://github.com/leandrosardi/content ~/code/app/extensions/content >>~/connectionsphere.app.output 2>&1
      git config --global credential.helper store >>~/connectionsphere.app.output 2>&1
      cd ~/code/app/extensions/content >>~/connectionsphere.app.output 2>&1
      git fetch --all >>~/connectionsphere.app.output 2>&1
      git reset --hard origin/main >>~/connectionsphere.app.output 2>&1

      # update extension selectrowsjs
      cd ~/code/app/extensions >>~/connectionsphere.app.output 2>&1
      git clone https://github.com/leandrosardi/selectrowsjs ~/code/app/extensions/selectrowsjs >>~/connectionsphere.app.output 2>&1
      git config --global credential.helper store >>~/connectionsphere.app.output 2>&1
      cd ~/code/app/extensions/selectrowsjs >>~/connectionsphere.app.output 2>&1
      git fetch --all >>~/connectionsphere.app.output 2>&1
      git reset --hard origin/main >>~/connectionsphere.app.output 2>&1

      # update extension filtersjs
      cd ~/code/app/extensions >>~/connectionsphere.app.output 2>&1
      git clone https://github.com/leandrosardi/filtersjs ~/code/app/extensions/filtersjs >>~/connectionsphere.app.output 2>&1
      git config --global credential.helper store >>~/connectionsphere.app.output 2>&1
      cd ~/code/app/extensions/filtersjs >>~/connectionsphere.app.output 2>&1
      git fetch --all >>~/connectionsphere.app.output 2>&1
      git reset --hard origin/main >>~/connectionsphere.app.output 2>&1

      # update extension templatesjs
      cd ~/code/app/extensions >>~/connectionsphere.app.output 2>&1
      git clone https://github.com/leandrosardi/templatesjs ~/code/app/extensions/templatesjs >>~/connectionsphere.app.output 2>&1
      git config --global credential.helper store >>~/connectionsphere.app.output 2>&1
      cd ~/code/app/extensions/templatesjs >>~/connectionsphere.app.output 2>&1
      git fetch --all >>~/connectionsphere.app.output 2>&1
      git reset --hard origin/main >>~/connectionsphere.app.output 2>&1

      # upload configuration file
      cd ~/code/app >>~/connectionsphere.app.output 2>&1
      [ -f ./config.rb ] && mv ./config.rb ./config.%timestamp%.rb >>~/connectionsphere.app.output 2>&1
      echo "%config_rb_content%" > ./config.rb

      # update gems
      #cd ~/code/app >>~/connectionsphere.app.output 2>&1
      #bundler update >>~/connectionsphere.app.output 2>&1
    ',
  }],
});