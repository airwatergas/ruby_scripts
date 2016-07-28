#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# WOGCC Casings Scraper

# UNIX shell script to run scraper: while true; do ./casings_scraper.rb & sleep 5; done

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require 'mechanize'
require 'nokogiri'

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'casing_scrapes'
require mappings_directory + 'casings'


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

  if CasingScrapes.where(in_use: true).count == 0 then

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


  CasingScrapes.find_by_sql("SELECT * FROM casing_scrapes WHERE well_status = 'PO' AND in_use IS FALSE AND scrape_status = 'not scraped' ORDER BY api_no LIMIT 1").each do |w|

  ActiveRecord::Base.transaction do

    puts "Well #{w.api_no} in use!"

    w.in_use = true
    w.save!

    page_url = "http://wogcc.state.wy.us/wyocsg.cfm?nAPI=#{w.api_no}"

    page = agent.get(page_url)

    response = page.code.to_s

    if response == "200"

      doc = Nokogiri::HTML(page.body)

      tops_table =  doc.xpath("/html/body/table[2]")

      if tops_table.text.nil?

        w.scrape_status = "no records found"

      else

        tops_table.css('tr').each_with_index do |tr,i|

          if i >= 3

            c = Casings.new
            c.api_no = w.api_no
            c.hole_size = tr.xpath('td[2]').text.gsub(nbsp, " ").strip
            c.casing_size = tr.xpath('td[3]').text.gsub(nbsp, " ").strip
            c.casing_depth = tr.xpath('td[4]').text.gsub(nbsp, " ").strip
            c.casing_weight = tr.xpath('td[5]').text.gsub(nbsp, " ").strip
            c.casing_type = tr.xpath('td[6]').text.gsub(nbsp, " ").strip
            c.cement = tr.xpath('td[7]').text.gsub(nbsp, " ").strip
            puts c.inspect
            c.save!

          end
     
        end

        w.scrape_status = "casings saved"

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
