#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# WOGCC Productions Scraper

# UNIX shell script to run scraper: while true; do ./production_scraper.rb & sleep 10; done

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require 'mechanize'
require 'nokogiri'
require 'csv'

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'production_scrapes'
require mappings_directory + 'productions'


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

  if ProductionScrapes.where(in_use: true).count == 0 then

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


  ProductionScrapes.find_by_sql("SELECT * FROM production_scrapes WHERE well_status = 'PO' AND in_use IS FALSE AND scrape_status = 'not scraped' ORDER BY api_no LIMIT 1").each do |w|

  ActiveRecord::Base.transaction do

    puts "Well #{w.api_no} in use!"

    w.in_use = true
    w.save!

    form_url = "http://wogcc.state.wy.us/reservoirexcel.cfm?nAPINO=#{w.api_no}"

    post_url = "http://wogcc.state.wy.us/DWPRODPIMS.cfm"

    form_page = agent.get(form_url)

    form_doc = Nokogiri::HTML(form_page.body)

    if form_doc.text.include? "Injected Volumes"

      w.scrape_status = "not found"

    else

      post_results = agent.post(post_url, {
        "uniquenumber" => form_doc.at('input[@name="uniquenumber"]')['value'],
        "Oops" => form_doc.at('input[@name="Oops"]')['value'],
        "oneapi" => form_doc.at('input[@name="oneapi"]')['value'],
        "GoGet" => 8,
      })

      response = post_results.code.to_s

      if response == "200"

        csv = CSV.parse(post_results.body, :headers => true)

        csv.each do |row|

          row.map

          puts row.inspect

          p = Productions.new

          p.api_no = w.api_no
        	p.api_res = row[0]
        	p.month_year = row[1]
        	p.oil_bbls = row[2]
        	p.gas_mcf = row[3]
        	p.water_bbls = row[4]
        	p.days = row[5]

          p.save!

        end # end csv row loop

        w.scrape_status = "productions saved"

      else

        w.scrape_status = "not found"

      end # end response check

    end # productions form check

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
