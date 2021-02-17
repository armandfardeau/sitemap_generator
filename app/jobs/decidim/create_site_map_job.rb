# frozen_string_literal: true

require 'rubygems'
require 'sitemap_generator'

module Decidim
  class CreateSiteMapJob < ApplicationJob
    include Rails.application.routes.mounted_helpers

    queue_as :scheduled

    def perform(_organization_id)
      ::SitemapGenerator::Sitemap.default_host = default_host
      ::SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/#{site_map_host}"

      site_map = ::SitemapGenerator::Sitemap.create(compress: :all_but_first)
      site_map.add '/'

      participatory_processes_content.each do |content, lastmod,|
        site_map.add content, lastmod
      end

      components_content.each do |content, lastmod,|
        site_map.add content, lastmod
      end

      static_pages_content.each do |content, lastmod,|
        site_map.add content, lastmod
      end

      Decidim::PingSearchEngineJob.perform_later(url)
    end

    private

    #
    # ParticipatoryProcesses
    #
    def participatory_processes
      @participatory_processes ||= Decidim::ParticipatoryProcess.where(organization: organization).select(&:visible?)
    end

    def participatory_processes_path(process)
      Decidim::EngineRouter.main_proxy(process).participatory_process_path(process)
    end

    def participatory_processes_content
      participatory_processes.map do |process|
        [
            participatory_processes_path(process),
            lastmod: process.updated_at
        ]
      end
    end

    #
    # Components
    #
    def components
      @components ||= Decidim::Component.where(participatory_space: participatory_processes).published
    end

    def components_path(component)
      Decidim::EngineRouter.main_proxy(component).root_path
    end

    def components_content
      components.map do |component|
        [
            components_path(component),
            lastmod: component.updated_at
        ]
      end
    end

    #
    # StaticPages
    #
    def static_pages
      @static_pages ||= Decidim::StaticPage.where(organization: organization)
    end

    def static_pages_path(static_page)
      Decidim::Core::Engine.routes.url_helpers.page_path(static_page)
    end

    def static_pages_content
      static_pages.map do |static_page|
        [
            static_pages_path(static_page),
            lastmod: static_page.updated_at
        ]
      end
    end

    #
    # Organization
    #
    def organization
      @organization ||= Decidim::Organization.find(@arguments.first)
    end

    def site_map_host
      organization.host
    end

    def default_host
      "https://#{site_map_host}"
    end

    def url
      "#{default_host}/sitemap.xml"
    end
  end
end
