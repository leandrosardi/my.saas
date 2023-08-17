require 'pry'
require 'sinatra'
require_relative 'models/stub/renderer/renderer'

configure { set :server, :puma }
set :bind, '0.0.0.0'
set :port, 3000
enable :sessions
enable :static

get '/' do
  BlackStack::Renderer.render('/settings/users')
end
