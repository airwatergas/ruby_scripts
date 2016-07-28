#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# COGCC Complaint Extra Details Scraper

# UNIX shell script to run scraper: while true; do ./complaint_details_extra.rb & sleep 5; done

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
require mappings_directory + 'cogcc_complaint_visits'
require mappings_directory + 'cogcc_complaint_responses'
require mappings_directory + 'cogcc_complaint_resolutions'


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

      has_notifications = false
      has_visits = false
      has_responses = false
      has_resolutions = false

      if !doc.at('td:contains("Other Notifications")').nil? then
        has_notifications = true
      end
      if !doc.at('td:contains("Other Notifications")').nil? then
        has_visits = true
      end
      if !doc.at('td:contains("Other Notifications")').nil? then
        has_responses = true
      end
      if !doc.at('td:contains("Other Notifications")').nil? then
        has_resolutions = true
      end

      if has_visits then 
        if has_notifications then 
          visits_table = doc.xpath('//table[8]')
        else
          visits_table = doc.xpath('//table[7]')
        end
      end

      if has_repsonses then 
        if has_visits and has_notifications then 
          reponses_table = doc.xpath('//table[9]')
        elsif (!has_visits and has_notifications) or (has_visits and !has_notifications)
          reponses_table = doc.xpath('//table[8]')
        else
          reponses_table = doc.xpath('//table[7]')
        end
      end

      if has_resolutions then 
        if has_repsonses and has_visits and has_notifications then 
          resolutions_table = doc.xpath('//table[10]')
        elsif (!has_responses and has_visits and has_notifications) or (has_responses and !has_visits and has_notifications) or (has_responses and has_visits and !has_notifications)
          resolutions_table = doc.xpath('//table[9]')
        elsif (!has_responses and !has_visits and has_notifications) or (!has_responses and has_visits and !has_notifications) or (has_responses and !has_visits and !has_notifications)
          resolutions_table = doc.xpath('//table[8]')
        else
          resolutions_table = doc.xpath('//table[7]')
        end
      end


      multiple_visits = false
      visits_table_length = visits_table.css('tr').length
      if visits_table_length > 7 then
        multiple_visits = true
      end

      if multiple_visits then
        visits_total = 0
        visits_table.css('tr').each do |vt_tr|
          if vt_tr.to_s == '<tr height="1"><td colspan="6"><hr></td></tr>' then
            visit_total += 1
          end
        end
      end

      cv = CogccComplaintVisits.new

      cv.cogcc_complaint_id = complaint.id

      visit_count = 1

      visits_table.css('tr').each_with_index do |v_tr,i|

        if !v_tr.at('th:contains("Issue:")').nil? then
          cv.issue = v_tr.xpath('td[1]').text.gsub(nbsp, " ").strip
          cv.assigned_to = v_tr.xpath('td[2]').text.gsub(nbsp, " ").strip
          cv.status = v_tr.xpath('td[3]').text.gsub(nbsp, " ").strip
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

        if !multiple_visits and i+1 == visits_table_length then
          cv.save!
          puts "Visit record saved"
        end

        if multiple_visits and v_tr.to_s == '<tr height="1"><td colspan="6"><hr></td></tr>' then
          cv.save!
          puts "Visit record saved"
          if visit_count < visit_total then
            cv = CogccComplaintVisits.new
            cv.cogcc_complaint_id = complaint.id
          end
          visit_count += 1
        end

      end

 
 
 
 

      complaint.details_scraped = true
      complaint.in_use = false
      complaint.save!
      puts "Complaint extra details saved!"

    end # end activerecord transaction block

    rescue Mechanize::ResponseCodeError => e
      puts "ResponseCodeError: " + e.to_s
      complaint.invalid_text = true
      complaint.save!
    end

  end # end complaint loop

   puts "Time Start: #{start_time}"
   puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end