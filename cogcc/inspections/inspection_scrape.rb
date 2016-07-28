# COGCC Inspection Scraper

# Include required classes and models:

require '../../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_inspections'


# begin error trapping
begin

  start_time = Time.now

  start_date = 305.months.ago.to_date # Thu, 25 Jan 1990
  end_date = Date.today # Thu, 25 Jun 2015
  number_of_months = (end_date.year*12+end_date.month)-(start_date.year*12+start_date.month) # 305

  dates = number_of_months.times.each_with_object([]) do |count, array|
    array << [start_date.beginning_of_month + count.months, start_date.end_of_month + count.months]
  end

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  # loop over each month in dates array
  (304..304).each do |i|

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

puts dates[i].first.strftime("%m/%d/%Y")
puts dates[i].last.strftime("%m/%d/%Y")

      search_form.radiobuttons_with(name: 'itype')[0].check
      search_form.field_with(name: 'maxrec').value = 6000
#      search_form.field_with(name: 'Date1').value = dates[i].first.strftime("%m/%d/%Y")
#      search_form.field_with(name: 'Date2').value = dates[i].last.strftime("%m/%d/%Y")
      search_form.field_with(name: 'Date1').value = "06/01/2015"
      search_form.field_with(name: 'Date2').value = "06/30/2015"
      search_results = search_form.submit

      page = agent.submit(search_form)

      # get http response code to check for valid url
      response = page.code.to_s

      # retreive body html
      doc = Nokogiri::HTML(page.body)

      results_table = doc.xpath('//table[2]')
      old_results_table = doc.xpath('//table[3]')

      results_table.css('tr').each_with_index do |tr,r|

        if r >= 2 then

          s = CogccInspections.new

        	s.inspection_date = tr.xpath('td[1]').text.gsub(nbsp, " ").strip
        	s.document_number = tr.xpath('td[2]').text.gsub(nbsp, " ").strip
        	s.document_id = tr.xpath('td[2]').at('a')['href'].to_s.split('=')[1]
        	s.location_id = tr.xpath('td[3]').text.gsub(nbsp, " ").strip
        	s.api_number = tr.xpath('td[4]').text.gsub(nbsp, " ").strip
        	s.status_code = tr.xpath('td[5]').text.gsub(nbsp, " ").strip
        	s.overall_inspection_status = tr.xpath('td[6]').text.gsub(nbsp, " ").strip
        	s.overall_ir = tr.xpath('td[7]').text.gsub(nbsp, " ").strip
        	s.overall_fr = tr.xpath('td[8]').text.gsub(nbsp, " ").strip
        	s.violation = tr.xpath('td[9]').text.gsub(nbsp, " ").strip

          s.save!

        end

      end

      old_results_table.css('tr').each_with_index do |tr,o|

        if o >= 2 then

          s = CogccInspections.new

        	s.inspection_date = tr.xpath('td[1]').text.gsub(nbsp, " ").strip
        	s.document_number = tr.xpath('td[2]').text.gsub(nbsp, " ").strip
        	s.inspection_type = tr.xpath('td[3]').text.gsub(nbsp, " ").strip
        	s.status_code = tr.xpath('td[4]').text.gsub(nbsp, " ").strip
        	s.overall_inspection_status = tr.xpath('td[5]').text.gsub(nbsp, " ").strip
        	s.reclamation = tr.xpath('td[6]').text.gsub(nbsp, " ").strip
        	s.p_and_a = tr.xpath('td[7]').text.gsub(nbsp, " ").strip
        	s.violation = tr.xpath('td[8]').text.gsub(nbsp, " ").strip

          s.save!

        end

      end


      rescue Mechanize::ResponseCodeError => e
        puts "ResponseCodeError: " + e.to_s
      end

puts "Inspections saved!"
puts ""

      sleep 10

    end # end month array loop

    puts "Time Start: #{start_time}"
    puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end