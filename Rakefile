load "scraper.rb"

@scraper = Scraper.new

@location = File.dirname(__FILE__)

desc "Populates the database with updated valuations every hour"
task :cron => :enviroment do
  @scrapper.go
end 
