module Application
  class Home < Application::Base
    get '/' do
      redirect '/ui'
    end

    get '/ui' do
      haml :index
    end

    get '/ui/*' do
      haml :index
    end
  end
end
