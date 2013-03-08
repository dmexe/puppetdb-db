require 'pathname'

module Application
  class Base < ::Sinatra::Base
    set :root,    Application.root.to_s
    set :views,   Application.root.join("views").to_s
    set :logging, true
  end
end
