class ReportIndex
  class << self
    def add(report)
      nodeless_index("all").add report.time, report.key
      node_index(report, "all").add report.time, report.key

      if report.success? || report.failed?
        nodeless_index("active").add report.time, report.key
        node_index(report, "active").add report.time, report.key
      end
    end

    def find_reports(options = {})
      scope = options.delete(:scope) || :all
      node  = options.delete(:node)

      index = node ? node_index(node, scope) : nodeless_index(scope)
      keys = index.all(options)
      Report.get keys
    end

    private
      def nodeless_index(name)
        Index["reports:#{name}"]
      end

      def node_index(report_or_node, name)
        node = report_or_node.respond_to?(:node) ? report_or_node.node : report_or_node
        name = "nodes:#{node}:reports:#{name}"
        Index[name]
      end
  end
end
