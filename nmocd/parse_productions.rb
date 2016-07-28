# NMOCD Well Productions Parser

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'nmocd_well_details'
require mappings_directory + 'nmocd_well_productions'


# begin error trapping
begin

  start_time = Time.now

  nbsp = Nokogiri::HTML("&nbsp;").text

  calendar_months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

#  NmocdWellDetails.find_by_sql("SELECT id, api_number, html_data_details, nmocd_well_id FROM nmocd_well_details WHERE is_san_juan IS TRUE AND productions_parsed IS FALSE AND html_data_details IS NOT NULL ORDER BY api_number LIMIT 5000").each do |w|
#  NmocdWellDetails.find_by_sql("SELECT id, api_number, html_data_details, nmocd_well_id FROM nmocd_well_details WHERE in_use IS FALSE AND is_san_juan IS TRUE AND has_production_records IS TRUE AND nmocd_well_id NOT IN (SELECT DISTINCT nmocd_well_id FROM nmocd_well_productions)").each do |w|
#  NmocdWellDetails.find_by_sql("SELECT id, api_number, html_data_details, nmocd_well_id FROM nmocd_well_details WHERE in_use IS FALSE AND is_san_juan IS FALSE AND has_production_records IS TRUE AND nmocd_well_id NOT IN (SELECT DISTINCT nmocd_well_id FROM nmocd_well_productions) ORDER BY api_number LIMIT 1000").each do |w|
#  NmocdWellDetails.find_by_sql("SELECT id, api_number, html_data_details, nmocd_well_id FROM nmocd_well_details WHERE in_use IS FALSE AND missed_prod_scrape IS TRUE AND has_production_records IS TRUE AND nmocd_well_id NOT IN (SELECT DISTINCT nmocd_well_id FROM nmocd_well_productions) ORDER BY api_number LIMIT 1000").each do |w|

  NmocdWellDetails.find_by_sql("SELECT id, api_number, html_data_details, nmocd_well_id FROM nmocd_well_details WHERE in_use IS FALSE AND missed_prod_scrape IS TRUE AND html_data_details IS NOT NULL AND nmocd_well_id NOT IN (SELECT DISTINCT nmocd_well_id FROM nmocd_well_productions) ORDER BY api_number LIMIT 3000").each do |w|


