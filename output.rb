# coding: utf-8

require 'yaml'
require 'sinatra'
require 'haml'
require 'sass'
require 'pg'

enable :run
set :views, File.dirname(__FILE__) + '/views'
set :public, File.dirname(__FILE__) + '/static'

def number_with_delimiter(number, delimiter=",")
  number.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
end

def start_up
  yml_location = File.dirname(__FILE__) + '/config/constants.yml'
  constants = YAML::load_file(yml_location)
  
  db_location = File.dirname(__FILE__) + '/config/database.yml'
  db_config = YAML::load_file(db_location)['production']

  conn = PGconn.open(db_config['host'], 5432, nil, nil, db_config['database'], db_config['username'], db_config['password'])
  sql = "SELECT * FROM data ORDER BY timestamp DESC LIMIT 1"
  values = conn.exec(sql)

  eu_value = values[0]['eu_value']
  us_value = values[0]['us_value']
  avg = values[0]['average']

  @last = values[0]['timestamp']
  @since = constants['since']

  @eu_value = '€' + number_with_delimiter(eu_value)
  @us_value = '$' + number_with_delimiter(us_value)
  @avg_value = '€' + number_with_delimiter(avg)

end

set :haml, {:format => :html5 }

get '/' do
  start_up
  haml :index
end

get '/css/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :style
end  

get '/css/handheld.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :handheld
end

not_found do
  haml :four04
end
