(function() {

  window.App || (window.App = {});

  App.Helpers = {
    linkTo: function(objectOrTitle, url) {
      if (!url) {
        url = objectOrTitle.link;
        objectOrTitle = objectOrTitle.name;
      } else {

      }
      return this.safe("<a href=\"" + url + "\">" + objectOrTitle + "</a>");
    },
    truncate: function(text, length, tail) {
      var cut;
      if (length == null) {
        length = 30;
      }
      if (tail == null) {
        tail = "...";
      }
      if (!text) {
        return "";
      }
      if (text.length < length) {
        return text;
      } else {
        cut = text.toString().substring(0, length) + tail;
        return this.safe("<span class=\"truncated-text\" title=\"" + (this.h(text.toString())) + "\">" + (this.h(cut)) + "</span>");
      }
    },
    eventStatusLabel: function(status) {
      var h, l, label;
      h = {
        "skipped": "",
        "success": "label-success",
        "failure": "label-important"
      };
      l = h[status];
      label = ("<span class=\"label " + l + "\">") + this.h(status) + "</span>";
      return this.safe(label);
    },
    reportSummary: function(summary) {
      var h;
      h = {
        "skipped": "",
        "success": "badge-success"
      };
      h = [];
      if (summary.success) {
        h.push("<span class=\"label label-success\">" + (this.h(summary.success)) + "</span>");
      }
      if (summary.failure) {
        h.push("<span class=\"label label-important\">" + (this.h(summary.failure)) + "</span>");
      }
      if (summary.skipped) {
        h.push("<span class=\"label\">" + (this.h(summary.skipped)) + "</span>");
      }
      return this.safe(h.join("&nbsp;"));
    },
    h: function(text) {
      return text.toString().replace(/\W/g, function(chr) {
        return '&#' + chr.charCodeAt(0) + ';';
      });
    }
  };

  Backbone.View.prototype.jst = function(name, context) {
    var content;
    context || (context = {});
    content = $.extend(context, App.Helpers);
    return window.JST["app/templates/" + name](context);
  };

  Backbone.View.prototype.html = function(template, context) {
    return this.$el.html(this.jst(template, context));
  };

}).call(this);
(function() {

  window.App.Router = Backbone.Router.extend({
    routes: {
      "": "dashboard",
      "/": "dashboard",
      "nodes/:node": "node",
      "nodes/:node/reports": "nodeReports",
      "nodes/:node/reports/:hash": "nodeEvents",
      "query/*q": "query"
    },
    initialize: function(options) {
      this.nodes = options.nodes;
      this.navView = new App.NavView();
      this.navView.render();
      this.searchView = new App.SearchView;
      this.dashboardView = new App.DashboardView({
        nodes: this.nodes
      });
      this.nodeView = new App.NodeView();
      this.nodeReportsView = new App.NodeReportsView();
      return this.nodeEventsView = new App.NodeEventsView();
    },
    dashboard: function() {
      this.navView.render();
      return this.dashboardView.activate();
    },
    node: function(nodeName) {
      var node;
      node = this.nodes.findByName(nodeName);
      this.navView.render({
        node: node
      });
      return this.nodeView.activate(node);
    },
    nodeReports: function(nodeName) {
      var node;
      node = this.nodes.findByName(nodeName);
      this.navView.render({
        node: node,
        reports: true
      });
      return this.nodeReportsView.activate(node);
    },
    nodeEvents: function(nodeName, hash) {
      var node;
      node = this.nodes.findByName(nodeName);
      return this.nodeEventsView.activate(node, hash, this.navView);
    },
    query: function(q) {
      console.log(q);
      this.navView.render({
        query: q
      });
      return this.searchView.activate(q);
    }
  });

  $(document).ready(function() {
    var nodes;
    if (!window.jasmine) {
      nodes = new App.NodesCollection();
      nodes.fetch().success(function() {
        window.appRouter = new App.Router({
          nodes: nodes
        });
        return Backbone.history.start({
          pushState: true,
          root: "/ui/"
        });
      });
      return $("body").on("click", "a", function(ev) {
        var el;
        el = $(ev.currentTarget);
        window.appRouter.navigate(el.attr("href"), {
          trigger: true
        });
        return false;
      });
    }
  });

}).call(this);
(function() {

  App.SummaryChart = (function() {

    function SummaryChart(data, target) {
      var chart, duration, requests, series, yAxis;
      series = [
        {
          name: "success",
          data: data.success,
          type: "column",
          yAxis: 0,
          color: "SeaGreen"
        }, {
          name: "failed",
          data: data.failed,
          type: "column",
          yAxis: 0,
          color: "Maroon"
        }
      ];
      yAxis = [
        {
          title: {
            text: "resources"
          }
        }
      ];
      if (data.duration) {
        duration = {
          name: "duration",
          data: data.duration,
          type: "spline",
          yAxis: 1,
          color: "SteelBlue",
          lineWidth: 1,
          marker: {
            enabled: false
          }
        };
        series.push(duration);
        yAxis.push({
          title: {
            text: "duration sec."
          },
          opposite: true
        });
      }
      if (data.requests) {
        requests = {
          name: "requests",
          data: data.requests,
          type: "spline",
          yAxis: 1,
          color: "Gainsboro",
          lineWidth: 1,
          marker: {
            enabled: false
          }
        };
        series.push(requests);
        yAxis.push({
          title: {
            text: "num requests"
          },
          opposite: true
        });
      }
      chart = new Highcharts.Chart({
        chart: {
          renderTo: target,
          animation: false
        },
        title: {
          text: 'Reports in last 30 days'
        },
        xAxis: {
          categories: data.days
        },
        yAxis: yAxis,
        series: series,
        plotOptions: {
          column: {
            stacking: 'normal'
          },
          line: {
            animation: false
          },
          series: {
            animation: false
          }
        },
        legend: {
          align: 'right',
          verticalAlign: 'top',
          y: -4,
          floating: true,
          borderWidth: 0
        }
      });
    }

    return SummaryChart;

  })();

}).call(this);
(function() {

  window.App.DashboardView = Backbone.View.extend({
    el: '.js-view-container',
    initialize: function() {
      this.nodes = this.options.nodes;
      this.stats = new App.MonthlyStats;
      this.metrics = new App.Metrics;
      return this.stats.on("sync", this.addStats, this);
    },
    activate: function() {
      this.metrics.fetch();
      this.stats.fetch();
      return this.render();
    },
    render: function() {
      return this.html('dashboard/show', {
        nodes: this.nodes
      });
    },
    addMetrics: function() {
      var metrics;
      metrics = new App.MetricsView({
        model: this.metrics
      });
      return $(".table-nodes", $(this.el)).before(metrics.render().el);
    },
    addStats: function() {
      var chart, data;
      data = this.stats.forChart();
      return chart = new App.SummaryChart(data, 'node-reports-summary-chart');
    }
  });

  window.App.MetricsView = Backbone.View.extend({
    tagName: "ul",
    className: "metrics inline well",
    initialize: function() {
      return this.model = this.options.model;
    },
    render: function() {
      this.html('dashboard/metrics', {
        metrics: this.model
      });
      return this;
    }
  });

}).call(this);
(function() {

  window.App.NavView = Backbone.View.extend({
    el: '.header',
    render: function(options) {
      if (options == null) {
        options = {};
      }
      return this.html('layout/navigation', {
        values: this.values(options)
      });
    },
    values: function(options) {
      var val;
      this.defaultValues || (this.defaultValues = [
        {
          link: "/",
          name: "PuppetDB Dashboard"
        }
      ]);
      val = _.clone(this.defaultValues);
      if (_.isEmpty(options)) {
        val.active = "/";
      } else if (options.query) {
        val.push({
          name: "Query: " + options.query,
          link: '/query'
        });
        val.active = '/query';
      } else if (options.node) {
        val.push(options.node);
        val.push(options.node.reports);
        if (options.report) {
          val.push(options.report);
        }
        if (options.report) {
          val.active = options.report.link;
        }
        if (options.reports) {
          val.active = options.node.reports.link;
        }
        val.active || (val.active = options.node.link);
      }
      return val;
    }
  });

}).call(this);
(function() {

  window.App.NodeView = Backbone.View.extend({
    el: '.js-view-container',
    initialize: function() {},
    activate: function(node) {
      this.node = node;
      this.node.facts.once("sync", this.render, this);
      return this.node.facts.fetch();
    },
    render: function() {
      return this.html('node/index', {
        node: this.node
      });
    }
  });

}).call(this);
(function() {

  window.App.NodeEventsView = Backbone.View.extend({
    el: '.js-view-container',
    initialize: function() {},
    activate: function(node, hash, nav) {
      var _this = this;
      this.hash = hash;
      this.node = node;
      this.nav = nav;
      return this.node.reports.fetch().then(function() {
        _this.report = _this.node.reports.findByHash(_this.hash);
        _this.report.events.once("sync", _this.render, _this);
        _this.report.events.fetch();
        return _this.nav.render({
          node: _this.node,
          report: _this.report
        });
      });
    },
    render: function() {
      return this.html('events/index', {
        report: this.report
      });
    }
  });

}).call(this);
(function() {
  var _this = this;

  window.App.NodeReportsView = Backbone.View.extend({
    el: '.js-view-container',
    initialize: function() {},
    activate: function(node) {
      this.node = node;
      this.stats = new App.NodeMonthlyStats({}, {
        node: this.node
      });
      this.node.reports.once("sync", this.render, this);
      this.stats.once("sync", this.addChart, this);
      return this.node.reports.fetch();
    },
    render: function() {
      this.html('reports/index', {
        node: this.node
      });
      this.node.reports.each(this.addOneReport);
      return this.stats.fetch();
    },
    addOneReport: function(report) {
      var view;
      view = new App.NodeReportView({
        model: report
      });
      return $("table tbody", _this.el).append(view.render().el);
    },
    addChart: function() {
      return new App.SummaryChart(this.stats.forChart(), 'node-reports-summary-chart');
    }
  });

  window.App.NodeReportView = Backbone.View.extend({
    tagName: "tr",
    initialize: function() {
      return this.model.on("change", this.render, this);
    },
    render: function() {
      this.html('reports/row', {
        report: this.model
      });
      return this;
    }
  });

}).call(this);
(function() {

  window.App.SearchView = Backbone.View.extend({
    el: '.js-view-container',
    initialize: function() {
      return $("body").on("submit", ".navigation .search form", this.navigate.bind(this));
    },
    navigate: function() {
      window.appRouter.navigate("/query/" + (this.query().val()), {
        trigger: true
      });
      return false;
    },
    activate: function(q) {
      this.collection = new App.QueryResourceCollection([], {
        query: q
      });
      this.collection.on("sync", this.render, this);
      this.collection.fetch();
      return this.query().val(q);
    },
    render: function() {
      return this.html('search/resources', {
        collection: this.collection
      });
    },
    query: function() {
      return $(".navigation .search input");
    }
  });

}).call(this);
(function() { this.JST || (this.JST = {}); this.JST["app/templates/dashboard/metrics"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<li>\n  Num nodes: ');
      
        __out.push(__sanitize(this.metrics.numNodes()));
      
        __out.push('\n</li>\n\n<li>\n  Num resources: ');
      
        __out.push(__sanitize(this.metrics.numResources()));
      
        __out.push('\n</li>\n\n<li>\n  Avg resources per node: ');
      
        __out.push(__sanitize(this.metrics.avgNumResources()));
      
        __out.push('\n</li>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() { this.JST || (this.JST = {}); this.JST["app/templates/dashboard/show"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
        var node, _i, _len, _ref;
      
        __out.push('<div id="node-reports-summary-chart" class=""></div>\n\n<table class="table table-striped table-nodes">\n  <thead>\n    <th>Node</th>\n    <th>Last report at</th>\n  </thead>\n  ');
      
        _ref = this.nodes.models;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          node = _ref[_i];
          __out.push('\n    <tr>\n      <td>\n        ');
          __out.push(__sanitize(this.linkTo(node)));
          __out.push('\n      </td>\n      <td>');
          __out.push(__sanitize(node.reportAt()));
          __out.push('</td>\n    </tr>\n  ');
        }
      
        __out.push('\n</table>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() { this.JST || (this.JST = {}); this.JST["app/templates/events/index"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
        var event, _i, _len, _ref;
      
        __out.push('<table class="table table-striped table-node-events">\n  <thead>\n    <tr>\n      <th>Status</th>\n      <th>Resource</th>\n      <th>Value</th>\n      <th>Message</th>\n      <th>At</th>\n    </tr>\n  </thead>\n  <body>\n    ');
      
        _ref = this.report.events.models;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          event = _ref[_i];
          __out.push('\n      <tr>\n        <td>');
          __out.push(__sanitize(this.eventStatusLabel(event.status)));
          __out.push('</td>\n        <td>');
          __out.push(__sanitize(this.truncate(event.resource)));
          __out.push('</td>\n        <td>');
          __out.push(__sanitize(this.truncate(event.newVal)));
          __out.push('</td>\n        <td>');
          __out.push(__sanitize(this.truncate(event.message)));
          __out.push('</td>\n        <td>');
          __out.push(__sanitize(event.timeAt));
          __out.push('</td>\n      </tr>\n    ');
        }
      
        __out.push('\n  </tbody>\n</table>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() { this.JST || (this.JST = {}); this.JST["app/templates/layout/navigation"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
        var value, _i, _len, _ref;
      
        __out.push('<ul class="navigation">\n  ');
      
        _ref = this.values;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          value = _ref[_i];
          __out.push('\n    <li class="');
          if (value.link === this.values.active) {
            __out.push(__sanitize("active"));
          }
          __out.push('">\n      ');
          if (value.link === this.values.active) {
            __out.push('\n        <span>');
            __out.push(__sanitize(value.name));
            __out.push('</span>\n      ');
          } else {
            __out.push('\n        ');
            __out.push(__sanitize(this.linkTo(value.name, value.link)));
            __out.push('\n      ');
          }
          __out.push('\n    </li>\n  ');
        }
      
        __out.push('\n  <li class="search">\n    <form>\n      <input type="text" name="query" value="" class="" placeholder="Search" />\n    </form>\n  </li>\n</ul>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() { this.JST || (this.JST = {}); this.JST["app/templates/node/index"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
        var fact, _i, _len, _ref;
      
        __out.push('<div class="node-facts-info">\n  <div class="node-info node-host-info">\n    <strong>');
      
        __out.push(__sanitize(this.node.fact("fqdn")));
      
        __out.push('</strong>\n    <strong>');
      
        __out.push(__sanitize(this.node.fact("ipaddress_eth0")));
      
        __out.push('</strong>\n    <small>Agent version ');
      
        __out.push(__sanitize(this.node.fact("clientversion")));
      
        __out.push('</small>\n    <small>');
      
        __out.push(__sanitize(this.node.fact("virtual")));
      
        __out.push('</small>\n  </div>\n\n  <div class="node-info node-cpu-info">\n    <strong>');
      
        __out.push(__sanitize(this.node.fact("physicalprocessorcount")));
      
        __out.push(' x ');
      
        __out.push(__sanitize(this.node.fact("processorcount")));
      
        __out.push(' CPU(s)</strong>\n    <strong>');
      
        __out.push(__sanitize(this.node.fact("memorytotal")));
      
        __out.push(' RAM</strong>\n    <small>');
      
        __out.push(__sanitize(this.truncate(this.node.fact("processor0"), 50)));
      
        __out.push('</small>\n    <small>');
      
        __out.push(__sanitize(this.node.fact("architecture")));
      
        __out.push('</small>\n  </div>\n\n  <div class="node-info node-kernel-info node-kernel-');
      
        __out.push(__sanitize(this.node.fact("kernel")));
      
        __out.push('-info">\n    <strong>');
      
        __out.push(__sanitize(this.node.fact("lsbdistdescription")));
      
        __out.push('</strong>\n    <small>');
      
        __out.push(__sanitize(this.node.fact("kernel")));
      
        __out.push(' ');
      
        __out.push(__sanitize(this.node.fact("kernelrelease")));
      
        __out.push('</small>\n    <small>Uptime ');
      
        __out.push(__sanitize(this.node.fact("uptime")));
      
        __out.push('</small>\n  </div>\n</div>\n\n<table class="table table-striped table-node-facts">\n  ');
      
        _ref = this.node.facts.models;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          fact = _ref[_i];
          __out.push('\n    <tr>\n      <td>');
          __out.push(__sanitize(fact.name));
          __out.push('</td>\n      <td>');
          __out.push(__sanitize(this.truncate(fact.value, 60)));
          __out.push('</td>\n    </tr>\n  ');
        }
      
        __out.push('\n</table>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() { this.JST || (this.JST = {}); this.JST["app/templates/reports/index"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<div id="node-reports-summary-chart" class=""></div>\n\n<table class="table table-striped table-node-reports">\n  <thead>\n    <th>Status</th>\n    <th>At</th>\n    <th>Version</th>\n    <th>Hash</th>\n    <th>Duration</th>\n  </thead>\n  <tbody>\n  </tbody>\n</table>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() { this.JST || (this.JST = {}); this.JST["app/templates/reports/row"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<td>');
      
        __out.push(__sanitize(this.reportSummary(this.report.summary())));
      
        __out.push('</td>\n<td>');
      
        __out.push(__sanitize(this.report.startAt()));
      
        __out.push('</td>\n<td>');
      
        __out.push(__sanitize(this.report.version));
      
        __out.push('</td>\n<td>');
      
        __out.push(__sanitize(this.linkTo(this.truncate(this.report.hash, 20), this.report.link)));
      
        __out.push('</td>\n<td>');
      
        __out.push(__sanitize(this.report.duration()));
      
        __out.push(' sec</td>\n\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() { this.JST || (this.JST = {}); this.JST["app/templates/search/resources"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
        var groupped, node, resource, _i, _j, _len, _len1, _ref, _ref1;
      
        groupped = this.collection.groupBy(function(i) {
          return i.node;
        });
      
        __out.push('\n');
      
        _ref = _.keys(groupped);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          node = _ref[_i];
          __out.push('\n  <h3>');
          __out.push(__sanitize(this.linkTo(node, "/nodes/" + node)));
          __out.push('</h3>\n  <table class="table table-striped table-query-resources">\n    ');
          _ref1 = groupped[node];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            resource = _ref1[_j];
            __out.push('\n      <tr>\n        <td>');
            __out.push(__sanitize(this.truncate(resource.name)));
            __out.push('</td>\n        <td>');
            __out.push(__sanitize(this.truncate(JSON.stringify(resource.parameters), 100)));
            __out.push('</td>\n      </tr>\n    ');
          }
          __out.push('\n  </table>\n');
        }
      
        __out.push('\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {

  window.App.Event = Backbone.Model.extend({
    initialize: function() {
      this.timestamp = Date.parse(this.get("timestamp"));
      this.timeAt = new Date(this.timestamp).toLocaleTimeString();
      this.message = this.get("message");
      this.newVal = this.get("new-value");
      this.resource = "" + (this.get("resource-type")) + "[" + (this.get("resource-title")) + "]";
      return this.status = this.get("status");
    }
  });

}).call(this);
(function() {

  window.App.Fact = Backbone.Model.extend({
    initialize: function() {
      this.name = this.get("name");
      return this.value = this.get("value");
    }
  });

}).call(this);
(function() {

  window.App.Metrics = Backbone.Model.extend({
    initialize: function() {},
    url: function() {
      return '/api/metrics';
    },
    numNodes: function() {
      return this.get("num_nodes");
    },
    numResources: function() {
      return this.get("num_resources");
    },
    avgResourcesPerNode: function() {
      return parseInt(this.get("avg_resources_per_node"));
    }
  });

}).call(this);
(function() {

  window.App.MonthlyStats = Backbone.Model.extend({
    initialize: function() {},
    url: function() {
      return '/api/stats/monthly';
    },
    forChart: function() {
      var rs;
      rs = {
        "days": [],
        "success": [],
        "failed": [],
        "requests": []
      };
      _.each(this.attributes, function(day) {
        var it, tm;
        tm = moment(day[0]).format("D MMM");
        rs.days.push(tm);
        it = day[1];
        rs.success.push(it.success);
        rs.failed.push(it.failed);
        return rs.requests.push(it.requests);
      });
      return rs;
    }
  });

  window.App.NodeMonthlyStats = Backbone.Model.extend({
    initialize: function(_unused, options) {
      return this.node = options.node;
    },
    url: function() {
      return "/api/nodes/" + this.node.name + "/stats/monthly";
    },
    forChart: function() {
      var rs;
      rs = {
        "days": [],
        "success": [],
        "failed": [],
        "duration": []
      };
      _.each(this.attributes, function(day) {
        var it, tm;
        tm = moment(day[0]).format("D MMM");
        rs.days.push(tm);
        it = day[1];
        rs.success.push(it.success);
        rs.failed.push(it.failed);
        if (it.requests === 0) {
          return rs.duration.push(0);
        } else {
          return rs.duration.push(it.duration / it.requests);
        }
      });
      return rs;
    }
  });

}).call(this);
(function() {

  window.App.Node = Backbone.Model.extend({
    initialize: function() {
      this.name = this.get("name");
      this.link = "/nodes/" + this.name;
      this.facts = new App.FactsCollection([], {
        node: this
      });
      return this.reports = new App.ReportsCollection([], {
        node: this
      });
    },
    reportAtTimestamp: function() {
      return Date.parse(this.get("report_timestamp"));
    },
    reportAt: function() {
      return new Date(this.reportAtTimestamp()).toLocaleString();
    },
    fact: function(name) {
      return this.facts.findByName(name).value;
    }
  });

}).call(this);
(function() {

  window.App.QueryResource = Backbone.Model.extend({
    initialize: function() {
      this.node = this.get("certname");
      this.parameters = this.get("parameters");
      this.type = this.get('type');
      this.title = this.get('title');
      return this.name = "" + this.type + "[" + this.title + "]";
    }
  });

}).call(this);
(function() {

  window.App.Report = Backbone.Model.extend({
    initialize: function() {
      this.hash = this.get("hash");
      this.version = this.get("configuration-version");
      this.link = "" + this.collection.link + "/" + this.hash;
      this.name = this.hash.substring(0, 6);
      return this.events = new App.EventsCollection([], {
        report: this
      });
    },
    startAtTimestamp: function() {
      return Date.parse(this.get("start-time"));
    },
    endAtTimestamp: function() {
      return Date.parse(this.get("end-time"));
    },
    startAt: function() {
      return new Date(this.startAtTimestamp()).toLocaleString();
    },
    duration: function() {
      return (this.endAtTimestamp() - this.startAtTimestamp()) / 1000;
    },
    summary: function() {
      return this.get("_summary");
    }
  });

}).call(this);
(function() {

  window.App.EventsCollection = Backbone.Collection.extend({
    model: App.Event,
    initialize: function(models, options) {
      this.report = options.report;
      this.link = this.report.link;
      return this.name = this.report.name;
    },
    url: function() {
      return this.report.collection.url() + ("/" + this.report.hash);
    },
    comparator: function(event) {
      return event.timestamp * -1;
    },
    summary: function() {
      var fun;
      if (_.isEmpty(this.models)) {
        return {};
      }
      fun = function(ac, it) {
        var _name;
        ac[_name = it.status] || (ac[_name] = 0);
        ac[it.status] += 1;
        return ac;
      };
      return _.reduce(this.models, fun, {});
    }
  });

}).call(this);
(function() {

  window.App.FactsCollection = Backbone.Collection.extend({
    model: App.Fact,
    initialize: function(models, options) {
      return this.node = options.node;
    },
    url: function() {
      return "/api/nodes/" + this.node.name + "/facts";
    },
    comparator: function(fact) {
      return fact.name;
    },
    findByName: function(name) {
      return this.where({
        name: name
      })[0];
    }
  });

}).call(this);
(function() {

  window.App.NodesCollection = Backbone.Collection.extend({
    model: App.Node,
    url: '/api/nodes',
    comparator: function(node) {
      return node.reportAtTimestamp() * -1;
    },
    findByName: function(name) {
      return this.where({
        name: name
      })[0];
    }
  });

}).call(this);
(function() {

  window.App.QueryResourceCollection = Backbone.Collection.extend({
    model: App.QueryResource,
    initialize: function(models, options) {
      return this.query = options.query;
    },
    url: function() {
      return "/api/query?resource=" + this.query;
    }
  });

}).call(this);
(function() {

  window.App.ReportsCollection = Backbone.Collection.extend({
    model: App.Report,
    initialize: function(models, options) {
      this.node = options.node;
      this.link = "" + this.node.link + "/reports";
      return this.name = "Reports";
    },
    url: function() {
      return "/api/nodes/" + this.node.name + "/reports";
    },
    comparator: function(report) {
      return report.startAtTimestamp() * -1;
    },
    findByHash: function(hash) {
      return this.where({
        hash: hash
      })[0];
    }
  });

}).call(this);
