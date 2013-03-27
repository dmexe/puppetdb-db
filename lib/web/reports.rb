require 'yaml'

module App
  class Reports
    class << self
      def call(env)
        if env["REQUEST_METHOD"] == 'POST'
          body = env['rack.input'].read
          if body.length > 0
            ReportWorker.perform_async(body)
          end
        end
        [200, {'Content-Type' => 'text/plain'}, ["OK"]]
      end
    end
  end
end
