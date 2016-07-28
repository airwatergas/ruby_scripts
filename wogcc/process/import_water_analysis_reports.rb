# NMOCD Well Productions Parser

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require 'nokogiri'

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'scrape_statuses'
require mappings_directory + 'water_analysis_reports'


# begin error trapping
begin

  start_time = Time.now

  nbsp = Nokogiri::HTML("&nbsp;").text

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase, schema_search_path: getDBSchema } )

  ScrapeStatuses.find_by_sql("SELECT id, api_no, war_sample_count, war_liquid_analysis_count, war_gas_analysis_count, war_html FROM scrape_statuses WHERE api_no <> 928224 AND html_parsed IS FALSE AND war_status = 'html saved' AND war_sample_count > 0 ORDER BY api_no").each do |w|

    ActiveRecord::Base.transaction do

    puts w.api_no

    doc = Nokogiri::HTML(w.war_html)

    sample_count = 1 + w.war_liquid_analysis_count + war_gas_analysis_count

    (1..w.war_sample_count).each do |s|

      if s == 1
        sample_count = sample_count + 1
      else
        sample_count = sample_count + 3
      end

      header_html = doc.xpath("/html/body/table[#{sample_count}]")
      ions_html = doc.xpath("/html/body/table[#{sample_count+1}]")
      other_html = doc.xpath("/html/body/table[#{sample_count+2}]")

      war = WaterAnalysisReports.new

      war.api_no = w.api_no

      war.operator_name = header_html.at("tr[1]/td[1]").text.gsub(nbsp, " ").strip
    	war.field_name = header_html.at("tr[1]/td[5]").text.gsub(nbsp, " ").strip
    	war.well_api_number = header_html.at("tr[2]/td[2]").text.gsub(nbsp, " ").strip
    	war.well_name = header_html.at("tr[2]/td[5]").text.gsub(nbsp, " ").strip
    	war.formation_name = header_html.at("tr[3]/td[2]").text.gsub(nbsp, " ").strip
    	war.plss_location = header_html.at("tr[3]/td[5]").text.gsub(nbsp, " ").strip
    	war.date_sampled = header_html.at("tr[4]/td[2]").text.gsub(nbsp, " ").strip
    	war.perf_interval = header_html.at("tr[4]/td[5]").text.gsub(nbsp, " ").strip
    	sampled_by_html = header_html.at("tr[5]/td[2]")
    	if !sampled_by_html.nil?
    	  war.sampled_by = sampled_by_html.text.gsub(nbsp, " ").strip
    	end

      war.sodium_mgl = ions_html.at("tr[2]/td[2]").text.gsub(nbsp, " ").strip
    	war.sodium_meql = ions_html.at("tr[2]/td[3]").text.gsub(nbsp, " ").strip
    	war.potassium_mgl = ions_html.at("tr[3]/td[2]").text.gsub(nbsp, " ").strip
    	war.potassium_meql = ions_html.at("tr[3]/td[3]").text.gsub(nbsp, " ").strip
    	war.lithium_mgl = ions_html.at("tr[4]/td[2]").text.gsub(nbsp, " ").strip
    	war.lithium_meql = ions_html.at("tr[4]/td[3]").text.gsub(nbsp, " ").strip
    	war.calcium_mgl = ions_html.at("tr[5]/td[2]").text.gsub(nbsp, " ").strip
    	war.calcium_meql = ions_html.at("tr[5]/td[3]").text.gsub(nbsp, " ").strip
    	war.magnesium_mgl = ions_html.at("tr[6]/td[2]").text.gsub(nbsp, " ").strip
    	war.magnesium_meql = ions_html.at("tr[6]/td[3]").text.gsub(nbsp, " ").strip
    	war.iron_mgl = ions_html.at("tr[7]/td[2]").text.gsub(nbsp, " ").strip
    	war.iron_meql = ions_html.at("tr[7]/td[3]").text.gsub(nbsp, " ").strip
    	war.total_cations = ions_html.at("tr[9]/td[2]").text.gsub(nbsp, " ").strip
    	war.sulfate_mgl = ions_html.at("tr[2]/td[7]").text.gsub(nbsp, " ").strip
    	war.sulfate_meql = ions_html.at("tr[2]/td[8]").text.gsub(nbsp, " ").strip
    	war.chloride_mgl = ions_html.at("tr[3]/td[7]").text.gsub(nbsp, " ").strip
    	war.chloride_meql = ions_html.at("tr[3]/td[8]").text.gsub(nbsp, " ").strip
    	war.carbonate_mgl = ions_html.at("tr[4]/td[7]").text.gsub(nbsp, " ").strip
    	war.carbonate_meql = ions_html.at("tr[4]/td[8]").text.gsub(nbsp, " ").strip
    	war.bicarbonate_mgl = ions_html.at("tr[5]/td[7]").text.gsub(nbsp, " ").strip
    	war.bicarbonate_meql = ions_html.at("tr[5]/td[8]").text.gsub(nbsp, " ").strip
    	war.hydroxide_mgl = ions_html.at("tr[6]/td[7]").text.gsub(nbsp, " ").strip
    	war.hydroxide_meql = ions_html.at("tr[6]/td[8]").text.gsub(nbsp, " ").strip
    	war.hydrogen_sulfide_mgl = ions_html.at("tr[7]/td[7]").text.gsub(nbsp, " ").strip
    	war.hydrogen_sulfide_meql = ions_html.at("tr[7]/td[8]").text.gsub(nbsp, " ").strip
    	war.total_anions = ions_html.at("tr[9]/td[8]").text.gsub(nbsp, " ").strip

      war.specific_resistance = other_html.at("tr[1]/td[2]").text.gsub(nbsp, " ").strip
    	war.conductivity = other_html.at("tr[2]/td[2]").text.gsub(nbsp, " ").strip
    	war.total_dissolved_solids = other_html.at("tr[3]/td[2]").text.gsub(nbsp, " ").strip
    	war.nacl_equivalent = other_html.at("tr[4]/td[2]").text.gsub(nbsp, " ").strip
    	war.observed_ph = other_html.at("tr[5]/td[2]").text.gsub(nbsp, " ").strip
    	sar_html = other_html.at("tr[6]/td[2]")
    	if !sar_html.nil?
    	  war.sar = sar_html.text.gsub(nbsp, " ").strip
    	end

      war.comments = doc.xpath("//p[#{s}]/preceding-sibling::text()[1]").text.gsub("Comments", "").gsub(nbsp, " ").strip

      puts war.inspect

      war.save!

      puts "HTML parsed."

    end

    w.html_parsed = true
    w.save!

  end # transaction

  end # end well loop

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
end

