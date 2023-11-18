# MySaaS Emails - Delivery
# Copyright (C) 2022 ExpandedVenture, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
#
# Authors: Leandro Daniel Sardi (https://github.com/leandrosardi)
#

# README
# 
# In order to [pamperize](https://github.com/leandrosardi/pampa), it must be done at an `account` level.
# That means: each account will run its own planner.
# 
# In order to don't have to manage concurrency on the `shared_addresses` array, shared addresses must be
# assgined to a single accounts during a `leassing period`.
#

# load gem and connect database
require 'app/mysaas'
require 'app/lib/stubs'
require 'app/config'
require 'app/version'
DB = BlackStack::CRDB::connect
require 'app/lib/skeletons'

require 'app/extensions/i2p/lib/skeletons'
require 'app/extensions/i2p/main'

# add required extensions
BlackStack::Extensions.append :i2p

l = BlackStack::LocalLogger.new('./delivery.log')

# total number of deliveries created per while(true) loop
n = 0

while (true)
    n = 0 # reset the number of deliveries created per while(true) loop
    
    begin

        # get array of addresses to process
        l.logs 'Get addresses to process... '
        addresses = BlackStack::Emails::Address.where(:delete_time=>nil, :enabled=>true).all
        l.logf addresses.size.to_s.green

        # store the number of deliveries left per address
        l.logs 'Get daily left quota per address... '
        buff = BlackStack::Emails::Address.daily_left_for_delivery(addresses.map(&:id))
        l.logf 'done'.green

        addresses.each { |a|
            l.log ''
            l.log "#{a.address}:"

            l.logs 'Validate stealth configuration... '
            min = a.delivery_interval_min_minutes.to_i
            max = a.delivery_interval_max_minutes.to_i
            raise 'Invalid stealth configuration' if min > max
            l.logf 'done'.green

            l.logs 'Get daily left quota... '
            daily_left = buff[a.id][:daily_left]
            l.logf daily_left <= 0 ? daily_left.to_s.red : daily_left.to_s.green
            next if daily_left <= 0

            l.logs 'Get last delivery (minutes ago)... '
            minsago = buff[a.id][:last_delivery_minutes_ago]
            b = minsago > min + rand(max-min)
            l.logf !b ? minsago.to_s.red : minsago.to_s.green
            next if !b

            l.logs 'Get number of allowed deliveries... '
            allowed = (min==0 && max==0) ? daily_left : 1 
            l.logf allowed.to_s.green
        
            l.logs 'Get pending deliveries... '
            deliveries = BlackStack::Emails::Delivery.where(:id_address=>a.id, :delete_time=>nil, :delivery_end_time=>nil, :is_response=>[nil,false]).all

            raise 'Daily Quota Exceeded' if deliveries.size > a.max_deliveries_per_day
            l.logf deliveries.size == 0 ? '0' : deliveries.size.to_s.green
            next if deliveries.size == 0

            # remove all deliveries that are not in schedule
            l.logs 'Remove deliveries out of schedule... '
            id_campaigns = deliveries.select { |d| d.id_followup }.map { |d| d.followup.id_campaign }.uniq
            id_campaigns = id_campaigns.select { |id_campaign| BlackStack::Emails::Campaign.select(:id, :id_user).where(:id=>id_campaign).first.is_in_schedule? }            
            deliveries = deliveries.select { |d| d.id_followup.nil? || id_campaigns.include?(d.followup.id_campaign) }
            l.logf deliveries.size == 0 ? '0' : deliveries.size.to_s.green
            next if deliveries.size == 0

            # remove all deliveries that are belonging a paused followup
            l.logs 'Remove paused followups... '
            id_followups = deliveries.select { |d| d.id_followup }.map { |d| d.id_followup }.uniq
            id_followups = id_followups.select { |id_followup| BlackStack::Emails::Followup.select(:id, :id_user, :status).where(:id=>id_followup).first.status == BlackStack::Emails::Followup::STATUS_ON }
            deliveries = deliveries.select { |d| d.id_followup.nil? || id_followups.include?(d.id_followup) }
            l.logf deliveries.size == 0 ? '0' : deliveries.size.to_s.green
            next if deliveries.size == 0

            # remove all deliveries that are belonging a paused followup
            l.logs 'Remove deleted followups... '
            id_followups = deliveries.select { |d| d.id_followup }.map { |d| d.id_followup }.uniq
            id_followups = id_followups.select { |id_followup| BlackStack::Emails::Followup.select(:id, :id_user, :delete_time).where(:id=>id_followup).first.delete_time.nil? }
            deliveries = deliveries.select { |d| d.id_followup.nil? || id_followups.include?(d.id_followup) }
            l.logf deliveries.size == 0 ? '0' : deliveries.size.to_s.green
            next if deliveries.size == 0

            # iterate deliveries
            j = 0
            while j < allowed && j < daily_left && j < a.max_deliveries_per_day && j < deliveries.size 
                # get the delivery
                d = deliveries[j]
                # increase the array position
                j += 1
                # incdes the number of deliveries created per while(true) loop
                n += 1
                # delivery
                l.logs "#{d.id}... "
                d.deliver
                l.logf 'sent'.green
            end

        }

    rescue => e
        l.logf "Error: #{e.message}"
    end 

    l.logs 'Sleeping... '
    sleep(10*60) if n == 0
    l.logf 'done'.green
  end # while (true)