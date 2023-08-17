# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
require 'version'
DB = BlackStack::CRDB::connect
require 'lib/skeletons'

# setting up storage configuration
BlackStack::Storage::set_storage(
  :storage_folder => SANDBOX ? '/home/leandro/code/mysaas/public/clients' : '/home/ubuntu/code/mysaas/public/clients',
  :storage_default_max_allowed_kilobytes => 15 * 1024,
  :storage_sub_folders => [
    'downloads', 'uploads', 'logs'
  ],
)
# => nil

# loading an account
a = BlackStack::MySaaS::Account.first
# => nil

# output
puts "Account Name: #{a.name}"
# => Account Name: su

puts "Account ID: #{a.id}"
# => Account ID: 897b4c5e-692e-400f-bc97-8ee0e3e1f1cf

puts "Storage Folder: #{a.storage_folder}"
# => Storage Folder: /home/leandro/code/mysaas/public/clients/897B4C5E-692E-400F-BC97-8EE0E3E1F1CF

puts "List of Sub-Folders that Every Account Should Have: #{BlackStack::Storage::storage_sub_folders.join(', ')}"
# => List of Sub-Folders that Every Account Should Have: downloads, uploads, logs

# this line create all the folders and sub-folders who not exists.
a.create_storage
# => nil

puts "Used KBs: #{a.storage_used_kb}"
# => 0

puts "Free KBs: #{a.storage_free_kb}"
# => 15360