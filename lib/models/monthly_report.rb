require 'json'

class MonthlyReport
  class << self
    def last_hashes(from = nil)
      Report.find_keys(from).map{|i| i.split(":").last }
    end

    def last_node_hashes(node, from = nil)
      NodeReport.find_keys_by_node(node, from: from).map{|i| i.split(":").last }
    end

    def last_summaries(hashes)
      ReportSummary.find hashes
    end

    def stats(options = {})
      from = options[:from]
      node = options[:node]
      rs = fill_data

      hashes = node ? last_node_hashes(node, from) : last_hashes(from)

      last_summaries(hashes).each do |summary|
        tm = summary.timestamp
        tm = Time.utc(tm.year, tm.month, tm.day)
        rs[tm][:success]  += summary.success
        rs[tm][:failed]   += summary.failed
        rs[tm][:skipped]  += summary.skipped
        rs[tm][:duration] += summary.duration
        rs[tm][:requests] += 1
      end
      rs.to_a
    end

    private
      def fill_data
        rs = {}

        start  = Time.now.utc - 60 * 60 * 24 * 31 # 31 days
        finish = Time.now.utc
        while start < finish
          tm = Time.utc(start.year, start.month, start.day)
          rs[tm] ||= {}
          rs[tm][:success]  ||= 0
          rs[tm][:failed]   ||= 0
          rs[tm][:skipped]  ||= 0
          rs[tm][:duration] ||= 0
          rs[tm][:requests] ||= 0
          start = start + 60 * 60 * 24
        end

        rs
      end
  end
end
