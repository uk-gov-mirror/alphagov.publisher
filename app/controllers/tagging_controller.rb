# frozen_string_literal: true

class TaggingController < InheritedResources::Base
  # TODO: set permissions on actions
  layout "design_system"

  defaults resource_class: Edition, collection_name: "editions", instance_name: "resource"

  before_action only: %i[breadcrumb] do
    require_editor_permissions
  end

  SERVICE_REQUEST_ERROR_MESSAGE = "Due to a service problem, the request could not be made".freeze

  def breadcrumb
    linkables = Tagging::Linkables.new
    @radio_groups = build_radio_groups_for_tagging_govuk_breadcrumb_page(linkables, get_govuk_breadcrumb_from_publishing_api(resource))
    @govuk_breadcrumb = get_govuk_breadcrumb_from_publishing_api(resource)
    render "editions/secondary_nav_tabs/tagging_breadcrumb_page"
  rescue StandardError => e
    Rails.logger.error "Error #{e.class} #{e.message}"
    flash[:danger] = SERVICE_REQUEST_ERROR_MESSAGE
    redirect_to tagging_edition_path(resource)
  end

  def update_breadcrumb
    @govuk_breadcrumb = get_govuk_breadcrumb_from_publishing_api(resource)
    breadcrumb = update_breadcrumb_params
    update_form = Tagging::TaggingUpdateForm.build_from_publishing_api(resource.artefact.content_id, resource.artefact.language)
    update_form.parent = breadcrumb
    update_form.publish!
    redirect_to tagging_edition_path(resource)
  end

private
  def build_radio_groups_for_tagging_govuk_breadcrumb_page(linkables, current_breadcrumb)
    linkables.mainstream_browse_pages.map do |k, v|
      {
        heading: k,
        items: v.map do |item|
          {
            text: item.first.split(" / ").last,
            value: item.last,
            checked: current_breadcrumb.breadcrumb&.include?(item.last),
          }
        end,
      }
    end
  end

  def get_govuk_breadcrumb_from_publishing_api(edition)
    Tagging::GovukBreadcrumb.build_from_publishing_api(edition)
  end

  def update_breadcrumb_params
    params.require(
      :govuk_breadcrumb,
    )
  end
end
