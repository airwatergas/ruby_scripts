# NMOCD Well Formation Tops Parser

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'nmocd_well_details'
require mappings_directory + 'nmocd_well_formation_tops'


# begin error trapping
begin

  start_time = Time.now

  nbsp = Nokogiri::HTML("&nbsp;").text

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  NmocdWellDetails.find_by_sql("SELECT id, api_number, html_data_details, nmocd_well_id FROM nmocd_well_details WHERE tops_parsed IS FALSE AND html_data_details IS NOT NULL LIMIT 5000").each do |w|

  ActiveRecord::Base.transaction do

    puts w.api_number

    doc = Nokogiri::HTML(w.html_data_details)

    tops = doc.xpath('//div[@id="formation_tops"]')

    tops.css('tr').each_with_index do |tr,i|

      if i >= 1 then

        f = NmocdWellFormationTops.new

        f.nmocd_well_id = w.nmocd_well_id
        f.formation_name = tr.xpath('td[1]').text.gsub(nbsp, " ").strip
        f.top_depth = tr.xpath('td[2]').text.gsub(nbsp, " ").strip
        f.save!

      end

    end

    w.tops_parsed = true
    w.save!

  end # transaction

  end # end well loop

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end