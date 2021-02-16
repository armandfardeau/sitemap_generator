# frozen_string_literal: true

module Decidim
  module SitemapGenerator
    # This is the engine that runs on the public interface of `SitemapGenerator`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::SitemapGenerator::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :sitemap_generator do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "sitemap_generator#index"
      end

      def load_seed
        nil
      end
    end
  end
end
