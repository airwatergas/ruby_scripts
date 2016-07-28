#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# COGCC Facility Details Scraper

# while true; do ./facility_details_scrape_a.rb & sleep $(( ( RANDOM % 10 )  + 5 )); done


# SCRAPE TYPE A: Basic table with comment (Comment:) => WATER GATHERING SYSTEM/LINE, UIC WATER TRANSFER STATION, TANK BATTERY, SPILL OR RELEASE, SERVICE SITE, PIPELINE, NONFACILITY, LAND APPLICATION SITE, FLOWLINE, CENTRALIZED EP WASTE MGMT FAC
# look for (cogcc_facility_details) => status_date, latitude, longitude, comments

# No additional details => LEASE, GAS PROCESSING PLANT, CDP


# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_facilities'
require mappings_directory + 'cogcc_facility_details'


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

  nbsp = Nokogiri::HTML("&nbsp;").text

  CogccFacilities.find_by_sql("SELECT * FROM cogcc_facilities WHERE facility_type IN ('WATER GATHERING SYSTEM/LINE', 'UIC WATER TRANSFER STATION', 'TANK BATTERY', 'SPILL OR RELEASE', 'SERVICE SITE', 'PIPELINE', 'NONFACILITY', 'LAND APPLICATION SITE', 'FLOWLINE', 'CENTRALIZED EP WASTE MGMT FAC') AND details_scraped IS FALSE LIMIT 1;").each do |f|

  begin

    puts f.facility_detail_url

    page_url = "http://cogcc.state.co.us/cogis/#{f.facility_detail_url}"

    page = agent.get(page_url)

    response = page.code.to_s

    doc = Nokogiri::HTML(page.body)

    ActiveRecord::Base.transaction do

      d = CogccFacilityDetails.new

      d.cogcc_facility_id = f.id

      # scrape details from html
      if !doc.at('td:contains("Status Date:")').nil? then
        d.status_date = doc.at('td:contains("Status Date:")').next_element.text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("Lat/Long:")').nil? then
        lat_long = doc.at('td:contains("Lat/Long:")').next_element.text.gsub(nbsp, " ").strip
        if lat_long.include? "/" then
          d.latitude = lat_long.split("/").first
          d.longitude = lat_long.split("/").last
        end
      end
      if !doc.at('td:contains("Comment:")').nil? then
        comment_text = doc.at('td:contains("Comment:")').next_element.text
        comment = comment_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        comment = comment.encode!('UTF-8', 'UTF-16')
        d.comments = comment.gsub(nbsp, " ").strip
      end

      d.save!

      f.details_scraped = true
      f.save!

    end # end activerecord transaction block

    rescue Mechanize::ResponseCodeError => e
      puts "ResponseCodeError: " + e.to_s
    end

  end

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end








