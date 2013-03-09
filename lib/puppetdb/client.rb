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
      Application.cache "puppetdb:#{node}:facts" do
        get "nodes/#{node}/facts"
      end
    end

    def reports(name)
      Application.cache "puppetdb:#{name}:reports" do
        query "reports", "=", 'certname', name
      end
    end

    def report(report_id)
      Application.cache "puppetdb:report:#{report_id}", ttl: 0 do
        query "events", "=", 'report', report_id
      end
    end

    def reports_summary(name)
      reports = reports(name)
      reports.map! do |report|
        events  = report(report["hash"])
        summary = events.inject({}) do |ac, it|
          ac[it["status"]] ||= 0
          ac[it["status"]] += 1
          ac
        end
        summary["hash"] = report["hash"]
        summary["duration"] = Time.parse(report['end-time']).to_i - Time.parse(report["start-time"]).to_i
        summary["timestamp"] = Time.parse(report["start-time"]).to_i * 1000
        summary
      end
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
