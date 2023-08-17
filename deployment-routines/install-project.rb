# setup deploying rutines
BlackStack::Deployer::add_routine({
  :name => 'install-project',
  :commands => [
    { 
        :command => 'mkdir ~/code;',
        :matches => [ /^$/i, /File exists/i ],
        :sudo => false,
    }, { 
        :command => 'cd ~/code; git clone %git_project_url%;',
        :matches => [ 
            /already exists and is not an empty directory/i,
            /Cloning into/i,
            /Resolving deltas\: 100\% \((\d)+\/(\d)+\), done\./i,
            /fatal\: destination path \'.+\' already exists and is not an empty directory\./i,
        ],
        :nomatches => [ # no output means success.
            { :nomatch => /error/i, :error_description => 'An Error Occurred' },
        ],
        :sudo => false,
    }, { 
        :command => '
            source /home/%ssh_username%/.rvm/scripts/rvm;
            cd ~/code/%git_project_name%; rvm install 3.1.2;
            rvm --default use 3.1.2; bundler update;',
        :matches => [ 
            /Bundle updated\!/i,
        ],
        :nomatches => [ 
            { :nomatch => /not found/i, :error_description => 'An Error Occurred' },
        ],
        :sudo => true,
    },
  ],
});