# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
DB = BlackStack.db_connect

p DB["SELECT 'Hello CockroachDB!' AS message"].first
# => {:message=>"Hello CockroachDB!"}
