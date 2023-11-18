# MySaaS Emails - Timeline
# Copyright (C) 2022 ExpandedVenture, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
#
# Authors: Leandro Daniel Sardi (https://github.com/leandrosardi)
#

# This script is to keep the table `eml_timeline` updated.

# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
require 'version'
DB = BlackStack::CRDB::connect
require 'lib/skeletons'

# TODO: emails extension should require leads extension as a dependency
require 'extensions/i2p/lib/skeletons'
require 'extensions/i2p/main'

require 'extensions/leads/lib/skeletons'
require 'extensions/leads/main'

require 'extensions/emails/lib/skeletons'
require 'extensions/emails/main'

# add required extensions
BlackStack::Extensions.append :i2p
BlackStack::Extensions.append :leads
BlackStack::Extensions.append :emails

l = BlackStack::LocalLogger.new('./actions.log')

while (true)
    begin
        BlackStack::Emails::Action.where(:delete_time=>nil).all { |a|
            l.logs "performing action #{a.id}... "
            a.perform(l)
            l.done
            # release resources
            GC.start
            DB.disconnect
        }        
    rescue => e
        l.logf "Error: #{e.to_console}"
    end 
    
    l.logs 'Sleeping... '
    sleep(60) # Update timeline every 60 seconds.
    l.done
  end # while (true)