window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}

describe('GA4FormSetup', function () {
  'use strict'

  var module, ga4FormSetup

  beforeEach(function () {
    var moduleHtml =
      `<div data-module="ga4-form-setup">
        <form></form>
      </div>`

    module = document.createElement('div')
    module.innerHTML = moduleHtml
    document.body.appendChild(module)

    ga4FormSetup = new window.GOVUK.Modules.Ga4FormSetup
    ga4FormSetup.init()
  })

  afterEach(function () {
    document.body.removeChild(module)
  })

  describe('when loaded', function () {
    // TODO: make this test work
    xit('starts the FormTracker module', function () {
      var ga4FormTrackerSpyInit = spyOn(new window.GOVUK.Modules.Ga4FormTracker, 'init')

      expect(ga4FormTrackerSpyInit).toHaveBeenCalled()
    })

    it('adds the correct parameters to the form', function() {
      var form = module.querySelector('form')
      var formGA4Data = form.dataset
      var formEventData = JSON.parse(formGA4Data.ga4Form)

      console.log('formGA4Data: ', formGA4Data.ga4FormChangeTracking)
      console.log('formEventData: ', formEventData)

      expect(formEventData.action).toBe("Save")
      expect(formEventData.event_name).toBe("form_response")
      expect(formEventData.section).toBe("Edit publication")
      expect(formEventData.tool_name).toBe("publisher")
      expect(formEventData.type).toBe("edit")
      expect(Object.keys(formGA4Data)).toContain('ga4FormChangeTracking');
      expect(Object.keys(formGA4Data)).toContain('ga4FormRecordJson');
      expect(Object.keys(formGA4Data)).toContain('ga4FormUseTextCount');
    })
  })
})
