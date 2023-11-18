#require_relative '../blackstack-nodes/lib/blackstack-nodes.rb'

require 'blackstack-db'
#require_relative '../blackstack-db/lib/blackstack-db.rb'

require 'blackstack-core'
require 'simple_command_line_parser'
require 'simple_cloud_logging'
require 'my-ruby-deployer'

require 'pampa'
#require_relative '../pampa/lib/pampa.rb'

require 'workmesh'
#require_relative '../../workmesh/lib/workmesh.rb'

require 'my-dropbox-api'
#require_relative '../../my-dropbox-api/lib/my-dropbox-api.rb'

require 'colorize'
require 'pg'
require 'sequel'
require 'bcrypt'
require 'mail'
require 'pry'
require 'cgi'
require 'erb'
require 'uri'
require 'nokogiri'
require 'fileutils'
require 'rack/contrib/try_static' # this is to manage many public folders
require 'postmark'

require 'app/lib/controllers'
require 'app/lib/emails'
require 'app/lib/extensions'
require 'app/lib/notifications'
require 'app/lib/tablehelper'

# Default login and signup screens.
# 
DEFAULT_LOGIN = '/login'
DEFAULT_SIGNUP = '/leads/signup'

# convert an integer to a string like 1.5K or 1.5M
def short_label(i)
    i = i.to_f
    if i >= 1000000
        return (i.to_f/1000000.to_f).round(2).to_label + 'M'
    elsif i >= 1000
        return (i.to_f/1000.to_f).round(2).to_label + 'K'
    else
        return i.to_label
    end
end

# receive a datetime parameter `dt`
# return a string like ''1 day ago', '2 hours ago', '3 minutes ago', '4 seconds ago'.
# 
# this function returns a string that describe difference between two times, in a human-friendy way.
# e.g. "3 hours", "2 days"
def htimediff(from, to=nil)
  to = now if to.nil?
  n = (to - from).to_i
  if n<60
      return "#{n} seconds"
  elsif n<60*60
      return "#{n/60} minutes"
  elsif n<60*60*24
      return "#{n/(60*60)} hours"
  else
      return "#{n/(60*60*24)} days"
  end
end

# map params key-values to session key-values.
# for security: the keys `:password` and `:new_password` are not mapped.
def params_to_session(path=nil)
    params.each do |key, value|
      if path.nil?
        session[key.to_s] = value if key != :password && key != :new_password
      else
        session[path + '.' + key] = value if key != :password && key != :new_password
      end
    end
end

  # Helper: get the real user who is logged in.
# If this account is accessded by an operator, return the [user] object of such an operator.
# Otherwise, return the logged-in [user].
def real_user
    login = BlackStack::MySaaS::Login.where(:id=>session['login.id']).first
    uid = !session['login.id_prisma_user'].nil? ? session['login.id_prisma_user'] : login.user.id
    BlackStack::MySaaS::User.where(:id=>uid).first
end # def real_user
  
# Helper: create file ./.maintenance if you want to disable internal pages in the member area
def unavailable?
    f = File.exist?(File.expand_path(__FILE__).gsub('/mysaas.rb', '') + '/.maintenance')
end
  
# Helper: create file ./.notrial if you want to switch to another landing
def notrial?
    f = File.exist?(File.expand_path(__FILE__).gsub('/app.rb', '') + '/.notrial')
end
  
# Helper: return true if there is a user logged into
def logged_in?
    !session['login.id'].nil?
end

## Add your other libraries here
## 
require "fileutils"
require 'mail'
require 'net/imap'
require 'csv'
require 'email_verifier'
require 'sisimai'

