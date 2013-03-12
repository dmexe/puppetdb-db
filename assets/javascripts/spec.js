//= require vendor/jasmine
//= require vendor/jasmine-html
//= require vendor/console-runner
//= require application
//
//= require_tree ./spec
//= require_self

(function() {
    $("body > .container").hide();

    var jasmineEnv = jasmine.getEnv();
    jasmineEnv.updateInterval = 250;

    var htmlReporter = new jasmine.HtmlReporter();
    jasmineEnv.addReporter(htmlReporter);

    window.console_reporter = new jasmine.ConsoleReporter({ print: console.log });
    jasmine.getEnv().addReporter(console_reporter);

    jasmineEnv.specFilter = function(spec) {
      return htmlReporter.specFilter(spec);
    };

    var currentWindowOnload = window.onload;
    window.onload = function() {
      if (currentWindowOnload) {
        currentWindowOnload();
      }

      execJasmine();
    };

    function execJasmine() {
      jasmineEnv.execute();
    }
})();
