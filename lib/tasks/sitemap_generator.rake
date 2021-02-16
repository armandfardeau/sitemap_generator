namespace :sitemap_generator do
  desc "TODO"
  task enqueue: :environment do
    Decidim::EnqueueSiteMapJob.perform_later
  end

  desc "TODO"
  task :create, [:id] => :environment do |_task, args|
    raise ArgumentError if args.id.nil?

    Decidim::CreateSiteMapJob.perform_later(args.id)
  end

  desc "TODO"
  task ping: :environment do
    Decidim::PingSearchEngineJob.perform_later
  end

end
