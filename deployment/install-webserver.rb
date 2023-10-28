# setup deploying rutines
BlackStack::Deployer::add_routine({
  :name => 'install-webserver',
  :commands => [{
    :command => '
      # create code folder
      mkdir -p ~/code >>~/freeleadsdata.app.output 2>&1
      mkdir -p ~/code/freeleadsdata >>~/freeleadsdata.app.output 2>&1

      # clone the project
      git clone https://%git_username%:%git_password%@github.com/freeleadsdata/app ~/code/freeleadsdata/app >>~/freeleadsdata.app.output 2>&1
      git clone https://%git_username%:%git_password%@github.com/freeleadsdata/model ~/code/freeleadsdata/model >>~/freeleadsdata.app.output 2>&1

      # pull the last version of the source code
      cd ~/code/freeleadsdata/app
      git config --global credential.helper store >>~/freeleadsdata.app.output 2>&1
      git fetch --all >>~/freeleadsdata.app.output 2>&1
      git reset --hard origin/%git_branch% >>~/freeleadsdata.app.output 2>&1

      # pull the last version of the source code
      cd ~/code/freeleadsdata/model >>~/freeleadsdata.app.output 2>&1
      git config --global credential.helper store >>~/freeleadsdata.app.output 2>&1
      git fetch --all >>~/freeleadsdata.app.output 2>&1
      git reset --hard origin/%git_branch% >>~/freeleadsdata.app.output 2>&1

      # update extension i2p
      cd ~/code/freeleadsdata/app/extensions >>~/freeleadsdata.app.output 2>&1
      git clone https://github.com/leandrosardi/i2p ~/code/freeleadsdata/app/extensions/i2p >>~/freeleadsdata.app.output 2>&1
      git config --global credential.helper store >>~/freeleadsdata.app.output 2>&1
      cd ~/code/freeleadsdata/app/extensions/i2p >>~/freeleadsdata.app.output 2>&1
      git fetch --all >>~/freeleadsdata.app.output 2>&1
      git reset --hard origin/master >>~/freeleadsdata.app.output 2>&1

      # update extension monitoring
      cd ~/code/freeleadsdata/app/extensions >>~/freeleadsdata.app.output 2>&1
      git clone https://github.com/leandrosardi/monitoring ~/code/freeleadsdata/app/extensions/monitoring >>~/freeleadsdata.app.output 2>&1
      git config --global credential.helper store >>~/freeleadsdata.app.output 2>&1
      cd ~/code/freeleadsdata/app/extensions/monitoring >>~/freeleadsdata.app.output 2>&1
      git fetch --all >>~/freeleadsdata.app.output 2>&1
      git reset --hard origin/main >>~/freeleadsdata.app.output 2>&1

      # update extension content
      cd ~/code/freeleadsdata/app/extensions >>~/freeleadsdata.app.output 2>&1
      git clone https://github.com/leandrosardi/content ~/code/freeleadsdata/app/extensions/content >>~/freeleadsdata.app.output 2>&1
      git config --global credential.helper store >>~/freeleadsdata.app.output 2>&1
      cd ~/code/freeleadsdata/app/extensions/content >>~/freeleadsdata.app.output 2>&1
      git fetch --all >>~/freeleadsdata.app.output 2>&1
      git reset --hard origin/main >>~/freeleadsdata.app.output 2>&1

      # update extension selectrowsjs
      cd ~/code/freeleadsdata/app/extensions >>~/freeleadsdata.app.output 2>&1
      git clone https://github.com/leandrosardi/selectrowsjs ~/code/freeleadsdata/app/extensions/selectrowsjs >>~/freeleadsdata.app.output 2>&1
      git config --global credential.helper store >>~/freeleadsdata.app.output 2>&1
      cd ~/code/freeleadsdata/app/extensions/selectrowsjs >>~/freeleadsdata.app.output 2>&1
      git fetch --all >>~/freeleadsdata.app.output 2>&1
      git reset --hard origin/main >>~/freeleadsdata.app.output 2>&1

      # update extension filtersjs
      cd ~/code/freeleadsdata/app/extensions >>~/freeleadsdata.app.output 2>&1
      git clone https://github.com/leandrosardi/filtersjs ~/code/freeleadsdata/app/extensions/filtersjs >>~/freeleadsdata.app.output 2>&1
      git config --global credential.helper store >>~/freeleadsdata.app.output 2>&1
      cd ~/code/freeleadsdata/app/extensions/filtersjs >>~/freeleadsdata.app.output 2>&1
      git fetch --all >>~/freeleadsdata.app.output 2>&1
      git reset --hard origin/main >>~/freeleadsdata.app.output 2>&1

      # update extension templatesjs
      cd ~/code/freeleadsdata/app/extensions >>~/freeleadsdata.app.output 2>&1
      git clone https://github.com/leandrosardi/templatesjs ~/code/freeleadsdata/app/extensions/templatesjs >>~/freeleadsdata.app.output 2>&1
      git config --global credential.helper store >>~/freeleadsdata.app.output 2>&1
      cd ~/code/freeleadsdata/app/extensions/templatesjs >>~/freeleadsdata.app.output 2>&1
      git fetch --all >>~/freeleadsdata.app.output 2>&1
      git reset --hard origin/main >>~/freeleadsdata.app.output 2>&1

      # upload configuration file
      cd ~/code/freeleadsdata/app >>~/freeleadsdata.app.output 2>&1
      [ -f ./config.rb ] && mv ./config.rb ./config.%timestamp%.rb >>~/freeleadsdata.app.output 2>&1
      echo "%config_rb_content%" > ./config.rb

      # update gems
      #cd ~/code/freeleadsdata/app >>~/freeleadsdata.app.output 2>&1
      #bundler update >>~/freeleadsdata.app.output 2>&1
    ',
  }],
});