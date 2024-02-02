require "integration_test_helper"

class DowntimeIntegrationTest < JavascriptIntegrationTest
  setup do
    setup_users

    @edition = FactoryBot.create(
      :transaction_edition,
      :published,
      title: "Apply to become a driving instructor",
      slug: "apply-to-become-a-driving-instructor",
    )

    WebMock.reset!
    stub_any_publishing_api_put_content
    stub_any_publishing_api_publish

    test_strategy = Flipflop::FeatureSet.current.test!
    test_strategy.switch!(:design_system_downtime_index_page, true)
    test_strategy.switch!(:design_system_downtime_new, true)
  end

  test "Scheduling new downtime" do
    DowntimeScheduler.stubs(:schedule_publish_and_expiry)

    visit root_path
    click_link "Downtime"
    click_link "Add downtime"

    enter_start_time first_of_july_next_year_at_midday_bst
    enter_end_time first_of_july_next_year_at_six_pm_bst

    #assert_match("midday to 6pm on #{day} 1 July", page.find_field("Message").value)
    click_button "Save"
    puts page.html
    assert page.has_content?("downtime message scheduled") , page.html
    assert page.has_content?("Scheduled downtime")
    assert page.has_content?("midday to 6pm on 1 July")
  end


  def enter_start_time(start_time)
    complete_date_inputs("From date", start_time)
    complete_time_inputs("From time", start_time)
  end

  def enter_end_time(end_time)
    complete_date_inputs("To date", end_time)
    complete_time_inputs("To time", end_time)

  end

  def complete_date_inputs(fieldset_legend, time)
    within_fieldset(fieldset_legend) do
      fill_in 'Day', with: time.day.to_s
      fill_in 'Month', with: time.month.to_s
      fill_in 'Year', with: time.year.to_s
    end
  end

  def complete_time_inputs(fieldset_legend, time)
    within_fieldset(fieldset_legend) do
      fill_in 'Hour', with: time.hour.to_s
      fill_in 'Minute', with: time.min.to_s
    end
  end

  def next_year
    Time.zone.now.next_year.year
  end

  def date_in_the_past
    Time.zone.local(Time.zone.now.last_year.year, 1, 1, 12, 0)
  end

  def first_of_july_next_year_at_midday_bst
    Time.zone.local(next_year, 7, 1, 12, 0)
  end

  def first_of_july_next_year_at_six_pm_bst
    Time.zone.local(next_year, 7, 1, 18, 0)
  end

  def first_of_july_next_year_at_nine_thirty_pm_bst
    Time.zone.local(next_year, 7, 1, 21, 30)
  end

  def day
    first_of_july_next_year_at_six_pm_bst.strftime("%A")
  end

  def create_downtime
    Downtime.create!(
      artefact: @edition.artefact,
      start_time: first_of_july_next_year_at_midday_bst,
      end_time: first_of_july_next_year_at_six_pm_bst,
      message: "foo",
    )
  end

  def assert_no_downtime_scheduled
    assert_equal 0, Downtime.count
  end
end
