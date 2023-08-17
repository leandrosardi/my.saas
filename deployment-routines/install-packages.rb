# setup deploying rutines
BlackStack::Deployer::add_routine({
  :name => 'install-packages',
  :commands => [
    { 
        :command => 'apt install -y net-tools;', 
        :matches => [/(\d)+ upgraded, (\d)+ newly installed, (\d)+ to remove and (\d)+ not upgraded/i], 
        :nomatches => [
            { :nomatch => /Unable to locate package/, :error_description => 'Unable to locate package' }, 
            { :nomatch => /^E: /i, :error_description => 'An Error Occurred' },
        ],
        :sudo => true,
    }, { 
        :command => 'apt install -y gnupg2;', 
        :matches => [/(\d)+ upgraded, (\d)+ newly installed, (\d)+ to remove and (\d)+ not upgraded/i], 
        :nomatches => [
            { :nomatch => /Unable to locate package/, :error_description => 'Unable to locate package' }, 
            { :nomatch => /^E: /i, :error_description => 'An Error Occurred' },
        ],
        :sudo => true,
    }, { 
        :command => 'apt install -y git;', 
        :matches => [/(\d)+ upgraded, (\d)+ newly installed, (\d)+ to remove and (\d)+ not upgraded/i], 
        :nomatches => [
            { :nomatch => /Unable to locate package/, :error_description => 'Unable to locate package' }, 
            { :nomatch => /^E: /i, :error_description => 'An Error Occurred' },
        ],
        :sudo => true,
    }, { 
        :command => 'apt install -y libpq-dev;', 
        :matches => [/(\d)+ upgraded, (\d)+ newly installed, (\d)+ to remove and (\d)+ not upgraded/i], 
        :nomatches => [
            { :nomatch => /Unable to locate package/, :error_description => 'Unable to locate package' }, 
            { :nomatch => /^E: /i, :error_description => 'An Error Occurred' },
        ],
        :sudo => true,  
    }, { 
        # this is used by the BlackStack::BackUp module.
        :command => 'apt install -y zip;', 
        :matches => [/(\d)+ upgraded, (\d)+ newly installed, (\d)+ to remove and (\d)+ not upgraded/i], 
        :nomatches => [
            { :nomatch => /Unable to locate package/, :error_description => 'Unable to locate package' }, 
            { :nomatch => /^E: /i, :error_description => 'An Error Occurred' },
        ],
        :sudo => true,    
    }, { 
        # this is used over sinatra to process SSL requests.
        :command => 'apt install -y nginx;', 
        :matches => [/(\d)+ upgraded, (\d)+ newly installed, (\d)+ to remove and (\d)+ not upgraded/i], 
        :nomatches => [
            { :nomatch => /Unable to locate package/, :error_description => 'Unable to locate package' }, 
            { :nomatch => /^E: /i, :error_description => 'An Error Occurred' },
        ],
        :sudo => true,  
    },
  ],
});