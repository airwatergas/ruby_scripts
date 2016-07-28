#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# COGCC Facility Cataloger

# while true; do ./facility_cataloger_by_fips.rb & sleep $(( ( RANDOM % 25 )  + 5 )); done


# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'counties'
require mappings_directory + 'cogcc_facilities'


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

  page_url = "http://cogcc.state.co.us/cogis/FacilitySearch.asp"

  nbsp = Nokogiri::HTML("&nbsp;").text

  #Counties.find_by_sql("SELECT * FROM counties WHERE state_name = 'Colorado' AND cogcc_location_scraped IS FALSE LIMIT 1;").each do |county|
  #Counties.find_by_sql("SELECT * FROM counties WHERE state_name = 'Colorado' AND cogcc_lease_scraped IS FALSE LIMIT 1;").each do |county|

  #puts county.cnty_fips
    
  begin

    page = agent.get(page_url)

    search_form = page.form_with(name: 'cogims2')

    # 'LOCATION' --time out at 3,898
    # 'LEASE' --timed out at 5,135
    
    #search_form.field_with(name: 'factype').value = "'LOCATION'"
    search_form.field_with(name: 'factype').value = "'LEASE'"
    #search_form.field_with(name: 'ApiCountyCode').value = "#{county.cnty_fips}"
    search_form.field_with(name: 'ApiCountyCode').value = "123"
    search_form.field_with(name: 'twp').value = "12N"
    search_form.field_with(name: 'maxrec').value = 0
    search_results = search_form.submit

    page = agent.submit(search_form)

    # get http response code to check for valid url
    response = page.code.to_s

    # retreive body html
    doc = Nokogiri::HTML(page.body)

    results_table = doc.xpath('//table[2]')

    puts results_table

    results_table.css('tr').each_with_index do |tr,i|

      if i >= 2 then

        f = CogccFacilities.new

        f.facility_type = tr.xpath('td[1]').text.gsub(nbsp, " ").strip

        f.facility_detail_url = tr.xpath('td[1]').at('a')['href'].to_s

        f.facility_id = tr.xpath('td[2]').text.gsub(nbsp, " ").strip

        facility_cell = tr.xpath('td[3]')
        facility_cell.search('br').each do |n|
          n.replace("\n")
        end
        if !facility_cell.text.split("\n")[0].nil? then
          f.facility_name = facility_cell.text.split("\n")[0].gsub(nbsp, " ").strip
        end
        if !facility_cell.text.split("\n")[1].nil? then
          f.facility_number = facility_cell.text.split("\n")[1].gsub(nbsp, " ").strip
        end

        operator_cell = tr.xpath('td[4]')
        operator_cell.search('br').each do |n|
          n.replace("\n")
        end
        if !operator_cell.text.split("\n")[0].nil? then
          f.operator_name = operator_cell.text.split("\n")[0].gsub(nbsp, " ").strip
        end
        if !operator_cell.text.split("\n")[1].nil? then
          f.operator_number = operator_cell.text.split("\n")[1].gsub(nbsp, " ").strip
        end

        f.status = tr.xpath('td[5]').text.gsub(nbsp, " ").strip

        field_cell = tr.xpath('td[6]')
        field_cell.search('br').each do |n|
          n.replace("\n")
        end
        if !field_cell.text.split("\n")[0].nil? then
          f.field_name = field_cell.text.split("\n")[0].gsub(nbsp, " ").strip
        end
        if !field_cell.text.split("\n")[1].nil? then
          f.field_number = field_cell.text.split("\n")[1].gsub(nbsp, " ").strip
        end

        location_cell = tr.xpath('td[7]')
        location_cell.search('br').each do |n|
          n.replace("\n")
        end
        if !location_cell.text.split("\n")[0].nil? then
          f.location_county = location_cell.text.split("\n")[0].gsub(nbsp, " ").strip
        end
        if !location_cell.text.split("\n")[1].nil? then
          f.location_plss = location_cell.text.split("\n")[1].gsub(nbsp, " ").strip
        end

        f.related_facilities_url = tr.xpath('td[8]').at('a')['href'].to_s

        f.save!

      end

    end

    #county.cogcc_location_scraped = true
    #county.cogcc_lease_scraped = true
    #county.save!

    rescue Mechanize::ResponseCodeError => e
      puts "ResponseCodeError: " + e.to_s
    end

  #end

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end