# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module SitemapGenerator
    # This is the engine that runs on the public interface of sitemap_generator.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::SitemapGenerator

      routes do
        # Add engine routes here
        # resources :sitemap_generator
        # root to: "sitemap_generator#index"
      end

      initializer "decidim_sitemap_generator.assets" do |app|
        app.config.assets.precompile += %w[decidim_sitemap_generator_manifest.js decidim_sitemap_generator_manifest.css]
      end
    end
  end
end
