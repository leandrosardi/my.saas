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

require 'lib/controllers'
require 'lib/emails'
require 'lib/extensions'
require 'lib/notifications'

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