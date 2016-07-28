#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# NMOCD HTML Well Details Scraper

# UNIX shell script to run scraper: while true; do ./html_well_details_scraper.rb & sleep 10; done

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'nmocd_well_details'


# begin error trapping
begin

  start_time = Time.now

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  # use random browser
  agent_aliases = [ 'Windows IE 7', 'Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla', 'Linux Mozilla', 'Linux Firefox' ]
  agent_alias = agent_aliases[rand(0..6)]

  agent = Mechanize.new { |agent| agent.user_agent_alias = agent_alias }

  puts agent_alias

#  NmocdWellDetails.find_by_sql("SELECT * FROM nmocd_well_details WHERE well_status_id = 5 AND in_use IS FALSE AND html_saved IS FALSE LIMIT 1").each do |w|
  NmocdWellDetails.find_by_sql("SELECT * FROM nmocd_well_details WHERE html_heading ilike '%An Unexpected Error Has Occurred%' AND in_use IS FALSE AND html_saved IS FALSE LIMIT 1").each do |w|

  begin

    puts "Well #{w.api_number} in use!"

    w.in_use = true
    w.save!

    page_url = "https://wwwapps.emnrd.state.nm.us/ocd/ocdpermitting/Data/WellDetails.aspx?api=#{w.api_number}"

    page = agent.get(page_url)

    response = page.code.to_s

    if response == "200" then
      doc = Nokogiri::HTML(page.body)
      w.html_heading = doc.xpath('//h1')
      w.html_data_details = doc.xpath('//div[@id="data_details"]')
      w.html_status = "page saved"
    else
      w.html_status = "page not found"
    end # end response check

    w.html_saved = true
    w.in_use = false
    w.save!

    rescue Mechanize::ResponseCodeError => e
      w.html_status = "page not found"
      w.html_saved = true
      w.in_use = false
      w.save!
      puts "ResponseCodeError: " + e.to_s
    end

    puts "Well scrape completed!"

  end # end well loop

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end