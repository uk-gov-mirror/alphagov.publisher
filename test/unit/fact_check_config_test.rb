require "test_helper"
require "fact_check_config"

class FactCheckConfigTest < ActiveSupport::TestCase
  valid_address = "factcheck+1234@example.com"
  valid_address_pattern = "factcheck+{id}@example.com"
  valid_subjects = ["‘[Some title]’ GOV.UK preview of new edition [1234]",
                    "‘[Some title]’ GOV.UK preview of new edition [1234] - ticket #5678",
                    "I've edited the subject but left the ID at the end [1234]",
                    "I've edited the subject and appended something [1234] - ticket #2468"]
  valid_prefixed_subjects = valid_subjects.map { |subject| subject.gsub(/\[1234\]/, "[test-1234]") }

  should "fail on a nil address format" do
    assert_raises ArgumentError do
      FactCheckConfig.new(nil)
    end
  end

  should "fail on an empty address format" do
    assert_raises ArgumentError do
      FactCheckConfig.new("")
    end
  end

  should "fail on an address format with no ID marker" do
    assert_raises ArgumentError do
      FactCheckConfig.new("factcheck@example.com")
    end
  end

  should "accept an address format with an ID marker" do
    FactCheckConfig.new(valid_address_pattern)
  end

  should "fail on an address format with multiple ID markers" do
    assert_raises ArgumentError do
      FactCheckConfig.new("factcheck+{id}+{id}@example.com")
    end
  end

  should "recognise a valid fact check address" do
    config = FactCheckConfig.new(valid_address_pattern)
    assert config.valid_address?(valid_address)
  end

  should "not recognise an invalid fact check address" do
    config = FactCheckConfig.new(valid_address_pattern)
    assert_not config.valid_address?("not-factcheck@example.com")
  end

  should "not recognise a fact check address with an empty ID" do
    config = FactCheckConfig.new(valid_address_pattern)
    assert_not config.valid_address?("factcheck+@example.com")
  end

  should "extract an item ID from a valid address" do
    config = FactCheckConfig.new(valid_address_pattern)
    assert_equal "1234", config.item_id_from_address(valid_address)
  end

  should "raise an exception trying to extract an ID from an invalid address" do
    config = FactCheckConfig.new(valid_address_pattern)
    assert_raises ArgumentError do
      config.item_id_from_address("not-factcheck+1234@example.com")
    end
  end

  should "construct an address from an item ID" do
    config = FactCheckConfig.new(valid_address_pattern)
    assert_equal valid_address, config.address("1234")
  end

  should "accept item IDs that aren't strings" do
    # For example, Mongo IDs, but let's not tie this test to Mongo
    config = FactCheckConfig.new(valid_address_pattern)
    assert_equal valid_address, config.address(1234)
  end

  should "recognise a valid fact check subject" do
    config = FactCheckConfig.new(valid_address_pattern)
    valid_subjects.each do |valid_subject|
      assert config.valid_subject?(valid_subject)
    end
  end

  should "recognise a valid fact check subject with a prefix" do
    config = FactCheckConfig.new(valid_address_pattern, "test")
    valid_prefixed_subjects.each do |valid_prefixed_subject|
      assert config.valid_subject?(valid_prefixed_subject)
    end
    valid_subjects.each do |valid_subject|
      assert_not config.valid_subject?(valid_subject)
    end
  end

  should "not recognise an invalid fact check subject" do
    config = FactCheckConfig.new(valid_address_pattern)
    assert_not config.valid_subject?("Not a valid subject")
  end

  should "treat a subject prefixed with Re: as valid" do
    config = FactCheckConfig.new(valid_address_pattern)
    valid_subjects.each do |valid_subject|
      assert config.valid_subject?("Re: " + valid_subject)
    end
  end

  should "not recognise a fact check subject with an empty ID" do
    config = FactCheckConfig.new(valid_address_pattern)
    assert_not config.valid_subject?("Not a valid subject []")
  end

  should "extract an item ID from a valid subject" do
    config = FactCheckConfig.new(valid_address_pattern)
    valid_subjects.each do |valid_subject|
      assert_equal "1234", config.item_id_from_subject(valid_subject)
    end
  end

  should "raise an exception trying to extract an ID from an invalid subject" do
    config = FactCheckConfig.new(valid_address_pattern)
    assert_raises ArgumentError do
      config.item_id_from_subject("Not a valid subject (1234)")
    end

    assert_raises ArgumentError do
      config.item_id_from_subject("Not a valid subject [notHexadecimal]")
    end
  end

  should "raise an exception if there are multiple matches" do
    config = FactCheckConfig.new(valid_address_pattern)
    valid_subjects.each do |valid_subject|
      assert_equal false, config.valid_subject?(valid_subject + " [5678]")

      assert_raises ArgumentError do
        config.item_id_from_subject(valid_subject + " [5678]")
      end
    end
  end
end
