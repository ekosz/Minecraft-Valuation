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

  ###### LOAD CONSTANTS ########
  yml_location = File.dirname(__FILE__) + '/config/constants.yml'
  constants = YAML::load_file(yml_location)

  @rent = constants['rent']
  @office_space = constants['office_space']
  @rent_cost = @rent * @office_space
  @salary = constants['salary']
  @employees = constants['employees']
  @salary_cost = @salary * @employees
  @misc_sga = constants['misc_sga']
  @networking = constants['networking']
  @legal = constants['legal']
  @legal_cost = (@salary_cost * (5.0/3.0)).to_i + @legal
  @supplies = constants['supplies']
  @multi = constants['multi']
  @since = constants['since']

  @sga = @rent_cost + @salary_cost + @networking + @legal_cost + @supplies + @misc_sga
  

  ###### LOAD VERIBLES FROM DATABASE #######
  db_location = File.dirname(__FILE__) + '/config/database.yml'
  db_config = YAML::load_file(db_location)['production']

  conn = PGconn.open(db_config['host'], 5432, nil, nil, db_config['database'], db_config['username'], db_config['password'])

  sql = "SELECT players, exchange_rate, created_at FROM data ORDER BY data_id DESC LIMIT 1"

  sql_avg = "SELECT avg(players) FROM data"

  values = conn.exec(sql)
  avg_res = conn.exec(sql_avg)

  conn.finish

  ###### CALCULATE VALUATION ######
  @players = values[0]['players'].to_i
  @top_line = (@players * 9.4 * 365).to_i 
  avg = ((avg_res[0]['avg'].to_f * 9.4 * 365).to_i - @sga) * @multi
  eu_value = (@top_line - @sga) * @multi
  us_value = (eu_value * values[0]['exchange_rate'].to_f).to_i
  @last = values[0]['created_at']

  ###### MAKE SOME NUMBERS READABLE ########
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
