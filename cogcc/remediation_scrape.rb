# COGCC Remediation Scraper

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_remediations'
require mappings_directory + 'counties'


# begin error trapping
begin

  start_time = Time.now

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  agent = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }

  #page_url = "file:///Users/troyburke/Projects/ruby/cogcc/remediations_v3.html"

  page_url = "http://cogcc.state.co.us/cogis/IncidentSearch.asp"

  nbsp = Nokogiri::HTML("&nbsp;").text

  Counties.find_by_sql("SELECT * FROM counties WHERE state_name = 'Colorado' AND in_use IS FALSE AND cogcc_remediations_scraped IS FALSE LIMIT 1").each do |county|

  begin

    puts "County: #{county.cnty_fips}"
    county.in_use = true
    county.save!

    ActiveRecord::Base.transaction do

      page = agent.get(page_url)

      search_form = page.form_with(name: 'cogims2')

      search_form.radiobuttons_with(name: 'itype')[4].check
      search_form.field_with(name: 'ApiCountyCode').value = county.cnty_fips
      search_form.field_with(name: 'maxrec').value = 5000
      search_results = search_form.submit

      page = agent.submit(search_form)

      # get http response code to check for valid url
      response = page.code.to_s

      # retreive body html
      doc = Nokogiri::HTML(page.body)

      results_table = doc.xpath('//table[2]')

      if doc.at('th:contains("No Records Found.")').nil? then

        results_table.css('tr').each_with_index do |tr,i|

          if i >= 2 then

            r = CogccRemediations.new

            r.submit_date = tr.xpath('td[1]').text.gsub(nbsp, " ").strip
            r.document_number = tr.xpath('td[2]').text.gsub(nbsp, " ").strip
            r.document_url = tr.xpath('td[2]').at('a')['href'].to_s
            r.project_number = tr.xpath('td[3]').text.gsub(nbsp, " ").strip
            r.facility_type = tr.xpath('td[4]').text.gsub(nbsp, " ").strip
            r.facility_id = tr.xpath('td[5]').text.gsub(nbsp, " ").strip
            r.operator_name = tr.xpath('td[6]').text.gsub(nbsp, " ").strip
            r.operator_number = tr.xpath('td[7]').text.gsub(nbsp, " ").strip
            r.fips_code = county.cnty_fips

            r.save!

          end

        end # end table row loop

      end # record check

      county.cogcc_remediations_scraped = true
      county.in_use = false
      county.save!
      puts "County completed!"

    end # transaction

    rescue Mechanize::ResponseCodeError => e
      puts "ResponseCodeError: " + e.to_s
    end

  end # county loop

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end