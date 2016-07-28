# COGCC MIT Scraper

# url=http://cogcc.state.co.us/cogis/IncidentSearch.asp
# itype=mit
# ApiCountyCode=123
# ApiSequenceCode=05444
# maxrec=100

# well links => MITReport.asp?doc_num=200405260 

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_scrape_statuses'
require mappings_directory + 'cogcc_mechanical_integrity_tests'


# begin error trapping
begin

  start_time = Time.now

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }

  CogccScrapeStatuses.where("mit_scrape_status = 'not scraped'").find_each do |well|
  #CogccScrapeStatuses.where("gid = 133").find_each do |well|

  begin

    page_url = "http://cogcc.state.co.us/cogis/IncidentSearch.asp"

    page = agent.get(page_url)

    search_form = page.form_with(name: 'cogims2')

    # attrib_1 = 05-xxx-xxxxx
    #search_form['ApiCountyCode'] = '123'
    #search_form['ApiSequenceCode'] = '05444'
    search_form['ApiCountyCode'] = well.well_api_county
    search_form['ApiSequenceCode'] = well.well_api_sequence
    search_form.radiobuttons_with(name: 'itype')[5].check
    search_form.field_with(name: 'maxrec').options[1].select
    search_results = search_form.submit

puts '05-' + well.well_api_county + '-' + well.well_api_sequence

    page = agent.submit(search_form)

    # get http response code to check for valid url
    response = page.code.to_s

    # retreive body html
    doc = Nokogiri::HTML(page.body)

    # grab all links on page
    links = doc.xpath("//a[starts-with(@href, 'MITReport')]")

    if links.length > 0 then

puts links

      links.each do |link|

        document_link = link['href'].to_s
        document_number = document_link.match('=').post_match

        report = agent.click(link)
        html = report.body
        doc = Nokogiri::HTML(html)
        nbsp = Nokogiri::HTML("&nbsp;").text

        mit = CogccMechanicalIntegrityTests.new
        mit.well_id = well.well_id
      	mit.document_number = document_number

        if !doc.at('td:contains("Facility ID")').nil? then
          mit.facility_id = doc.at('td:contains("Facility ID")').next_element.text.gsub(nbsp, " ").strip
        end

        mit.facility_status = doc.at('td:contains("Facility Status")').next_element.text.gsub(nbsp, " ").strip

      	mit.test_type = doc.at('td:contains("Test Type")').next_element.text.gsub(nbsp, " ").strip

        if !doc.at('td:contains("Repair type")').nil? then
          mit.repair_type = doc.at('td:contains("Repair type")').next_element.text.gsub(nbsp, " ").strip
        end

        if !doc.at('td:contains("Repair desc")').nil? then
          mit.repair_description = doc.at('td:contains("Repair desc")').next_element.text.gsub(nbsp, " ").strip
        end

      	mit.test_date = doc.at('td:contains("Test Date")').next_element.text.gsub(nbsp, " ").strip

      	mit.approved_date = doc.at('td:contains("Approved Date")').next_element.text.gsub(nbsp, " ").strip

      	mit.last_approved = doc.at('td:contains("Last Approved")').next_element.text.gsub(nbsp, " ").strip

        mit.formation_zones = doc.at('td:contains("Formation Zones")').next_element.text.gsub(nbsp, " ").strip

      	mit.perforation_interval = doc.at('td:contains("Perforation Interval")').next_element.text.gsub(nbsp, " ").strip

      	mit.open_hole_interval = doc.at('td:contains("Open Hole Interval")').next_element.text.gsub(nbsp, " ").strip

      	mit.plug_depth = doc.at('td:contains("Cement Plug Depth")').next_element.text.gsub(nbsp, " ").strip

      	mit.tubing_size = doc.at('td:contains("Tubing Size")').next_element.text.gsub(nbsp, " ").strip

      	mit.tubing_depth = doc.at('td:contains("Tubing Depth")').next_element.text.gsub(nbsp, " ").strip

      	mit.top_packer_depth = doc.at('td:contains("Top Packer Depth")').next_element.text.gsub(nbsp, " ").strip

      	mit.multiple_packers = doc.at('td:contains("Multiple Packers")').next_element.text.gsub(nbsp, " ").strip

        psi_table = doc.xpath("//table//table//td")

        if !psi_table.at('td:contains("10 MIN CASE")').nil? then

        	mit.ten_min_case_psi = psi_table.at('td:contains("10 MIN CASE")').next_element.text

        	mit.five_min_case_psi = psi_table.at('td:contains("5 MIN CASE")').next_element.text

          if !psi_table.at('td:contains("CASE BEFORE")').nil? then
        	  mit.case_before_psi = psi_table.at('td:contains("CASE BEFORE")').next_element.text
          end

        	mit.final_case_psi = psi_table.at('td:contains("FINAL CASE")').next_element.text

          if !psi_table.at('td:contains("FINAL TUBE")').nil? then
        	  mit.final_tube_psi = psi_table.at('td:contains("FINAL TUBE")').next_element.text
        	end

          if !psi_table.at('td:contains("INITIAL TUBE")').nil? then
        	  mit.initial_tube_psi = psi_table.at('td:contains("INITIAL TUBE")').next_element.text
        	end

          if !psi_table.at('td:contains("LOSS OR GAIN")').nil? then
        	  mit.loss_gain_psi = psi_table.at('td:contains("LOSS OR GAIN")').next_element.text
        	end

        	mit.start_case_psi = psi_table.at('td:contains("START CASE")').next_element.text

        end

        # insert mit test results
        mit.save
        puts "MIT results saved!"  

      end

      # mark well mit tests as scraped
      well.mit_scrape_status = 'scraped/found'
      well.save
      puts "MIT tests scraped!"

    else

      # mark well mit tests as scraped
      well.mit_scrape_status = 'scraped/none'
      well.save
      puts "No MIT tests found."

    end

    rescue Mechanize::ResponseCodeError => e
      well.mit_scrape_status = 'not found'
      well.save
      puts "ResponseCodeError: " + e.to_s
    end

  end

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end