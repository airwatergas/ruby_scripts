# COGCC Complaint Scraper

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_complaints'


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

  page_url = "http://cogcc.state.co.us/cogis/IncidentSearch.asp"

  nbsp = Nokogiri::HTML("&nbsp;").text

  begin

    page = agent.get(page_url)

    search_form = page.form_with(name: 'cogims2')

    search_form.radiobuttons_with(name: 'itype')[2].check
    search_form.field_with(name: 'maxrec').value = 5000
    search_results = search_form.submit

    page = agent.submit(search_form)

    # get http response code to check for valid url
    response = page.code.to_s

    # retreive body html
    doc = Nokogiri::HTML(page.body)

    results_table = doc.xpath('//table[2]')

    results_table.css('tr').each_with_index do |tr,i|

      if i >= 2 then

        c = CogccComplaints.new

        c.incident_date = tr.xpath('td[1]').text.gsub(nbsp, " ").strip
        c.document_number = tr.xpath('td[2]').text.gsub(nbsp, " ").strip
        c.complainant_name = tr.xpath('td[3]').text.gsub(nbsp, " ").strip
        c.facility_type = tr.xpath('td[4]').text.gsub(nbsp, " ").strip
        c.facility_id = tr.xpath('td[5]').text.gsub(nbsp, " ").strip
        c.operator_name = tr.xpath('td[6]').text.gsub(nbsp, " ").strip
        c.operator_number = tr.xpath('td[7]').text.gsub(nbsp, " ").strip

        c.save

      end

    end

    rescue Mechanize::ResponseCodeError => e
      well.document_scrape_status = 'not found'
      well.save
      puts "ResponseCodeError: " + e.to_s
    end

    puts "Time Start: #{start_time}"
    puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end