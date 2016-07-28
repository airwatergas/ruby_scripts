#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# COGCC Complaint Details Scraper

# UNIX shell script to run scraper: while true; do ./complaint_details_scrape.rb & sleep 5; done

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_complaints'
require mappings_directory + 'cogcc_complaint_issues'
require mappings_directory + 'cogcc_complaint_notifications'


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

  CogccComplaints.find_by_sql("SELECT * FROM cogcc_complaints WHERE in_use IS FALSE AND details_scraped IS FALSE LIMIT 1").each do |complaint|
#  CogccComplaints.find_by_sql("SELECT * FROM cogcc_complaints WHERE document_number = 200418963").each do |complaint|

  begin

    puts "#{complaint.document_number} in use!"

    complaint.in_use = true
    complaint.save!

    ActiveRecord::Base.transaction do

      page_url = "http://cogcc.state.co.us/cogis/ComplaintReport.asp?doc_num=#{complaint.document_number}"

      page = agent.get(page_url)

      response = page.code.to_s

      doc = Nokogiri::HTML(page.body)

      issues_table = doc.xpath('//table[6]')

      multiple_issues = false
      issues_table_length = issues_table.css('tr').length
      if issues_table_length > 7 then
        multiple_issues = true
      end

      if multiple_issues then
        issue_total = 0
        issues_table.css('tr').each do |it_tr|
          if it_tr.to_s == '<tr height="1"><td colspan="6"><hr></td></tr>' then
            issue_total += 1
          end
        end
      end

      notifications_table = doc.xpath('//table[7]')

      notification_total = 0
      notifications_table.css('tr').each do |in_tr|
        if !in_tr.at('th:contains("Response or Details")').nil? then
          notification_total += 1
        end
      end

      ci = CogccComplaintIssues.new

      ci.cogcc_complaint_id = complaint.id

      issue_count = 1

      issues_table.css('tr').each_with_index do |i_tr,i|

        if !i_tr.at('th:contains("Issue:")').nil? then
          ci.issue = i_tr.xpath('td[1]').text.gsub(nbsp, " ").strip
          ci.assigned_to = i_tr.xpath('td[2]').text.gsub(nbsp, " ").strip
          ci.status = i_tr.xpath('td[3]').text.gsub(nbsp, " ").strip
        end
        
        if !i_tr.at('th:contains("Description:")').nil? then
          description_text = i_tr.xpath('td[1]').text
          desc_text = description_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
          desc_text = desc_text.encode!('UTF-8', 'UTF-16')
          ci.description = desc_text.gsub(nbsp, " ").strip
        end

        if !i_tr.at('th:contains("Resolution:")').nil? then
          resolution_text = i_tr.xpath('td[1]').text
          res_text = resolution_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
          res_text = res_text.encode!('UTF-8', 'UTF-16')
          ci.resolution = res_text.gsub(nbsp, " ").strip
        end

        if !i_tr.at('th:contains("Letter Sent?:")').nil? then
          ci.letter_sent = i_tr.xpath('td[1]').text.gsub(nbsp, " ").strip
          ci.report_links = i_tr.xpath('td[2]').text.gsub(nbsp, " ").strip
        end

        if !multiple_issues and i+1 == issues_table_length then
          ci.save!
          puts "issue record saved"
        end

        if multiple_issues and i_tr.to_s == '<tr height="1"><td colspan="6"><hr></td></tr>' then
          ci.save!
          puts "issue record saved"
          if issue_count < issue_total then
            ci = CogccComplaintIssues.new
            ci.cogcc_complaint_id = complaint.id
          end
          issue_count += 1
        end

      end

      cn = CogccComplaintNotifications.new

      notification_count = 1

      notifications_table.css('tr').each_with_index do |n_tr,n|

        if !n_tr.at('th:contains("Date:")').nil? then
          
          cn.cogcc_complaint_id = complaint.id
          cn.notification_date = n_tr.xpath('td[1]').text.gsub(nbsp, " ").strip
          cn.agency = n_tr.xpath('td[2]').text.gsub(nbsp, " ").strip
          cn.contact = n_tr.xpath('td[3]').text.gsub(nbsp, " ").strip
        end

        if !n_tr.at('th:contains("Response or Details")').nil? then
          response_detail_text = notifications_table.xpath("tr[#{n}+2]/td/font").text
          response_det = response_detail_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
          response_det = response_det.encode!('UTF-8', 'UTF-16')
          cn.response_details = response_det.gsub(nbsp, " ").strip
          cn.save!
          puts "saving notification"
          if notification_count < notification_total then
            cn = CogccComplaintNotifications.new
          end
          notification_count += 1
        end

      end

      # additional complaint details
      if !doc.at('td:contains("Complaint taken by:")').nil? then
        complaint.complaint_taken_by = doc.at('td:contains("Complaint taken by:")').next_element.text.gsub(nbsp, " ").strip
      end
    	if !doc.at('td:contains("API number:")').nil? then
        complaint.well_api_number = doc.at('td:contains("API number:")').next_element.text.gsub(nbsp, " ").strip
      end
    	if !doc.at('td:contains("Complaint Type:")').nil? then
        complaint.complaint_type = doc.at('td:contains("Complaint Type:")').next_element.text.gsub(nbsp, " ").strip
      end
    	if !doc.at('td:contains("Address:")').nil? then
        complaint.complainant_address = doc.at('td:contains("Address:")').next_element.text.gsub(nbsp, " ").strip
      end
    	if !doc.at('td:contains("Date Received:")').nil? then
        complaint.complaint_date = doc.at('td:contains("Date Received:")').next_element.text.gsub(nbsp, " ").strip
      end
    	if !doc.at('td:contains("Connection to Incident:")').nil? then
        complaint.complainant_connection = doc.at('td:contains("Connection to Incident:")').next_element.text.gsub(nbsp, " ").strip
      end
    	if !doc.at('td:contains("Well Name/No.")').nil? then
        complaint.well_name_no = doc.at('td:contains("Well Name/No.")').next_element.text.gsub(nbsp, " ").strip
      end
      if !doc.at('td:contains("County Name:")').nil? then
        complaint.county_name = doc.at('td:contains("County Name:")').next_element.text.gsub(nbsp, " ").strip
      end
    	if !doc.at('td:contains("Operator contact:")').nil? then
        complaint.operator_contact = doc.at('td:contains("Operator contact:")').next_element.text.gsub(nbsp, " ").strip
      end
      if !doc.at('td/table/tr/td:contains("qtrqtr:")').nil? then
        complaint.qtr_qtr = doc.at('td/table/tr/td:contains("qtrqtr:")').text.split("qtrqtr:")[1].gsub(nbsp, " ").strip
      end
      if !doc.at('td/table/tr/td:contains("section:")').nil? then
        complaint.section = doc.at('td/table/tr/td:contains("section:")').text.split("section:")[1].gsub(nbsp, " ").strip
      end
      if !doc.at('td/table/tr/td:contains("township:")').nil? then
        complaint.township = doc.at('td/table/tr/td:contains("township:")').text.split("township:")[1].gsub(nbsp, " ").strip
      end
      if !doc.at('td/table/tr/td:contains("range:")').nil? then
        complaint.range = doc.at('td/table/tr/td:contains("range:")').text.split("range:")[1].gsub(nbsp, " ").strip
      end
      if !doc.at('td/table/tr/td:contains("meridian:")').nil? then
        complaint.meridian = doc.at('td/table/tr/td:contains("meridian:")').text.split("meridian:")[1].gsub(nbsp, " ").strip
      end

      complaint.details_scraped = true
      complaint.in_use = false
      complaint.save!
      puts "Complaint details saved!"

    end # end activerecord transaction block

    rescue Mechanize::ResponseCodeError => e
      puts "ResponseCodeError: " + e.to_s
      complaint.invalid_text = true
      complaint.save
    end

  end # end complaint loop

   puts "Time Start: #{start_time}"
   puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end