module BlackStack
    module Emails
        UNSUBSCRIBE_MERGETAG = '{unsubscribe-url}'

        @@mergetags = [
            '{company-name}',
            '{first-name}',
            '{last-name}',
            '{location}',
            '{industry}',
            '{email-address}',
            '{phone-number}',
            '{linkedin-url}',
            UNSUBSCRIBE_MERGETAG,
        ]

        def self.set_mergetags(tags)
            @@mergetags = tags
        end

        def self.mergetags
            @@mergetags
        end

        # -------------------------------------------------------------------------------------
        # Statistic Methods
        # -------------------------------------------------------------------------------------
        
        # return query to get the number of emails sent, by hour, from a given time
        # 
        # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
        # id_account: if nil, all accounts are considered
        # id_campaign: if nil, all campaigns are considered
        # id_followup: if nil, all followups are considered
        # id_address: if nil, all addresses are considered
        # 
        def self.query_sents(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
            from_time = Time.new(2000, 1, 1) if from_time.nil?
            q = "
                select 
                    gen_random_uuid() as id,
                    cast('#{now}' as timestamp) as create_time,
                    u.id_account,
                    f.id_campaign, 
                    d.id_followup, 
                    d.id_address,
                    cast(extract('year', d.delivery_end_time) as int) as yy,
                    cast(extract('month', d.delivery_end_time) as int) as mm,
                    cast(extract('day', d.delivery_end_time) as int) as dd,
                    cast(extract('hour', d.delivery_end_time) as int) as hh,
                    count(distinct d.id) as n
                from eml_delivery d
                join eml_followup f on f.id=d.id_followup
                join \"user\" u on u.id=f.id_user
                where coalesce(d.is_response,false) = false
                and coalesce(d.delivery_success,false) = true
            "

            q += " and u.id_account='#{id_account}'" if id_account
            q += " and f.id_campaign='#{id_campaign}'" if id_campaign
            q += " and f.id='#{id_followup}'" if id_followup
            q += " and d.id_address='#{id_address}'" if id_address

            q += " 
                and d.delivery_end_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'
                group by
                    f.id_campaign, 
                    d.id_followup, 
                    d.id_address,
                    u.id_account,
                    extract('year', d.delivery_end_time),
                    extract('month', d.delivery_end_time),
                    extract('day', d.delivery_end_time),
                    extract('hour', d.delivery_end_time)
            "
        end # def self.sents

        # return query to get the number of emails received, by hour, from a given time
        # 
        # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
        # id_account: if nil, all accounts are considered
        # id_campaign: if nil, all campaigns are considered
        # id_followup: if nil, all followups are considered
        # id_address: if nil, all addresses are considered
        # 
        def self.query_replies(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
            from_time = Time.new(2000, 1, 1) if from_time.nil?
            q = "
                select 
                    gen_random_uuid() as id,
                    cast('#{now}' as timestamp) as create_time,
                    u.id_account,
                    f.id_campaign, 
                    d.id_followup, 
                    d.id_address,
                    cast(extract('year', r.create_time) as int) as yy,
                    cast(extract('month', r.create_time) as int) as mm,
                    cast(extract('day', r.create_time) as int) as dd,
                    cast(extract('hour', r.create_time) as int) as hh,
                    count(distinct r.id) as n
                from eml_delivery d
                join eml_delivery r on (d.id_conversation=r.id_conversation and coalesce(r.is_response,false)=true and coalesce(r.is_bounce)=false)
                join eml_followup f on f.id=d.id_followup
                join \"user\" u on u.id=f.id_user
                where coalesce(d.is_response,false) = false
                and coalesce(d.delivery_success,false) = true
            "

            q += " and u.id_account='#{id_account}'" if id_account
            q += " and f.id_campaign='#{id_campaign}'" if id_campaign
            q += " and f.id='#{id_followup}'" if id_followup
            q += " and d.id_address='#{id_address}'" if id_address

            q += " 
                and d.create_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'
                group by
                    f.id_campaign, 
                    d.id_followup, 
                    d.id_address,
                    u.id_account,
                    extract('year', r.create_time),
                    extract('month', r.create_time),
                    extract('day', r.create_time),
                    extract('hour', r.create_time)
            "
        end

        # return query to get the number of emails received and marked as positives, by hour, from a given time
        # 
        # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
        # id_account: if nil, all accounts are considered
        # id_campaign: if nil, all campaigns are considered
        # id_followup: if nil, all followups are considered
        # id_address: if nil, all addresses are considered
        # 
        def self.query_positive_replies(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
            from_time = Time.new(2000, 1, 1) if from_time.nil?
            q = "
                select 
                    gen_random_uuid() as id,
                    cast('#{now}' as timestamp) as create_time,
                    u.id_account,
                    f.id_campaign, 
                    d.id_followup, 
                    d.id_address,
                    cast(extract('year', r.create_time) as int) as yy,
                    cast(extract('month', r.create_time) as int) as mm,
                    cast(extract('day', r.create_time) as int) as dd,
                    cast(extract('hour', r.create_time) as int) as hh,
                    count(distinct r.id) as n
                from eml_delivery d
                join eml_delivery r on (d.id_conversation=r.id_conversation and coalesce(r.is_response,false)=true and coalesce(r.is_bounce,false)=false and coalesce(r.is_positive,false)=true)
                join eml_followup f on f.id=d.id_followup
                join \"user\" u on u.id=f.id_user
                where coalesce(d.is_response,false) = false
                and coalesce(d.delivery_success,false) = true
            "

            q += " and u.id_account='#{id_account}'" if id_account
            q += " and f.id_campaign='#{id_campaign}'" if id_campaign
            q += " and f.id='#{id_followup}'" if id_followup
            q += " and d.id_address='#{id_address}'" if id_address

            q += " 
                and d.create_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'
                group by
                    f.id_campaign, 
                    d.id_followup, 
                    d.id_address,
                    u.id_account,
                    extract('year', r.create_time),
                    extract('month', r.create_time),
                    extract('day', r.create_time),
                    extract('hour', r.create_time)
            "
        end

        # return query to get the number of (non-unique) opens by hour, from a given time
        # 
        # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
        # id_account: if nil, all accounts are considered
        # id_campaign: if nil, all campaigns are considered
        # id_followup: if nil, all followups are considered
        # id_address: if nil, all addresses are considered
        # 
        def self.query_opens(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
            from_time = Time.new(2000, 1, 1) if from_time.nil?
            q = "
                select 
                    gen_random_uuid() as id,
                    cast('#{now}' as timestamp) as create_time,
                    u.id_account,
                    f.id_campaign, 
                    d.id_followup, 
                    d.id_address,
                    cast(extract('year', o.create_time) as int) as yy,
                    cast(extract('month', o.create_time) as int) as mm,
                    cast(extract('day', o.create_time) as int) as dd,
                    cast(extract('hour', o.create_time) as int) as hh,
                    count(distinct o.id) as n
                from eml_delivery d
                join eml_open o on d.id=o.id_delivery
                join eml_followup f on f.id=d.id_followup
                join \"user\" u on u.id=f.id_user
                where 1=1
            "

            q += " and u.id_account='#{id_account}'" if id_account
            q += " and f.id_campaign='#{id_campaign}'" if id_campaign
            q += " and f.id='#{id_followup}'" if id_followup
            q += " and d.id_address='#{id_address}'" if id_address

            q += " 
                and d.delivery_end_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'
                group by
                    f.id_campaign, 
                    d.id_followup, 
                    d.id_address,
                    u.id_account,
                    extract('year', o.create_time),
                    extract('month', o.create_time),
                    extract('day', o.create_time),
                    extract('hour', o.create_time)
            "
        end

        # return query to get the number of (unique) opens by hour, from a given time
        # 
        # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
        # id_account: if nil, all accounts are considered
        # id_campaign: if nil, all campaigns are considered
        # id_followup: if nil, all followups are considered
        # id_address: if nil, all addresses are considered
        # 
        def self.query_unique_opens(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
            from_time = Time.new(2000, 1, 1) if from_time.nil?
            q = "
                select 
                    gen_random_uuid() as id,
                    cast('#{now}' as timestamp) as create_time,
                    v.id_account,
                    v.id_campaign,
                    v.id_followup,
                    v.id_address,
                    v.yy,
                    v.mm,
                    v.dd,
                    v.hh,
                    count(*) as n
                from (
                    select 
                        u.id_account,
                        f.id_campaign, 
                        d.id_followup, 
                        d.id_address,
                        cast(extract('year', min(o.create_time)) as int) as yy,
                        cast(extract('month', min(o.create_time)) as int) as mm,
                        cast(extract('day', min(o.create_time)) as int) as dd,
                        cast(extract('hour', min(o.create_time)) as int) as hh,
                        o.id_delivery
                    from eml_delivery d
                    join eml_open o on d.id=o.id_delivery
                    join eml_followup f on f.id=d.id_followup
                    join \"user\" u on u.id=f.id_user
                    and o.create_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'
                    group by
                        f.id_campaign, 
                        d.id_followup, 
                        d.id_address,
                        u.id_account,
                        o.id_delivery
                ) v
                where 1=1
                "

                q += " and v.id_account='#{id_account}'" if id_account
                q += " and v.id_campaign='#{id_campaign}'" if id_campaign
                q += " and v.id_followup='#{id_followup}'" if id_followup
                q += " and v.id_address='#{id_address}'" if id_address    

                q += "
                group by 
                    v.id_account,
                    v.id_campaign,
                    v.id_followup,
                    v.id_address,
                    v.yy,
                    v.mm,
                    v.dd,
                    v.hh
                "            
        end

        # return query to get the number of (non unique) clicks by hour, from a given time
        # 
        # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
        # id_account: if nil, all accounts are considered
        # id_campaign: if nil, all campaigns are considered
        # id_followup: if nil, all followups are considered
        # id_address: if nil, all addresses are considered
        # 
        def self.query_clicks(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
            from_time = Time.new(2000, 1, 1) if from_time.nil?
            q = "
                select 
                    gen_random_uuid() as id,
                    cast('#{now}' as timestamp) as create_time,
                    u.id_account,
                    f.id_campaign, 
                    d.id_followup, 
                    d.id_address,
                    cast(extract('year', o.create_time) as int) as yy,
                    cast(extract('month', o.create_time) as int) as mm,
                    cast(extract('day', o.create_time) as int) as dd,
                    cast(extract('hour', o.create_time) as int) as hh,
                    count(distinct o.id) as n
                from eml_delivery d
                join eml_click o on d.id=o.id_delivery
                join eml_followup f on f.id=d.id_followup
                join \"user\" u on u.id=f.id_user
                where 1=1
            "

            q += " and u.id_account='#{id_account}'" if id_account
            q += " and f.id_campaign='#{id_campaign}'" if id_campaign
            q += " and f.id='#{id_followup}'" if id_followup
            q += " and d.id_address='#{id_address}'" if id_address

            q += " 
                and d.delivery_end_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'
                group by
                    f.id_campaign, 
                    d.id_followup, 
                    d.id_address,
                    u.id_account,
                    extract('year', o.create_time),
                    extract('month', o.create_time),
                    extract('day', o.create_time),
                    extract('hour', o.create_time)
            "
        end

        # return query to get the number of (unique) clicks by hour, from a given time
        # 
        # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
        # id_account: if nil, all accounts are considered
        # id_campaign: if nil, all campaigns are considered
        # id_followup: if nil, all followups are considered
        # id_address: if nil, all addresses are considered
        # 
        def self.query_unique_clicks(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
            from_time = Time.new(2000, 1, 1) if from_time.nil?
            q = "
                select 
                    gen_random_uuid() as id,
                    cast('#{now}' as timestamp) as create_time,
                    v.id_account,
                    v.id_campaign,
                    v.id_followup,
                    v.id_address,
                    v.yy,
                    v.mm,
                    v.dd,
                    v.hh,
                    count(*) as n
                from (
                    select 
                        u.id_account,
                        f.id_campaign, 
                        d.id_followup, 
                        d.id_address,
                        cast(extract('year', min(o.create_time)) as int) as yy,
                        cast(extract('month', min(o.create_time)) as int) as mm,
                        cast(extract('day', min(o.create_time)) as int) as dd,
                        cast(extract('hour', min(o.create_time)) as int) as hh,
                        o.id_delivery
                    from eml_delivery d
                    join eml_click o on d.id=o.id_delivery
                    join eml_followup f on f.id=d.id_followup
                    join \"user\" u on u.id=f.id_user
                    and o.create_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'
                    group by
                        f.id_campaign, 
                        d.id_followup, 
                        d.id_address,
                        u.id_account,
                        o.id_delivery
                ) v
                where 1=1
                "

                q += " and v.id_account='#{id_account}'" if id_account
                q += " and v.id_campaign='#{id_campaign}'" if id_campaign
                q += " and v.id_followup='#{id_followup}'" if id_followup
                q += " and v.id_address='#{id_address}'" if id_address    

                q += "
                group by 
                    v.id_account,
                    v.id_campaign,
                    v.id_followup,
                    v.id_address,
                    v.yy,
                    v.mm,
                    v.dd,
                    v.hh
                "            
        end

        # return query to get the number of bounces by hour, from a given time
        # 
        # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
        # id_account: if nil, all accounts are considered
        # id_campaign: if nil, all campaigns are considered
        # id_followup: if nil, all followups are considered
        # id_address: if nil, all addresses are considered
        # 
        def self.query_bounces(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
            from_time = Time.new(2000, 1, 1) if from_time.nil?
            q = "
                select 
                    gen_random_uuid() as id,
                    cast('#{now}' as timestamp) as create_time,
                    u.id_account,
                    f.id_campaign, 
                    d.id_followup, 
                    d.id_address,
                    cast(extract('year', r.create_time) as int) as yy,
                    cast(extract('month', r.create_time) as int) as mm,
                    cast(extract('day', r.create_time) as int) as dd,
                    cast(extract('hour', r.create_time) as int) as hh,
                    count(distinct r.id) as n
                from eml_delivery d
                join eml_delivery r on (d.id_conversation=r.id_conversation and coalesce(r.is_response,false)=true and coalesce(r.is_bounce,false)=true)
                join eml_followup f on f.id=d.id_followup
                join \"user\" u on u.id=f.id_user
                where coalesce(d.is_response,false) = false
                and coalesce(d.delivery_success,false) = true
            "

            q += " and u.id_account='#{id_account}'" if id_account
            q += " and f.id_campaign='#{id_campaign}'" if id_campaign
            q += " and f.id='#{id_followup}'" if id_followup
            q += " and d.id_address='#{id_address}'" if id_address

            q += " 
                and d.delivery_end_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'
                group by
                    f.id_campaign, 
                    d.id_followup, 
                    d.id_address,
                    u.id_account,
                    extract('year', r.create_time),
                    extract('month', r.create_time),
                    extract('day', r.create_time),
                    extract('hour', r.create_time)
            "
        end

        # return query to get the number of unsubscribes by hour, from a given time
        # 
        # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
        # id_account: if nil, all accounts are considered
        # id_campaign: if nil, all campaigns are considered
        # id_followup: if nil, all followups are considered
        # id_address: if nil, all addresses are considered
        # 
        def self.query_unsubscribes(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
            from_time = Time.new(2000, 1, 1) if from_time.nil?
            q = "
                select 
                    gen_random_uuid() as id,
                    cast('#{now}' as timestamp) as create_time,
                    u.id_account,
                    f.id_campaign, 
                    d.id_followup, 
                    d.id_address,
                    cast(extract('year', o.create_time) as int) as yy,
                    cast(extract('month', o.create_time) as int) as mm,
                    cast(extract('day', o.create_time) as int) as dd,
                    cast(extract('hour', o.create_time) as int) as hh,
                    count(distinct o.id) as n
                from eml_delivery d
                join eml_unsubscribe o on d.id=o.id_delivery
                join eml_followup f on f.id=d.id_followup
                join \"user\" u on u.id=f.id_user
                where 1=1
            "

            q += " and u.id_account='#{id_account}'" if id_account
            q += " and f.id_campaign='#{id_campaign}'" if id_campaign
            q += " and f.id='#{id_followup}'" if id_followup
            q += " and d.id_address='#{id_address}'" if id_address

            q += " 
                and d.delivery_end_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'
                group by
                    f.id_campaign, 
                    d.id_followup, 
                    d.id_address,
                    u.id_account,
                    extract('year', o.create_time),
                    extract('month', o.create_time),
                    extract('day', o.create_time),
                    extract('hour', o.create_time)
            "
        end

    end # module Emails
end # module BlackStack