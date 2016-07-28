#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# TEXAS Well Details Scraper (latitude, longtidue, gis symbol, wellbore status)

# while true; do ./well_details_scrape.rb & sleep $(( ( RANDOM % 10 )  + 5 )); done

# url=http://wwwgisp.rrc.state.tx.us/GISViewer2/index.html?api=01300692


# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require 'mechanize'
require 'nokogiri'
require 'csv'
require 'open-uri'

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'txrrc_wells'

begin # begin error trapping

  start_time = Time.now  

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  agent_proxies =  [ ['165.139.149.169',3128], ['165.2.139.51',80], ['199.189.80.13',8080], ['97.77.104.22',80], ['50.56.218.144',3129],  ['168.213.3.106',80], ['205.189.170.150',80], ['107.170.221.9',8080] ]
# slow ['54.186.105.158',80], ['173.73.19.153',80], ['52.89.226.152',80], 
# very slow ['192.240.46.126',80], ['54.191.214.172',8080], ['24.172.34.114',8181], 
  agent_proxy = agent_proxies[rand(0..7)]

  agent_aliases = [ 'Windows IE 7', 'Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla', 'Linux Mozilla', 'Linux Firefox' ]
  agent_alias = agent_aliases[rand(0..6)]

  api_number = "00932157"

#  if TxrrcWells.where(in_use: true).count == 0 then

#    TxrrcWells.find_by_sql("SELECT * FROM txrrc_wells WHERE in_use IS FALSE AND details_scraped IS FALSE ORDER BY api_number LIMIT 1").each do |well|

      agent = Mechanize.new { |agent| agent.user_agent_alias = agent_alias }
#      agent.set_proxy agent_proxy[0], agent_proxy[1]
      puts "#{agent_proxy[0]}, #{agent_proxy[1]}"
      puts agent_alias

#      well.in_use = true
#      well.save!
      puts "Well API: #{api_number}"

      page_url = "http://wwwgisp.rrc.state.tx.us/GISViewer2/index.html?api=00932157"
      page = agent.get(page_url)
      response = page.code.to_s
#      doc = Nokogiri::HTML(page.body)

doc = Nokogiri::HTML(open("http://wwwgisp.rrc.texas.gov/GISViewer2/index.html?api=00932157"))

      puts doc

      popup = doc.xpath('//*[@id="rrcGisViewerBottomPane"]')
      #popup = doc.css('div.esriPopup')

      #puts popup

#    well.details_scraped = true
#    well.in_use = false
#    well.save!

    rescue Mechanize::ResponseCodeError => e
      puts "ResponseCodeError: " + e.to_s
#      well.in_use = false
#      well.save!
#    end

#  end # active record loop

#  end # in use check

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
#    well.in_use = false
#    well.save!
end

