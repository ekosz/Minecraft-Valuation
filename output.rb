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

  sql = "SELECT players, exchange_rate, created_at, extract(epoch FROM created_at) FROM data ORDER BY data_id DESC LIMIT 720"

  sql_avg = "SELECT avg(players) FROM data"

  values = conn.exec(sql)
  avg_res = conn.exec(sql_avg)

  conn.finish

  ###### CALCULATE VALUATION ######
  @players = values[0]['players'].to_i
  @top_line = (@players * 9.4 * 365).to_i 
  @avg = ((avg_res[0]['avg'].to_f * 9.4 * 365).to_i - @sga) * @multi
  eu_value = (@top_line - @sga) * @multi
  us_value = (eu_value * values[0]['exchange_rate'].to_f).to_i
  @last = values[0]['created_at']

  ###### CREATE DATA FOR JAVASCRIPT GRAPH ######
  data_array = []
  values.each do |value|
    data_array << [value['date_part'].to_i*1000, (((value['players'].to_i*9.4*365).to_i-@sga)*@multi)/1000000]
  end
  @js_data = data_array.reverse.inspect
  @begining = data_array[0][0]
  @ending = data_array[-1][0] 

  ###### MAKE SOME NUMBERS READABLE ########
  @eu_value = '€' + number_with_delimiter(eu_value)
  @us_value = '$' + number_with_delimiter(us_value)
  @avg_value = '€' + number_with_delimiter(@avg)

end

set :haml, {:format => :html5 }

get '/' do
  headers['Cache-Control'] = 'public, max-age=1800'
  start_up
  haml :index
end

get '/css/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  headers['Cache-Control'] = 'public, max-age=1800'
  sass :style
end  

get '/css/handheld.css' do
  content_type 'text/css', :charset => 'utf-8'
  headers['Cache-Control'] = 'public, max-age=1800'
  sass :handheld
end

not_found do
  haml :four04
end
