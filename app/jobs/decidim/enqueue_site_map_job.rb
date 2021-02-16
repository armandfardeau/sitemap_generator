module Decidim
  class EnqueueSiteMapJob < ApplicationJob
    queue_as :scheduled

    def perform
      organizations.each do |organization|
        Decidim::CreateSiteMapJob.perform_later(organization.id)
      end
    end

    def organizations
      @organizations ||= Decidim::Organization.find_each
    end
  end
end
