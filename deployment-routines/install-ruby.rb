# setup deploying rutines
BlackStack::Deployer::add_routine({
  :name => 'install-ruby',
  :commands => [
    { 
        :command => '
            cd /tmp; 
            curl -sSL https://get.rvm.io -o rvm.sh;
        ', 
        :nomatches => [ # no output means success.
            { :nomatch => /.+/i, :error_description => 'An Error Occurred' },
        ],
        :sudo => false,
    }, { 
        :command => "
            gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB;
            cat /tmp/rvm.sh | bash -s stable --rails;", 
        :matches => [/(\d)+ gems installed/i, /1 gem installed/i, /Good signature from/i, /Successfully installed/i],
        :nomatches => [ 
            { :nomatch => /error/i, :error_description => 'An Error Occurred' },
        ],
        :sudo => false,
    }, { 
        # reference: https://askubuntu.com/questions/504546/error-message-source-not-found-when-running-a-script
        :command => "source /home/%ssh_username%/.rvm/scripts/rvm; rvm install 3.1.2; rvm --default use 3.1.2;", 
        :matches => [ /Already installed/i,  /installed/i, /generating default wrappers/i ],
        :sudo => false,    

    # TODO: Add validation the ruby 3.1.2 has been installed for the user %ssh_username%.

=begin
    # bundler already installed with Ruby 3.1.2
    }, { 
        # reference: https://askubuntu.com/questions/504546/error-message-source-not-found-when-running-a-script
        :command => "echo 'SantaClara123' | sudo -S su %ssh_username% -c '#!/bin/bash; gem install bundler -v '2.3.7';'", 
        :nomatches => [ # no output means success.
            { :nomatch => /.+/i, :error_description => 'An Error Occurred' },
        ],
        :sudo => true,    
=end
    },
  ],
});