# setup deploying rutines
BlackStack::Deployer::add_routine({
  :name => 'upgrade-packages',
  :commands => [
    { 
        :command => 'apt update;', 
        :matches => [/packages can be upgraded/i, /All packages are up to date/i], 
        :nomatches => [{ :nomatch => /error/, :error_description => 'An Error Occurred' }] 
    }, { 
        :command => 'apt -y upgrade;', 
        :matches => [/done/, /(\d)+ upgraded, (\d)+ newly installed, (\d)+ to remove and (\d)+ not upgraded/i], 
        :nomatches => [{ :nomatch => /error/, :error_description => 'An Error Occurred' }] 
    },
  ],
});
