require "test_helper"

class HomepageControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "#show" do
    setup do
      @popular_links = FactoryBot.create(:popular_links)
    end

    should "return last popular links" do
      get :show

      assert_response :ok
    end
  end
end
