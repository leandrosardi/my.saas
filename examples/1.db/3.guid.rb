require 'pg'
require 'sequel'
require 'lib/core'
require 'lib/stub'
require 'config.rb'

DB = BlackStack.db_connect

p guid