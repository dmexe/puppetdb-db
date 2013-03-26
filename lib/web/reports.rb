module App
  class Reports < App::Web
    post '/upload' do
      ReportProcessing.new(request.body.read).process_delayed!
    end
  end
end
