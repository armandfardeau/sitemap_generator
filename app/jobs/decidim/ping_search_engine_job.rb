module Decidim
  class PingSearchEngineJob < ApplicationJob
    queue_as :scheduled

    def perform(url)
      ::SitemapGenerator::Sitemap.ping_search_engines(url)
    end
  end
end
