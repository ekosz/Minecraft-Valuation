load "scraper.rb"

@scraper = Scraper.new

desc "Populates the database with updated valuations every hour"
task :cron do
  Scraper.new.go
end

