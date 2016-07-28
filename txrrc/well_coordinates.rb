#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# TEXAS Well Coordinates Scraper

# while true; do ./well_coordinates.rb & sleep 10; done

# API=00932157
# URL => http://wwwgisp.rrc.state.tx.us/arcgis/rest/services/rrc_public/RRC_GIS_Viewer/MapServer/0/query?where=API%3D%2707901027%27&outSR=4269&f=pjson

# API in ('07901027','00100845','00100887')
# URL => http://wwwgisp.rrc.state.tx.us/arcgis/rest/services/rrc_public/RRC_GIS_Viewer/MapServer/0/query?where=API%20in%20%28%2707901027%27%2C%2700100845%27%2C%2700100887%27%29&outSR=4269&f=pjson


# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require 'rubygems'
require 'mechanize'
require 'json'

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'txrrc_coordinate_scrapes'
require mappings_directory + 'txrrc_well_coordinates'

begin # begin error trapping

  start_time = Time.now  

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  agent_proxies =  [ ['165.139.149.169',3128], ['165.2.139.51',80], ['199.189.80.13',8080], ['97.77.104.22',80], ['50.56.218.144',3129],  ['168.213.3.106',80], ['205.189.170.150',80], ['107.170.221.9',8080] ]
  agent_proxy = agent_proxies[rand(0..7)]

  agent_aliases = [ 'Windows IE 7', 'Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla', 'Linux Mozilla', 'Linux Firefox' ]
  agent_alias = agent_aliases[rand(0..6)]

  url_string = "http://wwwgisp.rrc.state.tx.us/arcgis/rest/services/rrc_public/RRC_GIS_Viewer/MapServer/0/query?where=API%20in%20%28%27"

  TxrrcCoordinateScrapes.find_by_sql("SELECT * FROM txrrc_coordinate_scrapes WHERE scraped IS FALSE ORDER BY api_number LIMIT 100").each do |well|

    url_string = url_string + "%27%2C%27" + well.api_number

    well.scraped = true
    well.save!

  end

  url_string = url_string + "%27%29&outSR=4269&outFields=*&f=pjson"
  puts url_string

  agent = Mechanize.new { |agent| agent.user_agent_alias = agent_alias }
#  agent.set_proxy agent_proxy[0], agent_proxy[1]
#  puts "#{agent_proxy[0]}, #{agent_proxy[1]}"
  puts agent_alias

  page = agent.get(url_string)
  body = page.body

  json = JSON.parse(body)
#  puts json

  well_count = 0

  json['features'].each do |f|

    uni_id = f['attributes']['UNIQID']
    api_num = f['attributes']['API']
  	gis_sym_num = f['attributes']['SYMNUM']
  	gis_sym_desc = f['attributes']['GIS_SYMBOL_DESCRIPTION']
  	objct_id = f['attributes']['OBJECTID']
    long = f['geometry']['x']
    lat = f['geometry']['y']

    w = TxrrcWellCoordinates.new
    w.unique_id = uni_id
    w.api_number = api_num
    w.gis_symbol_num = gis_sym_num
    w.gis_symbol_desc = gis_sym_desc
    w.obj_id = objct_id
    w.longitude = long
    w.latitude = lat
    w.save!

    well_count = well_count + 1

  end

  puts "#{well_count} wells saved!"

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
end
