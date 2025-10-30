'use strict'

window.GOVUK = window.GOVUK || {}
window.GOVUK.analyticsGa4 = window.GOVUK.analyticsGa4 || {}
window.GOVUK.analyticsGa4.analyticsModules = window.GOVUK.analyticsGa4.analyticsModules || {}

;(function (Modules) {
  function Ga4FormSetup() {}

  Ga4FormSetup.prototype.init = function () {
    var forms

    const modules = document.querySelectorAll(
      "[data-module~='ga4-form-setup']"
    )

    Array.from(modules).map((module) => {
      forms = module.querySelectorAll('form')
    })

    Array.from(forms).map((form) => {
      this.addDataAttributes(form)
      this.callFormChangeTracker(form)
    })
  }

  Ga4FormSetup.prototype.addDataAttributes = function(form) {
    var eventData = {
      event_name: "form_response",
      type: "edit",
      section: "Edit publication",
      action: "Save",
      tool_name: "publisher"
    }

    form.setAttribute('data-ga4-form-change-tracking', '')
    form.setAttribute('data-ga4-form-record-json', '')
    form.setAttribute('data-ga4-form', JSON.stringify(eventData))
    form.setAttribute('data-ga4-form-use-text-count', '')
  }

  Ga4FormSetup.prototype.callFormChangeTracker = function (form) {
    const ga4FormTracker = new window.GOVUK.Modules.Ga4FormChangeTracker(form)

    ga4FormTracker.init()
  }

  Modules.Ga4FormSetup = Ga4FormSetup
})(window.GOVUK.Modules)
