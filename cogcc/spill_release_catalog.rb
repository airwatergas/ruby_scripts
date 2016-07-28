# COGCC Spill/Release Cataloger

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_spill_releases'


# begin error trapping
begin

  start_time = Time.now

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  agent = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }

  page_url = "file:///Users/troyburke/Projects/ruby/cogcc/spills_releases_v3.html"

  nbsp = Nokogiri::HTML("&nbsp;").text

  page = agent.get(page_url)

  doc = Nokogiri::HTML(page.body)

  doc.css('tr').each_with_index do |tr,i|

    if i >= 2 then

      s = CogccSpillReleases.new

      s.submit_date = tr.xpath('td[1]').text.gsub(nbsp, " ").strip
      s.document_number = tr.xpath('td[2]').text.gsub(nbsp, " ").strip
      s.document_url = tr.xpath('td[2]').at('a')['href'].to_s
      s.facility_id = tr.xpath('td[3]').text.gsub(nbsp, " ").strip
      s.operator_number = tr.xpath('td[4]').text.gsub(nbsp, " ").strip
      s.company_name = tr.xpath('td[5]').text.gsub(nbsp, " ").strip
      s.ground_water = tr.xpath('td[6]').text.gsub(nbsp, " ").strip
      s.surface_water = tr.xpath('td[7]').text.gsub(nbsp, " ").strip
      s.berm_contained = tr.xpath('td[8]').text.gsub(nbsp, " ").strip
      s.spill_area = tr.xpath('td[9]').text.gsub(nbsp, " ").strip

      s.save!

    end

  end

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end