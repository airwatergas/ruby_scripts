# NMOCD Well Productions Parser

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'nmocd_well_details'


# begin error trapping
begin

  start_time = Time.now

  nbsp = Nokogiri::HTML("&nbsp;").text

  prod_count = 0

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

#  NmocdWellDetails.find_by_sql("SELECT id, api_number, html_data_details, nmocd_well_id FROM nmocd_well_details WHERE in_use IS FALSE AND is_san_juan IS TRUE AND html_data_details IS NOT NULL AND has_production_records IS FALSE ORDER BY api_number").each do |w|

  NmocdWellDetails.find_by_sql("SELECT id, api_number, html_data_details, nmocd_well_id FROM nmocd_well_details WHERE is_san_juan IS TRUE AND html_data_details IS NOT NULL ORDER BY api_number").each do |w|

#  NmocdWellDetails.find_by_sql("SELECT id, api_number, html_data_details, nmocd_well_id FROM nmocd_well_details WHERE in_use IS FALSE AND is_san_juan IS FALSE AND html_data_details IS NOT NULL AND has_production_records IS FALSE ORDER BY api_number LIMIT 5000").each do |w|

    doc = Nokogiri::HTML(w.html_data_details)

    #results = doc.xpath('//span[@id="ctl00_ctl00__main_main_ucProduction_lblLastProduction"]')
    results = doc.xpath('//td[@id="Grand_Total_Heading"]')
    
    results = results.text.gsub(nbsp, " ").strip

#    w.in_use = true
    if results != ""
      puts "#{w.api_number}: Grand Total = #{results}"
#      w.has_production_records = true
      prod_count = prod_count + 1
    else
      puts "#{w.api_number}: none"
    end
#    w.save!

  end # end well loop

  puts prod_count

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end