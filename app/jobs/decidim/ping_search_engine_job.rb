module Decidim
  class PingSearchEngineJob < ApplicationJob
    queue_as :scheduled

    def perform
      ::SitemapGenerator::Sitemap.ping_search_engines
    end
  end
end
