require 'faraday'
require 'faraday_middleware'
require 'uri'

module PuppetDB
  class Client
    class << self
      def inst
        @inst ||= Client.new
      end
    end

    def nodes
      get "nodes"
    end

    def facts(node)
      get "nodes/#{node}/facts"
    end

    def reports(name)
      query "reports", "=", 'certname', name
    end

    def report(report_id)
      query "events", "=", 'report', report_id
    end

    private
      def conn
        @conn ||= begin
          _conn = Faraday.new host do |c|
            c.use FaradayMiddleware::ParseJson, content_type: 'application/json'
            c.use Faraday::Response::Logger
            c.use Faraday::Response::RaiseError
            c.use Faraday::Adapter::NetHttp
          end
          _conn.headers[:accept] = 'application/json'
          _conn
        end
      end

      def host
        ENV['PUPPETDB_URL'] || 'http://localhost:8080'
      end

      def get(url, options = {})
        conn.get("/v2/#{url}", options).body
      end

      def query(url, *q)
        q = %{query=["#{q[0]}","#{q[1]}","#{q[2]}"] }
        conn.get("/experimental/#{url}?" + URI.encode(q)).body
      end
  end
end
