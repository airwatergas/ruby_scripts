# NMOCD HTML Well File Importer

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'nmocd_wells'


# begin error trapping
begin

  start_time = Time.now

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  agent = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }

  page_url = "file:///Users/troyburke/Projects/ruby/nmocd/ExpandedWells.html"

  nbsp = Nokogiri::HTML("&nbsp;").text

  page = agent.get(page_url)

  doc = Nokogiri::HTML(page.body)

  doc.css('tr').each_with_index do |tr,i|

    if i >= 2 then

      w = NmocdWells.new

      w.api = tr.xpath('td[1]').text.gsub(nbsp, " ").strip
      if !tr.xpath('td[2]').text.gsub(nbsp, " ").strip.nil?
        w.well_name = tr.xpath('td[2]').text.gsub(nbsp, " ").strip
      end
      if !tr.xpath('td[3]').text.gsub(nbsp, " ").strip.nil?
        w.well_number = tr.xpath('td[3]').text.gsub(nbsp, " ").strip
      end
      if !tr.xpath('td[4]').text.gsub(nbsp, " ").strip.nil?
        w.type = tr.xpath('td[4]').text.gsub(nbsp, " ").strip
      end
      if !tr.xpath('td[5]').text.gsub(nbsp, " ").strip.nil?
        w.lease = tr.xpath('td[5]').text.gsub(nbsp, " ").strip
      end
      if !tr.xpath('td[6]').text.gsub(nbsp, " ").strip.nil?
        w.status = tr.xpath('td[6]').text.gsub(nbsp, " ").strip
      end
      if !tr.xpath('td[7]').text.gsub(nbsp, " ").strip.nil?
        w.initial_apd_approval_date = tr.xpath('td[7]').text.gsub(nbsp, " ").strip
      end
      if !tr.xpath('td[8]').text.gsub(nbsp, " ").strip.nil?
        w.unit_letter = tr.xpath('td[8]').text.gsub(nbsp, " ").strip
      end
      if !tr.xpath('td[9]').text.gsub(nbsp, " ").strip.nil?
        w.section = tr.xpath('td[9]').text.gsub(nbsp, " ").strip
      end
      if !tr.xpath('td[10]').text.gsub(nbsp, " ").strip.nil?
        w.township = tr.xpath('td[10]').text.gsub(nbsp, " ").strip
      end
      if !tr.xpath('td[11]').text.gsub(nbsp, " ").strip.nil?
    	  w.range = tr.xpath('td[11]').text.gsub(nbsp, " ").strip
    	end
    	if !tr.xpath('td[12]').text.gsub(nbsp, " ").strip.nil?
    	  w.ocd_unit_letter = tr.xpath('td[12]').text.gsub(nbsp, " ").strip
    	end
    	if !tr.xpath('td[13]').text.gsub(nbsp, " ").strip.nil?
    	  w.footages = tr.xpath('td[13]').text.gsub(nbsp, " ").strip
    	end
    	if !tr.xpath('td[14]').text.gsub(nbsp, " ").strip.nil?
    	  w.latitude = tr.xpath('td[14]').text.gsub(nbsp, " ").strip
    	end
    	if !tr.xpath('td[15]').text.gsub(nbsp, " ").strip.nil?
    	  w.longitude = tr.xpath('td[15]').text.gsub(nbsp, " ").strip
    	end
      if !tr.xpath('td[16]').text.gsub(nbsp, " ").strip.nil?
    	  w.last_production = tr.xpath('td[16]').text.gsub(nbsp, " ").strip
    	end
    	if !tr.xpath('td[17]').text.gsub(nbsp, " ").strip.nil?
    	  w.spud_date = tr.xpath('td[17]').text.gsub(nbsp, " ").strip
    	end
    	if !tr.xpath('td[18]').text.gsub(nbsp, " ").strip.nil?
    	  w.measured_depth = tr.xpath('td[18]').text.gsub(nbsp, " ").strip
    	end
    	if !tr.xpath('td[19]').text.gsub(nbsp, " ").strip.nil?
    	  w.true_vertical_depth = tr.xpath('td[19]').text.gsub(nbsp, " ").strip
      end
      if !tr.xpath('td[20]').text.gsub(nbsp, " ").strip.nil?
    	  w.elevation = tr.xpath('td[20]').text.gsub(nbsp, " ").strip
    	end
    	if !tr.xpath('td[21]').text.gsub(nbsp, " ").strip.nil?
    	  w.last_inspection = tr.xpath('td[21]').text.gsub(nbsp, " ").strip
    	end
    	if !tr.xpath('td[22]').text.gsub(nbsp, " ").strip.nil?
    	  w.last_mit = tr.xpath('td[22]').text.gsub(nbsp, " ").strip
    	end
    	if !tr.xpath('td[23]').text.gsub(nbsp, " ").strip.nil?
    	  w.plugged_on = tr.xpath('td[23]').text.gsub(nbsp, " ").strip
    	end
    	if !tr.xpath('td[24]').text.gsub(nbsp, " ").strip.nil?
    	  w.current_operator = tr.xpath('td[24]').text.gsub(nbsp, " ").strip
    	end
    	if !tr.xpath('td[25]').text.gsub(nbsp, " ").strip.nil?
    	  w.district = tr.xpath('td[25]').text.gsub(nbsp, " ").strip
    	end

      w.save!

    end

  end

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end