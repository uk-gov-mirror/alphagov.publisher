//= require mermaid/dist/mermaid
(function (Modules) {
  'use strict'
  Modules.SmartAnswerFlowchart = function () {
    this.start = function (element) {
      var diagram = element.find('.flowchart');
      var flowchart__loading = element.find('.flowchart__loading');

      mermaid.initialize({ startOnLoad: true, flowchart: { useMaxWidth: false }});

      setTimeout(() => {
        diagram.removeClass('flowchart--hidden')
        flowchart__loading.addClass('flowchart__loading--hidden')
      },
        100);
    }
  }
})(window.GOVUKAdmin.Modules)
