# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
DB = BlackStack.db_connect
require 'lib/skeletons'

u = BlackStack::MySaaS::User.where(:email=>'leandro.sardi@expandedventure.com').first
puts u.email 

BlackStack::MySaaS::NotificationWelcome.new(u).do
