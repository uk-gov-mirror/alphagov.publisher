module Editionable
  extend ActiveSupport::Concern

  included do
    has_one :edition, as: :editionable, touch: true
    validates_with LinkValidator, on: :update
    validates_with SafeHtml
  end
end
