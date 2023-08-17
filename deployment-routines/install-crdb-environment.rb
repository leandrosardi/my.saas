# this routine install 
BlackStack::Deployer::add_routine({
  :name => 'install-crdb-environment',
  :commands => [
    { 
        :sudo=> true,
        :command => '
          cd ~; 
          mv /usr/local/bin/cockroach /usr/local/bin/cockroach.back.%timestamp%;
          mv cockroach-v21.2.10.linux-amd64 cockroach-v21.2.10.linux-amd64.back.%timestamp%;
          curl https://binaries.cockroachdb.com/cockroach-v21.2.10.linux-amd64.tgz | tar -xz && cp -i cockroach-v21.2.10.linux-amd64/cockroach /usr/local/bin/;
          mv /usr/local/lib/cockroach /usr/local/lib/cockroach.back.%timestamp%;
          mkdir /usr/local/lib/cockroach;
          yes | cp -i cockroach-v21.2.10.linux-amd64/lib/libgeos.so /usr/local/lib/cockroach/;
          yes | cp -i cockroach-v21.2.10.linux-amd64/lib/libgeos_c.so /usr/local/lib/cockroach/;
        ',
        #:matches => /\%.*Total.*\%.*Received.*\%.*Xferd.*Average.*Speed.*Time.*Time.*Time.*Current/
    }
  ],
});

#cockroach start --certs-dir=certs --store=%name% --listen-addr=%eth0_ip%:%crdb_database_port% --http-addr=%eth0_ip%:%crdb_dashboard_port% --join=%eth0_ip%:%crdb_database_port% --background --max-sql-memory=.25 --cache=.25;
#cockroach init --host=%eth0_ip%:%crdb_database_port% --certs-dir=certs;
#:matches => /Cluster successfully initialized/,
