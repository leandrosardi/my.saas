# setup deploying rutines
BlackStack::Deployer::add_routine({
  :name => 'setup-mysaas',
  :commands => [
    { 
        # back up old configuration file
        # setup new configuration file
        :command => "
            cd ~/code/mysaas; 
            mv ./config.rb ./config.%timestamp%.rb;
            cp ./config.template.rb ./config.rb;
            sed -i \"s/@db_url@/%crdb_hostname%/g\" ./config.rb;
            sed -i \"s/@db_port@/%crdb_database_port%/g\" ./config.rb;
            sed -i \"s/@db_name@/blackstack/g\" ./config.rb;
            sed -i \"s/@db_user@/blackstack/g\" ./config.rb;
            sed -i \"s/@db_password@/%crdb_database_password%/g\" ./config.rb;            
        ",
        :matches => [ /^$/, /mv: cannot stat '\.\/config.rb': No such file or directory/ ],
        #:nomatches => [ { :nomatch => /.+/, :error_description => 'No output expected.' } ],
        :sudo => false,
    },
  ],
});
