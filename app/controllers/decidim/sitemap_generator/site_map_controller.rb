# frozen_string_literal: true

module Decidim
  module SitemapGenerator
    class SiteMapController < Decidim::SitemapGenerator::ApplicationController
      def index
        raise ActionController::RoutingError, 'Not Found' unless File.file?(sitemap_file)

        render plain: file, layout: false, content_type: "application/xml", encoding: "UTF-8", status: 200
      end

      private

      def file
        File.read(sitemap_file)
      end

      def sitemap_file_exists?
        File.file?(sitemap_file)
      end

      def sitemap_file
        Rails.root.join('public', 'sitemaps', current_organization.host, 'sitemap.xml')
      end
    end
  end
end
