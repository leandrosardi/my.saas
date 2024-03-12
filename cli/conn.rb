# encoding: utf-8
#
# conn.rb : Test the database connection configuration.
# Author: Leandro D. Sardi (https://github.com/leandrosardi).
#
# Use this command to see the raw connection string to the database, and test it.
# 
require 'mysaas'
require 'lib/stubs'
require 'config'
l = BlackStack::BaseLogger.new(nil)
BlackStack::CRDB.test(l)
exit(0)