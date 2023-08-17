require 'pg'
require 'sequel'

DB_PASSWORD = "*******"
DATABASE_URL="postgresql://blackstack:#{DB_PASSWORD}@free-tier14.aws-us-east-1.cockroachlabs.cloud:26257/blackstack?sslmode=verify-full&options=--cluster%3Dblackstack-4545"

conn = PG.connect(DATABASE_URL)
p conn.exec("SELECT 'Hello CockroachDB!' AS message").first
# => {"message"=>"Hello CockroachDB!"}

DB = Sequel.connect(DATABASE_URL)
p DB["SELECT 'Hello CockroachDB!' AS message"].first
# => {:message=>"Hello CockroachDB!"}
