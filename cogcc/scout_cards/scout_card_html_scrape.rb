#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# COGCC Scout Card HTML Downloader

# sample URL: cogcc.state.co.us/cogis/FacilityDetail.asp?facid=12335263&type=WELL

# UNIX shell script to run scraper: while true; do ./scout_card_html_scrape.rb & sleep 15; done

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'well_scout_card_scrapes'
require mappings_directory + 'cogcc_html_scout_cards'

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

  WellScoutCardScrapes.find_by_sql("SELECT * FROM well_scout_card_scrapes WHERE in_use IS FALSE AND html_saved IS FALSE LIMIT 1").each do |well|
  #WellScoutCardScrapes.find_by_sql("SELECT * FROM well_production_scrapes WHERE well_id = 12335263").each do |well|

  begin

    puts "Well #{well.well_id} in use!"

    well.in_use = true
    well.save!

    ActiveRecord::Base.transaction do

      page_url = "http://cogcc.state.co.us/cogis/FacilityDetail.asp?facid=#{well.well_id}&type=WELL"

      page = agent.get(page_url)

      response = page.code.to_s

      if response == "200" then

        sc = CogccHtmlScoutCards.new
        sc.well_id = well.well_id
      	sc.scout_card = page.body
        sc.save!

        well.html_status = "page saved"

      else

        well.html_status = "page not found"

      end # end response check

      well.html_saved = true
      well.in_use = false
      well.save!

    end # activerecord transaction

    rescue Mechanize::ResponseCodeError => e
      well.html_status = "page not found"
      well.html_saved = true
      well.in_use = false
      well.save!
      puts "ResponseCodeError: " + e.to_s
    end

    puts "Well scrape completed!"

  end # end well loop

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end

