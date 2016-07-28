#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# COGCC Production Inquiry Scraper

# sample URL: http://cogcc.state.co.us/cogis/ProductionWellMonthly.asp?APICounty=123&APISeq=05091&APIWB=00&Year=2013

# UNIX shell script to run scraper: while true; do ./production_scraper.rb & sleep 15; done

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
require mappings_directory + 'cogcc_well_productions'


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

  nbsp = Nokogiri::HTML("&nbsp;").text

  CogccScrapeStatuses.find_by_sql("SELECT * FROM cogcc_scrape_statuses WHERE production_scrape_status = 'not scraped' LIMIT 1").each do |well|
  #CogccScrapeStatuses.where("well_api_county = '123' AND well_api_sequence = '05091'").find_each do |well|

  begin

    puts '05-' + well.well_api_county + '-' + well.well_api_sequence

    year_list = Array.new

    ActiveRecord::Base.transaction do

      (1999..2014).each do |prod_year| 

        page_url = "http://cogcc.state.co.us/cogis/ProductionWellMonthly.asp?APICounty=#{well.well_api_county}&APISeq=#{well.well_api_sequence}&APIWB=00&Year=#{prod_year}"

        page = agent.get(page_url)

        response = page.code.to_s

        doc = Nokogiri::HTML(page.body)

        if doc.at('p:contains("No Records Found.")').nil? then

          year_list.push(prod_year)

          results_table = doc.xpath('//table[@width="75%"]')

          results_table.css('tr').each_with_index do |tr,i|

            if i >= 5 then

              p = CogccWellProductions.new

              p.well_id = well.well_id
              p.production_year = prod_year
              p.production_month = tr.xpath('td[1]').text.gsub(nbsp, " ").strip
              p.formation_name = tr.xpath('td[2]').text.gsub(nbsp, " ").strip
              p.well_status_code = tr.xpath('td[4]').text.gsub(nbsp, " ").strip
              if !tr.xpath('td[5]').text.nil? then
                p.days_producing = tr.xpath('td[5]').text.gsub(nbsp, " ").strip
              end

              td_7 = tr.xpath('td[7]')
              td_7.search('br').each do |n|
                n.replace("\n")
              end
              if !td_7.text.split("\n")[0].nil? then
                p.oil_bom = td_7.text.split("\n")[0].gsub(nbsp, " ").strip
              end
              if !td_7.text.split("\n")[2].nil? then
                p.gas_production = td_7.text.split("\n")[2].gsub(nbsp, " ").strip
              end

              td_8 = tr.xpath('td[8]')
              td_8.search('br').each do |n|
                n.replace("\n")
              end
              if !td_8.text.split("\n")[0].nil? then
                p.oil_produced = td_8.text.split("\n")[0].gsub(nbsp, " ").strip
              end
              if !td_8.text.split("\n")[2].nil? then
                p.gas_flared = td_8.text.split("\n")[2].gsub(nbsp, " ").strip
              end

              td_9 = tr.xpath('td[9]')
              td_9.search('br').each do |n|
                n.replace("\n")
              end
              if !td_9.text.split("\n")[0].nil? then
                p.oil_sold = td_9.text.split("\n")[0].gsub(nbsp, " ").strip
              end
              if !td_9.text.split("\n")[2].nil? then
                p.gas_used = td_9.text.split("\n")[2].gsub(nbsp, " ").strip
              end

              td_10 = tr.xpath('td[10]')
              td_10.search('br').each do |n|
                n.replace("\n")
              end
              if !td_10.text.split("\n")[0].nil? then
                p.oil_adj = td_10.text.split("\n")[0].gsub(nbsp, " ").strip
              end
              if !td_10.text.split("\n")[2].nil? then
                p.gas_shrinkage = td_10.text.split("\n")[2].gsub(nbsp, " ").strip
              end

              td_11 = tr.xpath('td[11]')
              td_11.search('br').each do |n|
                n.replace("\n")
              end
              if !td_11.text.split("\n")[0].nil? then
                p.oil_eom = td_11.text.split("\n")[0].gsub(nbsp, " ").strip
              end
              if !td_11.text.split("\n")[2].nil? then
                p.gas_sold = td_11.text.split("\n")[2].gsub(nbsp, " ").strip
              end

              td_12 = tr.xpath('td[12]')
              td_12.search('br').each do |n|
                n.replace("\n")
              end
              if !td_12.text.split("\n")[0].nil? then
                p.oil_gravity = td_12.text.split("\n")[0].gsub(nbsp, " ").strip
              end
              if !td_12.text.split("\n")[2].nil? then
                p.gas_btu = td_12.text.split("\n")[2].gsub(nbsp, " ").strip
              end

              td_13 = tr.xpath('td[13]')
              td_13.search('br').each do |n|
                n.replace("\n")
              end
              if !td_13.text.split("\n")[0].nil? then
                p.water_production = td_13.text.split("\n")[0].gsub(nbsp, " ").strip
              end
              if !td_13.text.split("\n")[1].nil? then
                p.water_disposal_code = td_13.text.split("\n")[1].gsub(nbsp, " ").strip
              end

              p.save

            end 

          end # end table row loop

        end # end results check      

      end # end year loop

      if !year_list.empty? then
        well.production_scrape_status = year_list.join(',')
      else
        well.production_scrape_status = 'not found'
      end
      well.save

    end # activerecord transaction

    rescue Mechanize::ResponseCodeError => e
      well.production_scrape_status = 'not found'
      well.save
      puts "ResponseCodeError: " + e.to_s
    end

    puts well.production_scrape_status

  end # end well loop

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end