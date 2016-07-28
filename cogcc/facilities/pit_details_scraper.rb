#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# COGCC Pit Details

#  while true; do ./pit_details_scraper.rb & sleep 5; done 

# URLS:
# http://cogcc.state.co.us/cogis/FacilityDetail.asp?facid=112604&type=PIT

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_pits'
require mappings_directory + 'cogcc_pit_details'


# begin error trapping
begin

  start_time = Time.now

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  # use random browser
  agent_aliases = [ 'Windows IE 7', 'Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla', 'Linux Mozilla', 'Linux Firefox' ]
  agent_alias = agent_aliases[rand(0..6)]

  agent = Mechanize.new { |agent| agent.user_agent_alias = agent_alias }

  puts " "
  puts agent_alias

  nbsp = Nokogiri::HTML("&nbsp;").text

  if CogccPits.where(in_use: true).count == 0 then

  CogccPits.find_by_sql("SELECT * FROM cogcc_pits WHERE in_use IS FALSE AND details_scraped IS FALSE LIMIT 1").each do |pit|

  begin

    puts "PIT: #{pit.facility_i} in use!"

    pit.in_use = true
    pit.save!

    ActiveRecord::Base.transaction do

      page_url = "http://cogcc.state.co.us/cogis/FacilityDetail.asp?facid=#{pit.facility_i}&type=PIT"

      page = agent.get(page_url)

      response = page.code.to_s

      doc = Nokogiri::HTML(page.body)

      if doc.at('h3:contains("could not be found.")').nil? then

        d = CogccPitDetails.new

        d.cogcc_pit_id = pit.id

        # scrape details from html
        if !doc.at('td:contains("Sensitive Area:")').nil? then
      	  d.sensitive_area = doc.at('td:contains("Sensitive Area:")').next_element.text.gsub(nbsp, " ").strip
      	end
      	if !doc.at('td:contains("Land Use:")').nil? then
      	  d.land_use = doc.at('td:contains("Land Use:")').next_element.text.gsub(nbsp, " ").strip
      	end
      	if !doc.at('td:contains("Dist. to Water Source:")').nil? then
      	  d.water_source_distance = doc.at('td:contains("Dist. to Water Source:")').next_element.text.gsub(nbsp, " ").strip
      	end
      	if !doc.at('td:contains("Surface Water:")').nil? then
      	  d.surface_water_distance = doc.at('td:contains("Surface Water:")').next_element.text.gsub(nbsp, " ").strip
      	end
      	if !doc.at('td:contains("Dist. to Ground Water:")').nil? then
      	  d.ground_water_distance = doc.at('td:contains("Dist. to Ground Water:")').next_element.text.gsub(nbsp, " ").strip
      	end
      	if !doc.at('td:contains("Water Wells:")').nil? then
      	  d.water_well_distance = doc.at('td:contains("Water Wells:")').next_element.text.gsub(nbsp, " ").strip
      	end
        if !doc.at('td:contains("Size of PIT (feet):")').nil? then
      	  d.size = doc.at('td:contains("Size of PIT (feet):")').next_element.text.gsub(nbsp, " ").strip
      	end
        if !doc.at('td:contains("Depth:")').nil? then
      	  d.depth = doc.at('td:contains("Depth:")').next_element.text.gsub(nbsp, " ").strip
      	end
        if !doc.at('td:contains("Length:")').nil? then
      	  d.length = doc.at('td:contains("Length:")').next_element.text.gsub(nbsp, " ").strip
      	end
        if !doc.at('td:contains("Width:")').nil? then
      	  d.width = doc.at('td:contains("Width:")').next_element.text.gsub(nbsp, " ").strip
      	end
        if !doc.at('td:contains("Capacity (bbls/day):")').nil? then
      	  d.capacity = doc.at('td:contains("Capacity (bbls/day):")').next_element.text.gsub(nbsp, " ").strip
      	end
      	if !doc.at('td:contains("Rates (bbls/day)")').nil? then
      	  evap_rate = doc.at('td:contains("Rates (bbls/day)")').next_element.text.split("Evap:")[1]
      	  if !evap_rate.nil? then
      	    d.daily_disposal_evap_rate = evap_rate.gsub(nbsp, " ").strip
      	  end
      	end
        if !doc.at('td:contains("Perc:")').nil? then
      	  d.daily_disposal_perc_rate = doc.at('td:contains("Perc:")').next_element.text.gsub(nbsp, " ").strip
      	end
        if !doc.at('td:contains("PIT Type:")').nil? then
      	  d.pit_type = doc.at('td:contains("PIT Type:")').next_element.text.gsub(nbsp, " ").strip
      	end
        if !doc.at('td:contains("Liner Material:")').nil? then
      	  d.liner_material = doc.at('td:contains("Liner Material:")').next_element.text.gsub(nbsp, " ").strip
      	end
      	if !doc.at('td:contains("Liner Material:")').nil? then
      	  thickness = doc.at('td:contains("Liner Material:")').next_element.text.split("Thickness:")[1]
      	  if !thickness.nil? then
      	    d.liner_thickness = thickness.gsub(nbsp, " ").strip
      	  end
      	end
        if !doc.at('td:contains("Treatment Method:")').nil? then
      	  d.treatment_method = doc.at('td:contains("Treatment Method:")').next_element.text.gsub(nbsp, " ").strip
      	end
        if !doc.at('td:contains("Pit Covering Fence:")').nil? then
      	  d.covering_fence = doc.at('td:contains("Pit Covering Fence:")').next_element.text.gsub(nbsp, " ").strip
      	end
        if !doc.at('td:contains("Net:")').nil? then
      	  d.covering_net = doc.at('td:contains("Net:")').next_element.text.gsub(nbsp, " ").strip
      	end
        if !doc.at('td:contains("Comment:")').nil? then
          comment_text = doc.at('td:contains("Comment:")').next_element.text
          com_text = comment_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
          com_text = com_text.encode!('UTF-8', 'UTF-16')
          d.comment = com_text.gsub(nbsp, " ").strip
        end

        puts d.inspect
        d.save!
        puts "Pit details saved!"

      else

        puts "Pit details not found!"

      end # details found check

      pit.details_scraped = true
      pit.in_use = false
      pit.save!

    end # active record transaction

    rescue Mechanize::ResponseCodeError => e
      pit.details_scraped = true
      pit.in_use = false
      pit.save!
      puts "ResponseCodeError: " + e.to_s
    end

  end # query loop
  
  end # in use check
  
  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end