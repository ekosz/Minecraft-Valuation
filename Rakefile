load "scraper.rb"

@scraper = Scraper.new

desc "Populates the database with updated valuations every hour"
task :cron => :environment do
  @scrapper.go
end

