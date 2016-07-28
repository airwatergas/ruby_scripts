#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# COGCC Facility Details Scraper

# while true; do ./facility_details_scrape_c.rb & sleep $(( ( RANDOM % 10 )  + 5 )); done


# SCRAPE TYPE C: Inject table with associated wells => UIC SIMULTANEOUS DISPOSAL, UIC ENHANCED RECOVERY, UIC DISPOSAL
# look for (cogcc_facility_details) => status_date, latitude, longitude, order_number, inj_initial_date, inj_fluid_type, inj_zone_name, inj_zone_code, inj_avg_porosity, inj_avg_permeability, inj_tds, inj_frac_gradient
# look for (cogcc_facility_wells) => all table columns


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
require mappings_directory + 'cogcc_facility_formations'
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

  CogccFacilities.find_by_sql("SELECT * FROM cogcc_facilities WHERE facility_type IN ('UIC SIMULTANEOUS DISPOSAL', 'UIC ENHANCED RECOVERY', 'UIC DISPOSAL') AND details_scraped IS FALSE LIMIT 1;").each do |f|

  begin

    puts f.facility_detail_url

    page_url = "http://cogcc.state.co.us/cogis/#{f.facility_detail_url}"

    page = agent.get(page_url)

    response = page.code.to_s

    doc = Nokogiri::HTML(page.body)

    data_table = doc.xpath('//table')
    num_data_table_rows = data_table.css('tr').length
    formation_count = data_table.text.scan(/Inj. Zone Name/).count
    formation_rows = 10 + (3 * formation_count) - 1
    well_row_start = (formation_count*3) + 13
    well_check = data_table.xpath("tr[#{well_row_start}]/td").text.gsub(nbsp, " ").strip

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
      if !doc.at('td:contains("Order #:")').nil? then
        d.order_number = doc.at('td:contains("Order #:")').next_element.text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("Initial Inj. Date:")').nil? then
        d.inj_initial_date = doc.at('td:contains("Initial Inj. Date:")').next_element.text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("Fluid Type:")').nil? then
        d.inj_fluid_type = doc.at('td:contains("Fluid Type:")').next_element.text.gsub(nbsp, " ").strip
      end

      puts d.inspect
      d.save!

      #loop through formations: first row is tr[10] and 3 rows per formation
      (10..formation_rows).step(3) do |i|

        ff = CogccFacilityFormations.new

        ff.cogcc_facility_id = f.id

        ff.inj_zone_name = data_table.xpath("tr[#{i}]/td[2]").text.gsub(nbsp, " ").strip
        ff.inj_zone_code = data_table.xpath("tr[#{i}]/td[4]").text.gsub(nbsp, " ").strip
        ff.inj_avg_porosity = data_table.xpath("tr[#{i}+1]/td[2]").text.gsub(nbsp, " ").strip
        ff.inj_avg_permeability = data_table.xpath("tr[#{i}+1]/td[4]").text.gsub(nbsp, " ").strip
        ff.inj_tds = data_table.xpath("tr[#{i}+2]/td[2]").text.gsub(nbsp, " ").strip
        ff.inj_frac_gradient = data_table.xpath("tr[#{i}+2]/td[4]").text.gsub(nbsp, " ").strip

        puts ff.inspect
        ff.save!

      end

      # capture associated well data
      if well_check != "Sorry, no associated wells could be found." then

        # loop over wells, if any
        (well_row_start..num_data_table_rows).step(5) do |r|

          w = CogccFacilityWells.new

          w.cogcc_facility_id = f.id

          w.api_number = data_table.xpath("tr[#{r}]/td[2]").text.gsub(nbsp, " ").strip
          w.well_url = data_table.xpath("tr[#{r}]/td[2]").at('a')['href'].to_s
          w.well_name = data_table.xpath("tr[#{r}]/td[4]").text.gsub(nbsp, " ").strip
          w.facility_status = data_table.xpath("tr[#{r}+1]/td[2]").text.gsub(nbsp, " ").strip
          w.wellbore_status = data_table.xpath("tr[#{r}+1]/td[4]").text.gsub(nbsp, " ").strip
          w.authorization_date = data_table.xpath("tr[#{r}+2]/td[2]").text.gsub(nbsp, " ").strip
          w.no_longer_injector_date = data_table.xpath("tr[#{r}+2]/td[4]").text.gsub(nbsp, " ").strip
          w.max_water_inj_psi = data_table.xpath("tr[#{r}+3]/td[2]").text.gsub(nbsp, " ").strip
          w.max_gas_inj_psi = data_table.xpath("tr[#{r}+3]/td[4]").text.gsub(nbsp, " ").strip
          w.max_inj_volume = data_table.xpath("tr[#{r}+4]/td[2]").text.gsub(nbsp, " ").strip
          w.last_mit = data_table.xpath("tr[#{r}+4]/td[4]").text.gsub(nbsp, " ").strip

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








