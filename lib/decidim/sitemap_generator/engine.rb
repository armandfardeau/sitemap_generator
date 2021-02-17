# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module SitemapGenerator
    # This is the engine that runs on the public interface of sitemap_generator.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::SitemapGenerator

      routes do
        get "/sitemap.xml", to: "site_map#index", as: :site_map
      end

      initializer "decidim_sitemap_generator.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::SitemapGenerator::Engine, at: "/", as: "decidim_sitemap_generator"
        end
      end

      initializer "decidim_sitemap_generator.assets" do |app|
        app.config.assets.precompile += %w[decidim_sitemap_generator_manifest.js decidim_sitemap_generator_manifest.css]
      end
    end
  end
end
