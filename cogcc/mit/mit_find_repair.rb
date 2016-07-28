# COGCC find MIT records with repair info

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

      links.each do |link|

        report = agent.click(link)
        html = report.body
        doc = Nokogiri::HTML(html)

        if !doc.at('td:contains("Repair type")').nil? then
          well.mit_scrape_status = 'repair found'
          well.save
          puts "MIT repair description found!"
        else 
          well.mit_scrape_status = 'scraped'
          well.save
        end

      end

    else

      well.mit_scrape_status = 'scraped'
      well.save

    end

    rescue Mechanize::ResponseCodeError => e
      puts "ResponseCodeError: " + e.to_s
      well.mit_scrape_status = 'scraped'
      well.save
    end

  end

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end