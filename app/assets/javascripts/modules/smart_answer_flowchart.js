//= require mermaid/dist/mermaid
(function (Modules) {
  'use strict'
  Modules.SmartAnswerFlowchart = function () {
    this.start = function (element) {
      mermaid.initialize({ startOnLoad: true, flowchart: { useMaxWidth: false }});
    }
  }
})(window.GOVUKAdmin.Modules)
