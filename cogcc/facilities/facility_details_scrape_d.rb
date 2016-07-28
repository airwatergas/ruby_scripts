#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# COGCC Facility Details Scraper

# while true; do ./facility_details_scrape_d.rb & sleep $(( ( RANDOM % 10 )  + 5 )); done


# SCRAPE TYPE D: Location table with associated wells => LOCATION
# look for (cogcc_facility_locations) => all table columns
# look for (cogcc_facility_wells) => api_number


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
require mappings_directory + 'cogcc_facility_locations'
require mappings_directory + 'cogcc_facility_wells'


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

  CogccFacilities.find_by_sql("SELECT * FROM cogcc_facilities WHERE facility_type = 'LOCATION' AND details_scraped IS FALSE LIMIT 1;").each do |f|

  begin

    puts f.facility_detail_url

    page_url = "http://cogcc.state.co.us/cogis/#{f.facility_detail_url}"

    page = agent.get(page_url)

    response = page.code.to_s

    doc = Nokogiri::HTML(page.body)

    data_table = doc.xpath('//table')
    num_data_table_rows = data_table.css('tr').length - 2
    well_row_start = 20
    well_check = data_table.xpath("tr[#{well_row_start}]/td").text.gsub(nbsp, " ").strip

    ActiveRecord::Base.transaction do

      d = CogccFacilityLocations.new

      d.cogcc_facility_id = f.id

      # scrape details from html
      d.status_date = doc.at('td:contains("Status Date:")').next_element.text.gsub(nbsp, " ").strip
      lat_long = doc.at('td:contains("Lat/Long:")').next_element.text.gsub(nbsp, " ").strip
      if lat_long.include? "/" then
        d.latitude = lat_long.split("/").first
        d.longitude = lat_long.split("/").last
      end
      d.form_2a_doc_num = doc.at('td:contains("Form 2A Document #:")').next_element.text.gsub(nbsp, " ").strip
      d.form_2a_exp_date = doc.at('td:contains("Form 2A Expiration:")').next_element.text.gsub(nbsp, " ").strip
      d.special_purpose_pits = doc.at('td:contains("Special Purpose Pits:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.drilling_pits = doc.at('td:contains("Drilling Pits:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.wells = doc.at('td:contains("Wells:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.production_pits = doc.at('td:contains("Production Pits:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.condensate_tanks = doc.at('td:contains("Condensate Tanks:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.water_tanks = doc.at('td:contains("Water Tanks:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.separators = doc.at('td:contains("Separators:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.electric_motors = doc.at('td:contains("Electric Motors:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.gas_or_diesel_motors = doc.at('td:contains("Gas or Diesel Motors:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.cavity_pumps = doc.at('td:contains("Cavity Pumps:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.lact_unit = doc.at('td:contains("LACT Unit:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.pump_jacks = doc.at('td:contains("Pump Jacks:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.electric_generators = doc.at('td:contains("Electric Generators:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.gas_pipeline = doc.at('td:contains("Gas Pipeline:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.oil_pipeline = doc.at('td:contains("Oil Pipeline:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.water_pipeline = doc.at('td:contains("Water Pipeline:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.gas_compressors = doc.at('td:contains("Gas Compressors:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.voc_combustor = doc.at('td:contains("VOC Combustor:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.oil_tanks = doc.at('td:contains("Oil Tanks:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.dehydrator_units = doc.at('td:contains("Dehydrator Units:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.multi_well_pits = doc.at('td:contains("Multi-Well Pits:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.pigging_station = doc.at('td:contains("Pigging Station:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.flare = doc.at('td:contains("Flare:")').text.split(":")[1].gsub(nbsp, " ").strip
    	d.fuel_tanks = doc.at('td:contains("Fuel Tanks:")').text.split(":")[1].gsub(nbsp, " ").strip

      puts d.inspect
      d.save!

      # capture associated well data
      if well_check != "Sorry, no associated wells could be found." then

        # loop over wells, if any
        (well_row_start..num_data_table_rows).step(4) do |r|

          w = CogccFacilityWells.new

          w.cogcc_facility_id = f.id
          w.cogcc_facility_location_id = d.id

          w.api_number = data_table.xpath("tr[#{r}]/td[2]").text.gsub(nbsp, " ").strip
          w.well_url = data_table.xpath("tr[#{r}]/td[2]").at('a')['href'].to_s

          puts w.inspect
          w.save!

        end

      end

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








