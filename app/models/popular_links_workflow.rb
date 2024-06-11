require "state_machines-mongoid"

module PopularLinksWorkflow
  class CannotDeletePublishedPublication < RuntimeError; end

  extend ActiveSupport::Concern
  included do

    before_save :denormalise_users!

    field :state, type: String, default: "draft"
    belongs_to :assigned_to, class_name: "User", optional: true

    state_machine initial: :draft do
      event :publish do
        transition draft: :published
      end
    end
  end

  def status_text
    text = human_state_name.capitalize
    text += " on #{publish_at.strftime('%d/%m/%Y %H:%M')}" if scheduled_for_publishing?
    text
  end

  def denormalise_users!
    new_assignee = assigned_to.try(:name)
    set(assignee: new_assignee) unless new_assignee == assignee
    update_user_action("creator", [Action::CREATE, Action::NEW_VERSION])
    update_user_action("publisher", [Action::PUBLISH])
    update_user_action("archiver", [Action::ARCHIVE])
    self
  end

  def in_progress?
    !%w[published].include? state
  end

  private

  def update_user_action(property, statuses)
    actions.where(:request_type.in => statuses).limit(1).each do |action|
      if action.requester
        set(property => action.requester.name)
      end
    end
  end

  def disallowable_change?
    allowed_to_change = %w[publish_at]
    (changes.keys - allowed_to_change).present?
  end
end
