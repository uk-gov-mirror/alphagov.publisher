require_dependency "popular_links_workflow"

class PopularLinksEdition
  include Mongoid::Document
  include Mongoid::Timestamps
  include RecordableActions
  include PopularLinksWorkflow

  field :link_items, type: Array
  field :version_number,       type: Integer,  default: 1
  field :title,                type: String
  field :created_at,           type: DateTime, default: -> { Time.zone.now }
  field :publish_at,           type: DateTime
  field :auth_bypass_id,       type: String, default: -> { SecureRandom.uuid }
  field :creator,              type: String
  field :assignee,             type: String

  scope :assigned_to,
        lambda { |user|
          if user
            where(assigned_to_id: user.id)
          else
            where(:assigned_to_id.exists => false)
          end
        }

  belongs_to :assigned_to, class_name: "User", optional: true

  validate :six_link_items_present?
  validate :all_urls_and_titles_are_present?

  def six_link_items_present?
    errors.add(:link_items, "Has to be 6 link items") if link_items.count != 6
  end

  def all_urls_and_titles_are_present?
    link_items.each_with_index do |item, index|
      errors.add(:item, "A URL is required for Link #{index + 1}") unless item.key?(:url)
      errors.add(:item, "A Title is required for Link #{index + 1}") unless item.key?(:title)
    end
  end
end
