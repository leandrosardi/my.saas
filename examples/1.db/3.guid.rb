require 'pg'
require 'sequel'
require 'lib/core'
require 'lib/stub'
require 'config.rb'

DB = BlackStack::CRDB::connect

p guid