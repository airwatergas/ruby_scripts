#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# COGCC Environmental Sample Site Infomation/Test Results Scraper

# UNIX shell script to run scraper: while true; do ./enviro_sample.rb & sleep 5; done

# Include required classes and models:

require '../../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_enviromental_locations'

start_time = Time.now

nbsp = Nokogiri::HTML("&nbsp;").text

# Establish a database connection
ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

# begin error trapping
begin

  # loop through facility ids
  #(700001..708217).step(1) do |i|
  (700100..700100).step(1) do |i|

    # use random browser
    agent_aliases = [ 'Windows IE 7', 'Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla', 'Linux Mozilla', 'Linux Firefox' ]
    agent_alias = agent_aliases[rand(0..6)]
    agent = Mechanize.new { |agent| agent.user_agent_alias = agent_alias }
    puts agent_alias

    begin

      puts "Facility ID: #{i}"
      page_url = "http://cogcc.state.co.us/COGIS/EnviroSample.asp?facid=#{i}"
      page = agent.get(page_url)
      response = page.code.to_s
      doc = Nokogiri::HTML(page.body)
      site_table = doc.xpath('//table[1]')

      s = CogccEnvironmentalLocations.new
      s.location_id = i

      if !site_table.at('td:contains("FacilityType:")').nil? then
        s.facility_type = site_table.at('td:contains("FacilityType:")').next_element.text.gsub(nbsp, " ").strip
      end
      if !site_table.at('td:contains("ProjNumber:")').nil? then
        s.project_number = site_table.at('td:contains("ProjNumber:")').next_element.text.gsub(nbsp, " ").strip
      end
      if !site_table.at('td:contains("County:")').nil? then
        s.county = site_table.at('td:contains("County:")').next_element.text.gsub(nbsp, " ").strip
      end
      if !site_table.at('td:contains("Location:")').nil? then
        s.plss_location = site_table.at('td:contains("Location:")').next_element.text.gsub(nbsp, " ").strip
      end
      if !site_table.at('td:contains("Elevation:")').nil? then
        s.elevation = site_table.at('td:contains("Elevation:")').next_element.text.gsub(nbsp, " ").strip
      end
      if !site_table.at('td:contains("Lat/Long:")').nil? then

        s.longitude = site_table.at('td:contains("Lat/Long:")').next_element.text.gsub(nbsp, " ").strip
        s.latitude = site_table.at('td:contains("Lat/Long:")').next_element.text.gsub(nbsp, " ").strip
      end
      if !site_table.at('td:contains("DWR Receipt #:")').nil? then
        s.dwr_receipt_number = site_table.at('td:contains("DWR Receipt #:")').next_element.text.gsub(nbsp, " ").strip
        if !s.dwr_receipt_number.nil? then
          s.dwr_url = "http://www.dwr.state.co.us/WellPermitSearch/View.aspx?receipt=#{s.dwr_receipt_number}"
        end
      end
      if !site_table.at('td:contains("WellDepth:")').nil? then
        s.well_depth = site_table.at('td:contains("WellDepth:")').next_element.text.gsub(nbsp, " ").strip
      end

      s.created_at = Time.now
      s.updated_at = Time.now
      puts s.inspect
#      s.save!

      puts "Site information saved!"

      sample_links = doc.xpath("//a[starts-with(@href, 'EnviroSample.asp?facid=#{i}')]")

      link_count = sample_links.length

      if link_count > 0 then

puts sample_links.inspect

        sample_ids = sample_links.text.join(",")
puts sample_ids
        export_url = "http://cogcc.state.co.us/COGIS/EnviroSample_Export.ashx?facid=#{i}&SampleID=#{sample_ids}&External=Y"
        puts export_url
        export = agent.get(export_url)
        file_name = "#{i}.csv"
        export.save file_name
        puts "Samples saved!"

      else

        puts "No samples found."

      end

    rescue Mechanize::ResponseCodeError => e
      puts "ResponseCodeError: " + e.to_s
      complaint.invalid_text = true
      complaint.save
    end

  end # end facility id loop

   puts "Time Start: #{start_time}"
   puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end