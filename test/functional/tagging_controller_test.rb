# frozen_string_literal: true
require "test_helper"

class TaggingControllerTest < ActionController::TestCase
  def setup
    @edition = FactoryBot.create(:edition, :draft)
    stub_linkables_with_data
  end

  def teardown
    # Do nothing
  end

  context "#breadcrumb" do
    context "user is an editor" do
      setup do
        login_as_stub_user
      end

      should "render the 'Set GOV.UK breadcrumb' page if the user is a govuk_editor" do
        get :breadcrumb, params: { id: @edition.id }

        assert_template "secondary_nav_tabs/tagging_breadcrumb_page"

        assert_select "h1", text: "Set GOV.UK breadcrumb"
        assert_select "h2", text: "Benefits"
        assert_select "label", text: "Benefits and financial support for families (draft)"
        assert_select "h2", text: "Tax"
        assert_select "label", text: "RTI (draft)"
        assert_select "button", text: "Save"
        assert_select "a", text: "Cancel"
      end

      should "render the 'Set GOV.UK breadcrumb' page if the user is a Welsh editor and the edition is Welsh" do
        login_as_welsh_editor
        welsh_edition = FactoryBot.create(:edition, :fact_check, :welsh)

        get :breadcrumb, params: { id: welsh_edition.id }

        assert_template "secondary_nav_tabs/tagging_breadcrumb_page"
      end

      should "render the tagging tab and display an error message if an error occurs during the request" do
        Tagging::GovukBreadcrumb.stubs(:build_from_publishing_api).raises(StandardError)

        get :breadcrumb, params: { id: @edition.id }

        assert_redirected_to tagging_edition_path(@edition)
        assert_equal "Due to a service problem, the request could not be made", flash[:danger]
      end
    end

    should "render an error message if the user is not a govuk_editor" do
      user = FactoryBot.create(:user)
      login_as(user)

      get :breadcrumb, params: { id: @edition.id }

      assert_equal "You do not have correct editor permissions for this action.", flash[:danger]
    end

    should "render an error message if the user is a Welsh editor and the edition is not Welsh" do
      login_as_welsh_editor

      get :breadcrumb, params: { id: @edition.id }

      assert_equal "You do not have correct editor permissions for this action.", flash[:danger]
    end
  end
end
