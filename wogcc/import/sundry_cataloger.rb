#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# WOGCC Sundry Cataloger

# UNIX shell script to run scraper: while true; do ./sundry_cataloger.rb & sleep 8; done

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require 'mechanize'
require 'nokogiri'

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'sundry_scrapes'
require mappings_directory + 'sundries'


# begin error trapping
begin

  start_time = Time.now

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase, schema_search_path: getDBSchema } )

  # use random browser
  agent_aliases = [ 'Windows IE 7', 'Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla', 'Linux Mozilla', 'Linux Firefox' ]
  agent_alias = agent_aliases[rand(0..6)]

  agent = Mechanize.new { |agent| agent.user_agent_alias = agent_alias }

  puts agent_alias

  nbsp = Nokogiri::HTML("&nbsp;").text

  if SundryScrapes.where(in_use: true).count == 0 then

#  53391 | PA
#  25729 | PG
#  14428 | EP
#  11745 | well_status = 'PO'
#   9615 | SI
#   5623 | SR
#   3530 | AI
#   2885 | AP
#   2575 | WP
#   2042 | NI
#   1080 | TA
#   2207 | well_status IN ('NO','SP','PS','FL','PR','SO','MW','DR','ND','NR','DH','GL','PL','DP','PH','M','GS')

# below are completed #


  SundryScrapes.find_by_sql("SELECT * FROM sundry_scrapes WHERE well_status = 'PO' AND in_use IS FALSE AND scrape_status = 'not scraped' ORDER BY api_no LIMIT 1").each do |w|

  ActiveRecord::Base.transaction do

    puts "Well #{w.api_no} in use!"

    w.in_use = true
    w.save!

    page_url = "http://wogcc.state.wy.us/wyosund.cfm?napi=#{w.api_no}"

    page = agent.get(page_url)

    response = page.code.to_s

    if response == "200"

      doc = Nokogiri::HTML(page.body)

      if  doc.text.include? "No Records Found"

        w.scrape_status = "no records"

      else

        doc_table =  doc.xpath("/html/body/table[2]")

        doc_table.css('tr').each_with_index do |tr,i|

          if i >= 1

            s = Sundries.new
            s.api_no = w.api_no
            s.document_url = tr.xpath('td[1]/a/@href')
            s.submit_date = tr.xpath('td[2]').text.gsub(nbsp, " ").strip
            s.submission = tr.xpath('td[3]').text.gsub(nbsp, " ").strip
            s.action = tr.xpath('td[4]').text.gsub(nbsp, " ").strip
            s.action_other = tr.xpath('td[5]').text.gsub(nbsp, " ").strip
            s.date_received = tr.xpath('td[6]').text.gsub(nbsp, " ").strip

            puts s.inspect
            s.save!

          end
     
        end

        w.scrape_status = "sundries saved"

      end

    else

      w.scrape_status = "page not found"

    end # end response check

    puts w.scrape_status

    w.in_use = false
    w.save!

  end # transaction

  end # end well loop

  end # in use check

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
end
