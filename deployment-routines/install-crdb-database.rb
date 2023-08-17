# this routine install 
BlackStack::Deployer::add_routine({
  :name => 'install-crdb-database',
  :commands => [
    { 
        :command => "cockroach sql --host %eth0_ip%:%crdb_database_port% --certs-dir %crdb_database_certs_path%/certs -e \"CREATE USER blackstack WITH PASSWORD %crdb_database_password%;\";",
        :matches => [/CREATE ROLE/, /already exists/],
        :sudo => true,
    }, {
        :command => "cockroach sql --host %eth0_ip%:%crdb_database_port% --certs-dir %crdb_database_certs_path%/certs -e \"CREATE DATABASE blackstack WITH ENCODING = UTF8 CONNECTION LIMIT = -1;\";",
        :matches => [/CREATE DATABASE/, /already exists/],
        :sudo => true,
    }, {
        :command => "cockroach sql --host %eth0_ip%:%crdb_database_port% --certs-dir %crdb_database_certs_path%/certs -e \"GRANT ALL ON DATABASE blackstack TO blackstack;\";",
        :matches => [/GRANT/, /unexpected end of file/],
        :sudo => true,
    }, {
        :command => "cockroach sql --host %eth0_ip%:%crdb_database_port% --certs-dir %crdb_database_certs_path%/certs -e \"SHOW GRANTS ON DATABASE blackstack;\";",
        :matches => [/database_name\.*|\.*grantee\.*|\.*privilege_type/, /unexpected end of file/],
        :sudo => true,
    }
  ],
});

#cockroach start --certs-dir=certs --store=%name% --listen-addr=%eth0_ip%:%crdb_database_port% --http-addr=%eth0_ip%:%crdb_database_port% --join=%eth0_ip%:%crdb_database_port% --background --max-sql-memory=.25 --cache=.25;
#cockroach init --host=%eth0_ip%:%crdb_database_port% --certs-dir=certs;
#:matches => /Cluster successfully initialized/,