#api_number IN ('30-015-27784','30-015-37309','30-025-10945','30-025-10946','30-025-10948','30-025-10949')
#'30-015-27784' QUAHADA RIDGE;DELAWARE, SOUTHEAST
#'30-015-37309' QUAHADA RIDGE;DELAWARE, SOUTHEAST
#'30-025-10945' TEAGUE;PADDOCK-BLINEBRY
#'30-025-10946' TEAGUE;PADDOCK-BLINEBRY
#'30-025-10948' TEAGUE;PADDOCK-BLINEBRY
#'30-025-10949' TEAGUE;PADDOCK-BLINEBRY

  ActiveRecord::Base.transaction do

    puts w.api_number

    doc = Nokogiri::HTML(w.html_data_details)

    results = doc.xpath('//table[@class="tblData productionresults"]')

    results_html = Nokogiri::HTML(results.to_html)

    # find which years exist
    aryYears = Array.new
    (1992..2015).each do |i|
      if !results.at("//tr[@class='prod_for_#{i}']").nil?
        aryYears << i
      end
    end

    # loop through production years
    aryYears.each_with_index do |prod_year,y|

      puts prod_year

      skip_year = false
      if w.api_number == "30-015-27784" && prod_year == 2000
        skip_year = true
      end
      if w.api_number == "30-015-37309" && prod_year == 2010
        skip_year = true
      end
      if w.api_number == "30-025-10945" && prod_year == 1997
        skip_year = true
      end
      if w.api_number == "30-025-10946" && prod_year == 1992
        skip_year = true
      end
      if w.api_number == "30-025-10946" && prod_year == 1993
        skip_year = true
      end
      if w.api_number == "30-025-10946" && prod_year == 1997
        skip_year = true
      end
      if w.api_number == "30-025-10948" && prod_year == 1997
        skip_year = true
      end
      if w.api_number == "30-025-10949" && prod_year == 1997
        skip_year = true
      end

      if !skip_year

      prod_start_node = results.at("tr[@class='prod_for_#{prod_year}']")
      if prod_year == aryYears[y]
        prod_end_node = results.at("tr[@id='footer_#{prod_year}']")
      else
        prod_end_node = results.at("tr[@class='prod_for_#{prod_year+1}']")        
      end

      prod_year_html = Nokogiri::XML::NodeSet.new(results_html)
      prod_year_node = prod_start_node.next_sibling
      loop do
        break if prod_year_node == prod_end_node
        prod_year_html << prod_year_node
        prod_year_node = prod_year_node.next_sibling
      end

      formation_nodes = prod_year_html.xpath('td[@style="width: auto;"]')

      # loop through formations
      (0..formation_nodes.size-1).each do |f|

        this_formation_name = formation_nodes[f].text.gsub(nbsp, " ").strip
        if f < formation_nodes.size-1
          next_formation_name = formation_nodes[f+1].text.gsub(nbsp, " ").strip
        end

        puts this_formation_name

        if this_formation_name == "BULL'S EYE;SAN ANDRES"
          this_formation_name = "S EYE;SAN ANDRES"
        end

        start_formation_node = prod_year_html.at("tr[@class='prod_for_#{prod_year}']/td:contains('#{this_formation_name}')").parent

        if f == formation_nodes.size-1
          end_formation_node = prod_year_html.at("tr[@id='footer_#{prod_year}']")
        else
          end_formation_node = prod_year_html.at("tr[@class='prod_for_#{prod_year}']/td:contains('#{next_formation_name}')").parent
        end

        prod_year_html = Nokogiri::HTML(prod_year_html.to_html)

        formation_html = Nokogiri::XML::NodeSet.new(prod_year_html)
        formation_node = start_formation_node.next_sibling
        loop do
          break if formation_node == end_formation_node
          formation_html << formation_node
          formation_node = formation_node.next_sibling
        end

        formation_html = Nokogiri::HTML(formation_html.to_html)

        # loop through months
        calendar_months.each do |m|

          if !formation_html.at("tr[@class='prod_for_#{prod_year}']/td[@class='rowheader']:contains('#{m}')").nil? then

            month_row = formation_html.at("td[@class='rowheader']:contains('#{m}')").parent

            puts "#{m}: Oil(bbls) = #{month_row.at("td[2]").text}, Gas(mcf) = #{month_row.at("td[3]").text}, Water(bbls) = #{month_row.at("td[4]").text}, Days P/I = #{month_row.at("td[5]").text}"

            p = NmocdWellProductions.new

            p.nmocd_well_id = w.nmocd_well_id
            p.record_year = prod_year
            p.record_month = m
            p.formation_name = this_formation_name
            p.prod_oil_bbls = month_row.at("td[2]").text
            p.prod_gas_mcf = month_row.at("td[3]").text
            p.prod_water_bbls = month_row.at("td[4]").text
            p.days_prod_inj = month_row.at("td[5]").text
            p.inj_water_bbls = month_row.at("td[6]").text
            p.inj_co2_mcf = month_row.at("td[7]").text
            p.inj_gas_mcf = month_row.at("td[8]").text
            p.inj_other = month_row.at("td[9]").text
            p.inj_pressure = month_row.at("td[10]").text
            p.save!

          end

        end # end month loop

      end # end formation loop

    end

    end # end year loop

#    w.productions_parsed = true
    w.in_use = true
    w.save!

  end # transaction

  end # end well loop

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
end

# 113740 - Total wells
# 37007 - San Juan total
# 76733 - Non-San Juan total
#
# 73347 - Distinct production wells
# 26824 - San Juan prod wells
# 46523 - Non-San Juan prod wells
#
# 10121 - No. expected SJ wells w/ no prod
# 23571 - No. expected non-SJ wells w/ no prod
#
# San Juan check => 26824 + 10121 = 36945 (actual is 37007) pretty darn close, diff of 62
# Non-SJ check => 46523 + 23571 = 70094 (actual is 76733) short by 6639, need to investigate (278 based on html_saved flag -- better)
#
# Num wells with HTML saved => 107379 (37007 for SJ and 70372 for Non-SJ)
#
# select id, api, compl_status from nmocd_wells where id not in (select distinct nmocd_well_id from nmocd_well_productions where is_san_juan is true union select nmocd_well_id from nmocd_well_details where html_data_details ilike '%<span id="ctl00_ctl00__main_main_ucProduction_lblLastProduction"></span>%' and is_san_juan is true);