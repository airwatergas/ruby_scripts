#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# COGCC Remediation Details

# while true; do ./remediation_details_scrape.rb & sleep 5; done

# URL:
# http://cogcc.state.co.us/cogis/RemediationReport.asp?doc_num=1983114


# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_remediations'
require mappings_directory + 'cogcc_remediation_details'
require mappings_directory + 'cogcc_remediation_medias'


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

  CogccRemediations.find_by_sql("SELECT * FROM cogcc_remediations WHERE in_use IS FALSE AND details_scraped IS FALSE LIMIT 1").each do |remediation|

  begin

    remediation.in_use = true
    remediation.save!

    puts "Remediation #{remediation.document_number} in use."
    
    page_url = "http://cogcc.state.co.us/cogis/#{remediation.document_url}"

    page = agent.get(page_url)

    response = page.code.to_s

    doc = Nokogiri::HTML(page.body)

    ActiveRecord::Base.transaction do

      impacted_media = doc.xpath('//table[5]')
      impacted_media_table_length = impacted_media.css('tr').length
      max_row_num = impacted_media_table_length - 1

      if impacted_media_table_length > 3 then 
        (3..max_row_num).step do |r|
          im = CogccRemediationMedias.new
          im.cogcc_remediation_id = remediation.id
          if !impacted_media.xpath("tr[#{r}]/td[1]").nil? then
            im.media = impacted_media.xpath("tr[#{r}]/td[1]").text.gsub(nbsp," ").strip
          end
          if !impacted_media.xpath("tr[#{r}]/td[3]").nil? then
            im.impacted = impacted_media.xpath("tr[#{r}]/td[3]").text.gsub(nbsp," ").strip
          end
          if !impacted_media.xpath("tr[#{r}]/td[5]").nil? then
            im.extent = impacted_media.xpath("tr[#{r}]/td[5]").text.gsub(nbsp," ").strip
          end
          if !impacted_media.xpath("tr[#{r}]/td[7]").nil? then
            im.how_determined = impacted_media.xpath("tr[#{r}]/td[7]").text.gsub(nbsp," ").strip
          end
          im.save!
        end
      end

      d = CogccRemediationDetails.new
      d.cogcc_remediation_id = remediation.id

      if !doc.at('td:contains("Reason for Report:")').nil? then
        cell_contents = doc.at('td:contains("Reason for Report:")').text
        if !cell_contents.split("Reason for Report:")[1].nil? then
          reason_report_content = cell_contents.split("Reason for Report:")[1]
          if !reason_report_content.split("Cause of Condition:")[0].nil? then
            d.report_reason = reason_report_content.split("Cause of Condition:")[0].gsub(nbsp, " ").strip
          end
        end
      end
      if !doc.at('td:contains("Cause of Condition:")').nil? then
        cell_contents = doc.at('td:contains("Cause of Condition:")').text
        if !cell_contents.split("Cause of Condition:")[1].nil? then
          condition_cause_content = cell_contents.split("Cause of Condition:")[1]
          if !condition_cause_content.split("Potential Receptors:")[0].nil? then
            d.condition_cause = condition_cause_content.split("Potential Receptors:")[0].gsub(nbsp, " ").strip
          end
        end
      end
      if !doc.at('td:contains("Potential Receptors:")').nil? then
        cell_contents = doc.at('td:contains("Potential Receptors:")').text
        if !cell_contents.split("Potential Receptors:")[1].nil? then
          d.potential_receptors = cell_contents.split("Potential Receptors:")[1].gsub(nbsp, " ").strip
        end
      end

      if !doc.at('td:contains("INITIAL ACTION:")').nil? then
        initial_action_text = doc.at('td:contains("INITIAL ACTION:")').next_element.text
        init_action_text = initial_action_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        init_action_text = init_action_text.encode!('UTF-8', 'UTF-16')
        d.initial_action = init_action_text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("SOURCE REMOVED:")').nil? then
        source_removed_text = doc.at('td:contains("SOURCE REMOVED:")').next_element.text
        src_removed_text = source_removed_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        src_removed_text = src_removed_text.encode!('UTF-8', 'UTF-16')
        d.source_removed = src_removed_text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("HOW REMEDIATE:")').nil? then
        how_remediate_text = doc.at('td:contains("HOW REMEDIATE:")').next_element.text
        how_rem_text = how_remediate_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        how_rem_text = how_rem_text.encode!('UTF-8', 'UTF-16')
        d.how_remediate = how_rem_text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("MONITORING PLAN:")').nil? then
        monitoring_plan_text = doc.at('td:contains("MONITORING PLAN:")').next_element.text
        mon_plan_text = monitoring_plan_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        mon_plan_text = mon_plan_text.encode!('UTF-8', 'UTF-16')
        d.monitoring_plan = mon_plan_text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("5-RECLAMATION PLAN:")').nil? then
        reclamation_plan_text = doc.at('td:contains("5-RECLAMATION PLAN:")').next_element.text
        rec_plan_text = reclamation_plan_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        rec_plan_text = rec_plan_text.encode!('UTF-8', 'UTF-16')
        d.reclamation_plan = rec_plan_text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("Conditions of Approval:")').nil? then
        approval_conditions_text = doc.at('td:contains("Conditions of Approval:")').text.split("Conditions of Approval:")[1]
        app_cond_text = approval_conditions_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        app_cond_text = app_cond_text.encode!('UTF-8', 'UTF-16')
        d.approval_conditions = app_cond_text.gsub(nbsp, " ").strip
      end

      d.save!

      if !doc.at('td:contains("Date Rec")').nil? then
        remediation.received_date = doc.at('td:contains("Date Rec")').next_element.text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("Document Type:")').nil? then
        remediation.document_type = doc.at('td:contains("Document Type:")').next_element.text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("Assigned by:")').nil? then
        remediation.assigned_by = doc.at('td:contains("Assigned by:")').next_element.text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("API number:")').nil? then
        remediation.api_number = doc.at('td:contains("API number:")').next_element.text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("Address:")').nil? then
        remediation.operator_address = doc.at('td:contains("Address:")').next_element.text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("Fac. Name")').nil? then
        remediation.facility_name = doc.at('td:contains("Fac. Name")').next_element.text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("County Name:")').nil? then
        remediation.county_name = doc.at('td:contains("County Name:")').next_element.text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("Operator contact:")').nil? then
        remediation.operator_contact = doc.at('td:contains("Operator contact:")').next_element.text.gsub(nbsp, " ").strip
      end

      if !doc.at('td/table/tr/td:contains("qtrqtr:")').nil? then
        remediation.qtr_qtr = doc.at('td/table/tr/td:contains("qtrqtr:")').text.split("qtrqtr:")[1].gsub(nbsp, " ").strip
      end
      if !doc.at('td/table/tr/td:contains("section:")').nil? then
        remediation.section = doc.at('td/table/tr/td:contains("section:")').text.split("section:")[1].gsub(nbsp, " ").strip
      end
      if !doc.at('td/table/tr/td:contains("township:")').nil? then
        remediation.township = doc.at('td/table/tr/td:contains("township:")').text.split("township:")[1].gsub(nbsp, " ").strip
      end
      if !doc.at('td/table/tr/td:contains("range:")').nil? then
        remediation.range = doc.at('td/table/tr/td:contains("range:")').text.split("range:")[1].gsub(nbsp, " ").strip
      end
      if !doc.at('td/table/tr/td:contains("meridian:")').nil? then
        remediation.meridian = doc.at('td/table/tr/td:contains("meridian:")').text.split("meridian:")[1].gsub(nbsp, " ").strip
      end

      remediation.related_documents_url = doc.at('table/tr/td/font[2]/a[2]')['href'].to_s
      remediation.details_scraped = true
      remediation.in_use = false
      remediation.save!
      puts "Remediation details saved!"

    end # end activerecord transaction block

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