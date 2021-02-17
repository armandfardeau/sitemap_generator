# frozen_string_literal: true

require 'rubygems'
require 'sitemap_generator'

module Decidim
  class CreateSiteMapJob < ApplicationJob
    include Rails.application.routes.mounted_helpers

    # Option is a float between 1.0 and 0.1
    PRIORITY = {
      participatory_processes_content: 0.5,
      components_content: 0.4,
      static_pages_content: 0.3,
      resources_content: 0.2
    }.freeze

    # Options are 'always', 'hourly', 'daily', 'weekly', 'monthly', 'yearly' or 'never'
    CHANGEFREQ = {
      participatory_processes_content: 'monthly',
      components_content: 'weekly',
      static_pages_content: 'monthly',
      resources_content: 'daily'
    }.freeze

    queue_as :scheduled

    def perform(_organization_id)
      ::SitemapGenerator::Sitemap.default_host = default_host
      ::SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/#{site_map_host}"

      site_map = ::SitemapGenerator::Sitemap.create(compress: :all_but_first)
      site_map.add '/'

      participatory_processes_content.each do |content, opts|
        site_map.add content, opts
      end

      components_content.each do |content, opts|
        site_map.add content, opts
      end

      static_pages_content.each do |content, opts|
        site_map.add content, opts
      end

      resources_content.each do |content, opts|
        site_map.add content, opts
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
          {
            lastmod: process.updated_at,
            priority: PRIORITY[:participatory_processes_content],
            changefreq: CHANGEFREQ[:participatory_processes_content]
          }
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
          {
            lastmod: component.updated_at,
            priority: PRIORITY[:components_content],
            changefreq: CHANGEFREQ[:components_content]
          }
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
          {
            lastmod: static_page.updated_at,
            priority: PRIORITY[:static_pages_content],
            changefreq: CHANGEFREQ[:static_pages_content]
          }
        ]
      end
    end

    #
    # Resources
    #
    def resources
      @resources ||= model_class_names.flat_map do |model_class_name|
        klass = model_class_name.constantize
        next unless klass.respond_to? :published

        klass.where(component: [components])
             .published
             .not_hidden
      end.compact
    end

    def model_class_names
      @model_class_names ||= Decidim.resource_registry.manifests.map(&:model_class_name) - excluded_class_names
    end

    def excluded_class_names
      %w[Decidim::Comments::Comment Decidim::UserGroup Decidim::User Decidim::ParticipatoryProcess Decidim::ParticipatoryProcessGroup Decidim::Assembly]
    end

    def resources_path(resource)
      Decidim::ResourceLocatorPresenter.new(resource).path
    end

    def resources_content
      resources.map do |resource|
        [
          resources_path(resource),
          {
            lastmod: resource.updated_at,
            priority: PRIORITY[:resources_content],
            changefreq: CHANGEFREQ[:resources_content]
          }
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
