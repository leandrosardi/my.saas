require 'simple_command_line_parser'
require 'simple_cloud_logging'
require 'blackstack-core'

require 'blackstack-nodes'
require 'blackstack-db'
#require_relative '../blackstack-db/lib/blackstack-db.rb'
#require_relative '../blackstack-nodes/lib/blackstack-nodes.rb'

# DEPRECATED
#require 'blackstack-enrichment'

require 'my-ruby-deployer'
require 'zyte-client'
require 'pampa'
require 'adspower-client'
require 'mass-client'
#require_relative '../pampa/lib/pampa.rb'

# DEPRECATED
#require 'workmesh'
#require_relative '../../workmesh/lib/workmesh.rb'

require 'openai' #, '~>6.3.1'
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

require 'net/imap'
require 'csv'
require 'sisimai'
require 'down'
require 'securerandom'

require 'lib/controllers'
require 'lib/emails'
require 'lib/extensions'
require 'lib/notifications'
require 'lib/tablehelper'

# Use these values in the screens with a period-filter.
PERIOD_FILTER_VALUES = [
    {'unit' => 'hours', 'number' => 1, 'text' => 'Last Hour'},
    {'unit' => 'hours', 'number' => 3, 'text' => 'Last 3 Hours'},
    {'unit' => 'hours', 'number' => 6, 'text' => 'Last 6 Hours'},
    {'unit' => 'hours', 'number' => 12, 'text' => 'Last 12 Hours'},
    {'unit' => 'hours', 'number' => 24, 'text' => 'Last 24 Hours'},
    {'unit' => 'days', 'number' => 1, 'text' => 'Last 1 Day'},
    {'unit' => 'days', 'number' => 3, 'text' => 'Last 3 Days'},
    {'unit' => 'weeks', 'number' => 1, 'text' => 'Last 1 Week'},
    {'unit' => 'weeks', 'number' => 4, 'text' => 'Last 4 Weeks'},
]

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


class String
    # add HTML code to highlight the keyword in yellow.
    def highlight(filter)
      x = self
      unless filter.to_s.empty?
        a = x.scan(/#{Regexp.escape(filter)}/i)
        a.each { |m|
            x = x.gsub(m, "<span style='background-color:yellow;'>#{m}</span>")
        }
      end # if 
      return x
    end # def 

    # remove empty lines and strip spaces
    # reference: https://stackoverflow.com/questions/7339292/ruby-remove-empty-lines-from-string
    def superstrip
      self.gsub(/^$\n/, '').gsub(/\n/, '').gsub(/\r/, '').strip
    end # def

    # blackstack-core .url? method is not working with URLs like this:
    # https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQCog_mVAC5GD0Nmeyo9KJBo7jAY5CM9EM8VfiGKB2BMdPnZ0PT6MRl9AE-o65LJrlSOzU&usqp=CAU
    #
    def valid_url?
        self =~ /^http(s)?:\/\/[a-z0-9\-\._~:\/\?#\[\]@!\$&'\(\)\*\+,;=]+$/i
    end

    # 
    def valid_filename?
        self =~ /^file\:\/\//
    end

    # 
    def valid_domain?
        self =~ /^(http(s)?\:\/\/)?([a-z0-9\-\._]+\.)+[a-z]+(\/)?$/
    end
end # class