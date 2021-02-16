# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/sitemap_generator/version"

Gem::Specification.new do |s|
  s.version = Decidim::SitemapGenerator.version
  s.authors = ["Armand Fardeau"]
  s.email = ["fardeauarmand@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-sitemap_generator"
  s.required_ruby_version = ">= 2.6"

  s.name = "decidim-sitemap_generator"
  s.summary = "A decidim sitemap_generator module"
  s.description = "A sitemap generator for Decidim."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::SitemapGenerator.version
  s.add_dependency "sitemap_generator", "~>6.1.2"
  s.add_development_dependency "decidim-dev", Decidim::SitemapGenerator.version
end
