# COGCC NOAV Scraper

# url=http://cogcc.state.co.us/cogis/IncidentSearch.asp
# itype=noav
# ApiCountyCode=123
# ApiSequenceCode=38087
# maxrec=100

# well links => NOAVReport.asp?doc_num=200402879 

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
require mappings_directory + 'cogcc_noavs'


def sanitize_utf8(string)
  return nil if string.nil?
  return string if string.valid_encoding?
  string.chars.select { |c| c.valid_encoding? }.join
end



# begin error trapping
begin

  start_time = Time.now

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }

  CogccScrapeStatuses.where("noav_scrape_status = 'not scraped' and gid between 100001 and 110000").find_each do |well|
  #CogccScrapeStatuses.where("gid = 11652").find_each do |well|

  begin

    page_url = "http://cogcc.state.co.us/cogis/IncidentSearch.asp"

    page = agent.get(page_url)

    search_form = page.form_with(name: 'cogims2')

    # attrib_1 = 05-xxx-xxxxx
    #search_form['ApiCountyCode'] = '123'
    #search_form['ApiSequenceCode'] = '38087'
    search_form['ApiCountyCode'] = well.well_api_county
    search_form['ApiSequenceCode'] = well.well_api_sequence
    search_form.radiobuttons_with(name: 'itype')[1].check
    search_form.field_with(name: 'maxrec').options[1].select
    search_results = search_form.submit

puts '05-' + well.well_api_county + '-' + well.well_api_sequence

    page = agent.submit(search_form)

    # get http response code to check for valid url
    response = page.code.to_s

    # retreive body html
    doc = Nokogiri::HTML(page.body)

    # grab all links on page
    links = doc.xpath("//a[starts-with(@href, 'NOAVReport')]")

    if links.length > 0 then

puts links

      links.each do |link|

        document_link = link['href'].to_s
        document_number = document_link.match('=').post_match

        report = agent.click(link)
        html = report.body
        doc = Nokogiri::HTML(html)
        doc.encoding = 'UTF-8'
        nbsp = Nokogiri::HTML("&nbsp;").text

        noav = CogccNoavs.new
        noav.well_id = well.well_id
      	noav.document_number = document_number

        noav_date = doc.at('td:contains("Date of Alleged Violation")')
        if !noav_date.at('font:contains("/")').nil? then
          noav.violation_date = noav_date.at('font:contains("/")').text.gsub(nbsp, " ").strip
        end
puts noav.violation_date
        violation = doc.at('tr:contains("Date of Alleged Violation")').next_element
        violation_text = violation.at('td').text
        if !violation_text.nil? then
          alleged_vio = violation_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
          alleged_vio = alleged_vio.encode!('UTF-8', 'UTF-16')
          noav.alleged_violation = alleged_vio.gsub(nbsp, " ").strip
        end
puts noav.alleged_violation
        cite = doc.at('tr:contains("Permit Conditions Cited")').next_element
        cite_text = cite.at('td').text
        if !cite_text.nil? then
          cite_text = cite_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
          cite_text = cite_text.encode!('UTF-8', 'UTF-16')
          noav.cited_condition = cite_text.gsub(nbsp, " ").strip
        end
puts noav.cited_condition
        abatement = doc.at('tr:contains("Performed by Operator")').next_element
        abatement_text = abatement.at('td').text
        if !abatement_text.nil? then
          abate_text = abatement_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
          abate_text = abate_text.encode!('UTF-8', 'UTF-16')
          noav.abatement = abate_text.gsub(nbsp, " ").strip
        end
puts noav.abatement
        completed_date = doc.at('font:contains("Completed by")')
        if !completed_date.at('font:contains("/")').nil? then
          noav.abatement_date = completed_date.at('font:contains("/")').text.gsub(nbsp, " ").strip
        end
puts noav.abatement_date
        # insert noav data
        noav.save
        puts "NOAV data saved!"  

      end

      # mark well noav data as scraped
      well.noav_scrape_status = 'scraped/found'
      well.save
      puts "NOAV data scraped!"

    else

      # mark well noav data as scraped
      well.noav_scrape_status = 'scraped/none'
      well.save
      puts "No NOAV data found."

    end

    rescue Mechanize::ResponseCodeError => e
      well.noav_scrape_status = 'not found'
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