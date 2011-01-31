require 'open-uri'
require 'hpricot'
require "cgi"
require "uri"
require "net/https"
require 'xmlsimple'
require 'yaml'
require 'pg'
require 'pony'

class Scraper

  def go
    start
  end

  private

  def curr_exchange_rate
    url = URI.parse("http://api.finance.xaviermedia.com/api/latest.xml")

    resp = Net::HTTP.get(url)
    xml  = XmlSimple.xml_in(resp)

    return xml['exchange_rates'][0]['fx'][1]['rate'][0].to_f
  end

  def start

    ###### PARSE MINECRAFT SITE ######
    doc = open("http://www.minecraft.net/stats.jsp") { |f| Hpricot(f) }

    @text = (doc/"/html/body/div[1]/div[3]/div[1]/div[1]/p[1]").inner_html

    if (@text =~ /(\d+) people bought/)
      @players = $1.to_i
    else
      puts "Could not find string"
      Pony.mail(:to => 'ekoslow@gmail.com', :from => 'info@whatsminecraftsvalue.com', :subject => 'Warning!', :body => 'The minecraft stats page has changed!', :via => :smtp, :via_options => {
        :address        => "smtp.sendgrid.net",
        :port           => "25",
        :authentication => :plain,
        :user_name      => ENV['SENDGRID_USERNAME'],
        :password       => ENV['SENDGRID_PASSWORD'],
        :domain         => ENV['SENDGRID_DOMAIN']
      })

      return
    end

    ###### INSERT VARIBLES INTO DATABASE ######
    sql = "INSERT INTO data (players, exchange_rate, created_at) VALUES ($1, $2, now())"

    db_location = File.dirname(__FILE__) + '/config/database.yml'
    db_config = YAML::load_file(db_location)['production']
    conn = PGconn.open(db_config['host'], 5432, nil, nil, db_config['database'], db_config['username'], db_config['password'])

    conn.exec(sql, [@players, curr_exchange_rate])

    conn.finish

  end
end
