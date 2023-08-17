# Deprecated - This is not handled by the bash script cli/install.sh
#require_relative './upgrade-packages.rb'
#require_relative './install-packages.rb'
#require_relative './install-ruby.rb'
require_relative './install-mysaas.rb'
#require_relative './setup-mysaas.rb'

# Deprecated - All databases are now running on CRDB's Cloud, in serverless mode.
#require_relative './install-crdb-environment.rb'
#require_relative './start-crdb-environment.rb'
#require_relative './install-crdb-database.rb'

require_relative './setup-mysaas-upload-config.rb'
require_relative './stop-mysaas.rb'
require_relative './start-mysaas.rb'
