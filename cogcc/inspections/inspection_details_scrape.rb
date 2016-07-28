#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# COGCC Inspection Details Scraper

# while true; do ./inspection_details_scrape.rb & sleep 5; done

# Include required classes and models:

require '../../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_inspections'
require mappings_directory + 'cogcc_inspection_details'

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

  CogccInspections.find_by_sql("SELECT * FROM cogcc_inspections WHERE details_scraped IS FALSE AND document_number < 600000000 ORDER BY inspection_date DESC LIMIT 1").each do |insp|

  begin

    puts ""
    puts ""
    puts ""

    page_url = "http://cogcc.state.co.us/cogis/FieldInspectionDetail.asp?doc_num=#{insp.document_number}"

    puts page_url
    puts ""

    page = agent.get(page_url)

    response = page.code.to_s

    doc = Nokogiri::HTML(page.body)

    puts doc
    puts ""

    ActiveRecord::Base.transaction do

      d = CogccInspectionDetails.new

      d.cogcc_inspection_id = insp.id

      if !doc.at('td:contains("API Number:")').nil? then
        d.api_number = doc.at('td:contains("API Number:")').text.split(":")[1].gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("Facility/Location ID:")').nil? then
        d.facility_location_id = doc.at('td:contains("Facility/Location ID:")').text.split(":")[1].gsub(nbsp, " ").strip
      end
      d.name = doc.at('td:contains("Name:")').text.split(":")[1].gsub(nbsp, " ").strip
      d.location = doc.at('td:contains("Location:")').text.split(":")[1].gsub(nbsp, " ").strip
      d.lat = doc.at('td:contains("Lat:")').text.split(":")[1].split("Long")[0].gsub(nbsp, " ").strip
      d.long = doc.at('td:contains("Long:")').text.split("Long:")[1].gsub(nbsp, " ").strip
      d.operator_number = doc.at('td:contains("Operator #:")').text.split(":")[1].gsub(nbsp, " ").strip
      d.operator_name = doc.at('td:contains("Operator Name:")').text.split(":")[1].gsub(nbsp, " ").strip
      d.inspection_date = doc.at('td:contains("Inspection Date:")').text.split(":")[1].gsub(nbsp, " ").strip
      d.inspector = doc.at('td:contains("Inspector:")').text.split(":")[1].gsub(nbsp, " ").strip
      d.inspection_was = doc.xpath("//font/font[1]/font[1]").text
      d.insp_type = doc.at('td:contains("Insp. Type:")').text.split(":")[1].gsub(nbsp, " ").strip
      d.insp_stat = doc.at('td:contains("Insp. Stat:")').text.split(":")[1].gsub(nbsp, " ").strip
      d.reclamation = doc.at('td:contains("Reclamation (Pass, Interim or Fail):")').text.split(":")[1].gsub(nbsp, " ").strip
      d.p_and_a = doc.at('td:contains("A (Pass/Fail):")').text.split(":")[1].gsub(nbsp, " ").strip
      d.brhd_pressure = doc.at('td:contains("Brhd. Pressure:")').text.split(":")[1].gsub(nbsp, " ").strip
      d.inj_pressure = doc.at('td:contains("Inj. Pressure:")').text.split(":")[1].gsub(nbsp, " ").strip
      d.t_c_ann_pressure = doc.at('td:contains("T-C Ann. Pressure:")').text.split(":")[1].gsub(nbsp, " ").strip
      d.uic_violation_type = doc.at('td:contains("UIC Violation Type:")').text.split(":")[1].gsub(nbsp, " ").strip
      d.violation = doc.at('td:contains("Violation:")').text.split(":")[1].gsub(nbsp, " ").strip
      d.noav_sent = doc.at('td:contains("NOAV Sent:")').text.split(":")[1].gsub(nbsp, " ").strip
      d.date_corrective_action_due = doc.at('td:contains("Date Corrective Action Due:")').text.split(":")[1].gsub(nbsp, " ").strip
      d.date_remedied = doc.at('td:contains("Date Remedied:")').text.split(":")[1].gsub(nbsp, " ").strip

      if !doc.at('td:contains("Pit Type:")').nil? then
        d.pit_type = doc.at('td:contains("Pit Type:")').text.split(":")[1].gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("Oil on Pit:")').nil? then
        d.oil_on_pit = doc.at('td:contains("Oil on Pit:")').text.split(":")[1].gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("Freeboard:")').nil? then
        d.freeboard = doc.at('td:contains("Freeboard:")').text.split(":")[1].gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("Number of Pits:")').nil? then
        d.num_pits = doc.at('td:contains("Number of Pits:")').text.split(":")[1].gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("Number covered or lined:")').nil? then
        d.num_covered_lined = doc.at('td:contains("Number covered or lined:")').text.split(":")[1].gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("Number uncovered or unlined:")').nil? then
        d.num_uncovered_unlined = doc.at('td:contains("Number uncovered or unlined:")').text.split(":")[1].gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("Comments:")').nil? then
        pit_comments_text = doc.at('td:contains("Comments:")').text
        pit_text = pit_comments_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        pit_text = pit_text.encode!('UTF-8', 'UTF-16')
        d.pit_comments = pit_text.split(":")[1].gsub(nbsp, " ").strip
      end

      if !doc.at('td:contains("ACTION                        ")').nil? then
        action_text = doc.at('td:contains("ACTION                        ")').next_element.text
        act_text = action_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        act_text = act_text.encode!('UTF-8', 'UTF-16')
        d.action = act_text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("FENCECOMMENT                  ")').nil? then
        fencecomment_text = doc.at('td:contains("FENCECOMMENT                  ")').next_element.text
        fence_text = fencecomment_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        fence_text = fence_text.encode!('UTF-8', 'UTF-16')
        d.fencecomment = fence_text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("FIREWALL                      ")').nil? then
        firewall_text = doc.at('td:contains("FIREWALL                      ")').next_element.text
        fw_text = firewall_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        fw_text = fw_text.encode!('UTF-8', 'UTF-16')
        d.firewall = fw_text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("GENHOUSE                      ")').nil? then
        genhouse_text = doc.at('td:contains("GENHOUSE                      ")').next_element.text
        gh_text = genhouse_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        gh_text = gh_text.encode!('UTF-8', 'UTF-16')
        d.genhouse = gh_text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("HISTORICAL                    ")').nil? then
        historical_text = doc.at('td:contains("HISTORICAL                    ")').next_element.text
        hist_text = historical_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        hist_text = hist_text.encode!('UTF-8', 'UTF-16')
        d.historical = hist_text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("MISC                          ")').nil? then
        miscellaneous_text = doc.at('td:contains("MISC                          ")').next_element.text
        misc_text = miscellaneous_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        misc_text = misc_text.encode!('UTF-8', 'UTF-16')
        d.misc = misc_text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("SPILCOM                       ")').nil? then
        spilcom_text = doc.at('td:contains("SPILCOM                       ")').next_element.text
        sp_text = spilcom_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        sp_text = sp_text.encode!('UTF-8', 'UTF-16')
        d.spilcom = sp_text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("SURFRH                        ")').nil? then
        surfrh_text = doc.at('td:contains("SURFRH                        ")').next_element.text
        sh_text = surfrh_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        sh_text = sh_text.encode!('UTF-8', 'UTF-16')
        d.surfrh = sh_text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("TANKBAT                       ")').nil? then
        tankbat_text = doc.at('td:contains("TANKBAT                       ")').next_element.text
        tb_text = tankbat_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        tb_text = tb_text.encode!('UTF-8', 'UTF-16')
        d.tankbat = tb_text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("UICCOM                        ")').nil? then
        uiccom_text = doc.at('td:contains("UICCOM                        ")').next_element.text
        uc_text = uiccom_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        uc_text = uc_text.encode!('UTF-8', 'UTF-16')
        d.uiccom = uc_text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("WELLSIGN                      ")').nil? then
        wellsign_text = doc.at('td:contains("WELLSIGN                      ")').next_element.text
        ws_text = wellsign_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        ws_text = ws_text.encode!('UTF-8', 'UTF-16')
        d.wellsign = ws_text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("WORKOV                        ")').nil? then
        workov_text = doc.at('td:contains("WORKOV                        ")').next_element.text
        wo_text = workov_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        wo_text = wo_text.encode!('UTF-8', 'UTF-16')
        d.workov = wo_text.gsub(nbsp, " ").strip
      end

      d.related_facility_url = doc.at('table/tr/td/font[1]/a[1]')['href'].to_s
      if !doc.at('table/tr/td/font[1]/a[3]').nil? then
        d.related_docs_url = doc.at('table/tr/td/font[1]/a[3]')['href'].to_s
      else
        d.related_docs_url = doc.at('table/tr/td/font[1]/a[2]')['href'].to_s
      end

      puts d.inspect
      d.save!

      insp.details_scraped = true
      insp.save!

    end

    rescue Mechanize::ResponseCodeError => e
      puts "ResponseCodeError: " + e.to_s
    end

  end 

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end