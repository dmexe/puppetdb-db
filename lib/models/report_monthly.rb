require 'json'

class ReportMonthly
  class << self
    def stats(options = {})
      from = options[:from]
      node = options[:node]
      rs = fill_data

      latest(node, from).each do |report|
        next unless report
        tm = report.time
        tm = Time.utc(tm.year, tm.month, tm.day)
        rs[tm][:success]  += report.success
        rs[tm][:failed]   += report.failed
        rs[tm][:skipped]  += report.skipped
        rs[tm][:duration] += report.duration
        rs[tm][:requests] += 1
      end
      rs.to_a
    end

    private
      def latest(node, from)
        ReportIndex.find_reports(:scope => :all, :node => node, :from => from)
      end

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
