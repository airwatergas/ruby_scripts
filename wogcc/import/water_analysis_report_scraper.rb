#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# WOGCC HTML Water Analysis Report Scraper

# UNIX shell script to run scraper: while true; do ./water_analysis_report_scraper.rb & sleep 5; done

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require 'mechanize'
require 'nokogiri'

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'scrape_statuses'


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

  if ScrapeStatuses.where(in_use: true).count == 0 then


#  14428 | well_status = 'EP' (expired permit) [9722...]


# below are completed #
#  53391 | well_status = 'PA' [8746...9721]
#  11745 | well_status = 'PO' (1482)
#   2207 | well_status IN ('NO','SP','PS','FL','PR','SO','MW','DR','ND','NR','DH','GL','PL','DP','PH','M','GS') [1482...1595]
#  25729 | well_status = 'PG' [1595 - 7446]
#   9615 | well_status = 'SI' [7447...7507 and 7657...8120]
#   1080 | well_status = 'TA' [7508...7572]
#   2042 | well_status = 'NI' [7573...7656]
#   3530 | well_status = 'AI' [8121...8549]
#   5623 | well_status = 'SR' [8550...8745]
#   2885 | well_status = 'AP' [9722...9722]
#   2575 | well_status = 'WP' [9722...9722]

  ScrapeStatuses.find_by_sql("SELECT * FROM scrape_statuses WHERE well_status = 'EP' AND in_use IS FALSE AND war_status = 'not scraped' ORDER BY api_no DESC LIMIT 1").each do |w|

  begin

    puts "Well #{w.api_no} in use!"

    w.in_use = true
    w.save!

    page_url = "http://wogcc.state.wy.us/Warapi.cfm?nApino=#{w.api_no}"

    page = agent.get(page_url)

    response = page.code.to_s

    if response == "200"
      html_html = Nokogiri::HTML(page.body)
      html_text = html_html.text
      if html_text.include? "No Records Found For This Well"
        w.war_status = "no records found"
      else
        w.war_html = html_html
        w.war_status = "html saved"
      end 
    else
      w.html_status = "page not found"
    end # end response check

    puts w.war_status

    w.in_use = false
    w.save!

    rescue Mechanize::ResponseCodeError => e
      w.war_status = "page not found"
      w.in_use = false
      w.save!
      puts "ResponseCodeError: " + e.to_s
    end

  end # end well loop

  end # in use check

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end