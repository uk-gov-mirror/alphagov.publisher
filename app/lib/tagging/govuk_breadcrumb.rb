# frozen_string_literal: true

module Tagging
  class GovukBreadcrumb
    include ActiveModel::Model
    attr_accessor :breadcrumb

    def self.build_from_publishing_api(edition)
      link_set = LinkSet.find(edition.artefact.content_id, edition.artefact.language)

      new(
        breadcrumb: link_set.links["parent"],
      )
    end
  end
end
