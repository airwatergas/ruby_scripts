#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# COGCC Well Scout Card Scraper

# sample URL: cogcc.state.co.us/cogis/FacilityDetail.asp?facid=00507220&type=WELL

# UNIX shell script to run scraper: while true; do ./well_scout_card_confidential.rb & sleep 10; done

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"
require "nokogiri"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_well_scout_card_scrapes'
require mappings_directory + 'cogcc_well_scout_cards'
require mappings_directory + 'cogcc_well_sidetracks'
require mappings_directory + 'cogcc_well_objective_formations'
require mappings_directory + 'cogcc_well_planned_casings'
require mappings_directory + 'cogcc_well_completed_casings'
require mappings_directory + 'cogcc_well_completed_formations'
require mappings_directory + 'cogcc_well_completed_intervals'
require mappings_directory + 'cogcc_well_formation_treatments'

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

  if CogccWellScoutCardScrapes.where(in_use: true).count == 0 then

  CogccWellScoutCardScrapes.find_by_sql("SELECT * FROM cogcc_well_scout_card_scrapes WHERE completion_data_confidential IS TRUE AND in_use IS FALSE AND html_saved IS FALSE LIMIT 1").each do |well|
  begin

    puts "#{well.well_facility_id} in use!"

    well.in_use = true
    well.save!

    ActiveRecord::Base.transaction do

      page_url = "http://cogcc.state.co.us/cogis/FacilityDetail.asp?facid=#{well.well_facility_id}&type=WELL"

      page = agent.get(page_url)

      response = page.code.to_s

      doc = Nokogiri::HTML(page.body)

      # check if well scout card exists
      if doc.at('h3:contains("could not be found.")').nil? then

        sc = CogccWellScoutCards.new

        sc.well_id = well.well_id

        # details not contained in GIS download
        if !doc.at('td:contains("Status Date:")').nil? then
      	  sc.status_date = doc.at('td:contains("Status Date:")').next_element.text.gsub(nbsp, " ").strip
      	end
      	if !doc.at('td:contains("Federal or State Lease #:")').nil? then
      	  sc.lease_number = doc.at('td:contains("Federal or State Lease #:")').next_element.text.gsub(nbsp, " ").strip
      	end

        # Frac Focus details
      	frac_focus_links = doc.xpath("//a[contains(@href, 'DisclosureSearch')]")
        if frac_focus_links.length > 0 then
          sc.has_frac_focus_report = true
          if !doc.at('td:contains("Job Date:")').nil? then
            job_start = doc.at('td:contains("Job Date:")').text.split("Job End Date:")[0].gsub(nbsp, " ").strip
            sc.job_start_date = job_start.split(":")[1].gsub(nbsp, " ").strip
            sc.job_end_date = doc.at('td:contains("Job End Date:")').text.split("Job End Date:")[1].gsub(nbsp, " ").strip
          end
          if !doc.at('td:contains("Reported:")').nil? then
        	  sc.reported_date = doc.at('td:contains("Reported:")').text.split(":")[1].gsub(nbsp, " ").strip
        	end
        	if !doc.at('td:contains("Days to report:")').nil? then
        	  sc.days_to_report =  doc.at('td:contains("Days to report:")').text.split(":")[1].gsub(nbsp, " ").strip
        	end
        end

        # save extra basic details
        puts sc.inspect
        sc.save!

        # sidetrack nodes/comments
        begin_wellbore_loop_node = doc.at("//comment()[contains(.,'BEGIN WELLBORE LOOP')]")
        end_sidetrack_comment = "<!-- MOVE TO NEXT SIDETRACK AND LOOP -->"
        end_wellbore_loop_comment = "<!-- END REPEAT FOR EACH WELLBORE -->"

        num_sidetracks = doc.xpath("//comment()[contains(.,'MOVE TO NEXT SIDETRACK AND LOOP')]").size

        sidetracks = Array.new
        track_num = 0
        sidetracks[track_num] = Nokogiri::XML::NodeSet.new(doc)
        contained_node = begin_wellbore_loop_node.next_sibling

        # sidetrack loop
        loop do

          break if contained_node.to_s == end_wellbore_loop_comment
          sidetracks[track_num] << contained_node
          contained_node = contained_node.next_sibling

          # track num switch condition
          if contained_node.to_s == end_sidetrack_comment then

            # sidetrack html captured in array sidetracks[track_num]
            bore_node = sidetracks[track_num]
            bore_html = Nokogiri::HTML(bore_node.to_html)
            # record sidetrack details
            st = CogccWellSidetracks.new
            st.well_id = well.well_id
            st.cogcc_well_scout_card_id = sc.id
            if !bore_html.at('td:contains("Wellbore Data for Sidetrack")').nil? then
          	  st.sidetrack_number = "0#{track_num}"
          	  sidetrack_heading = bore_html.at('td:contains("Wellbore Data for Sidetrack")').text.split("Status:")[1]
      	      st.status_code = sidetrack_heading.gsub(nbsp, " ").strip # use sql to split status code/date
        	    st.status_date = sidetrack_heading.gsub(nbsp, " ").strip # use sql to split status code/date
          	end
          	if !bore_html.at('td:contains("Spud Date:")').nil? then
          	  st.spud_date = bore_html.at('td:contains("Spud Date:")').next_element.text.gsub(nbsp, " ").strip
          	end
          	if !bore_html.at('td:contains("Spud Date is:")').nil? then
          	  st.spud_date_type = bore_html.at('td:contains("Spud Date is:")').next_element.text.gsub(nbsp, " ").strip
          	end
          	if !bore_html.at('td:contains("Wellbore Permit")').nil? then
          	  st.wellbore_permit = bore_html.at('td:contains("Wellbore Permit")').next_element.next_element.text.gsub(nbsp, " ").strip
          	end
          	if !bore_html.at('td:contains("Permit #:")').nil? then
          	  st.permit_number = bore_html.at('td:contains("Permit #:")').next_element.text.gsub(nbsp, " ").strip
          	end
          	if !bore_html.at('td:contains("Expiration Date:")').nil? then
          	  st.permit_expiration_date = bore_html.at('td:contains("Expiration Date:")').next_element.text.gsub(nbsp, " ").strip
          	end
          	if !bore_html.at('td:contains("Prop Depth/Form:")').nil? then
          	  st.prop_depth_form = bore_html.at('td:contains("Prop Depth/Form:")').next_element.text.gsub(nbsp, " ").strip
          	end
          	if !bore_html.at('td:contains("Surface Mineral Owner Same:")').nil? then
          	  st.surface_mineral_owner_same = bore_html.at('td:contains("Surface Mineral Owner Same:")').next_element.text.gsub(nbsp, " ").strip
          	end
          	if !bore_html.at('td:contains("Mineral Owner:")').nil? then
          	  st.mineral_owner = bore_html.at('td:contains("Mineral Owner:")').next_element.text.gsub(nbsp, " ").strip
          	end
          	if !bore_html.at('td:contains("Surface Owner:")').nil? then
          	  st.surface_owner = bore_html.at('td:contains("Surface Owner:")').next_element.text.gsub(nbsp, " ").strip
          	end
          	if !bore_html.at('td:contains("Unit:")').nil? then
          	  st.unit = bore_html.at('td:contains("Unit:")').next_element.text.gsub(nbsp, " ").strip
          	end
          	if !bore_html.at('td:contains("Unit Number:")').nil? then
          	  st.unit_number = bore_html.at('td:contains("Unit Number:")').next_element.text.gsub(nbsp, " ").strip
          	end
          	if !bore_html.at('td:contains("Completion Date:")').nil? then
          	  st.completion_date = bore_html.at('td:contains("Completion Date:")').next_element.text.gsub(nbsp, " ").strip
          	end
          	if !bore_html.at('td:contains("Measured TD:")').nil? then
          	  st.measured_td = bore_html.at('td:contains("Measured TD:")').next_element.text.gsub(nbsp, " ").strip
          	end
          	if !bore_html.at('td:contains("Measured PB depth:")').nil? then
          	  st.measured_pb_depth = bore_html.at('td:contains("Measured PB depth:")').next_element.text.gsub(nbsp, " ").strip
          	end
          	if !bore_html.at('td:contains("True Vertical TD:")').nil? then
          	  st.true_vertical_td = bore_html.at('td:contains("True Vertical TD:")').next_element.text.gsub(nbsp, " ").strip
          	end
          	if !bore_html.at('td:contains("True Vertical PB depth:")').nil? then
          	  st.true_vertical_pb_depth = bore_html.at('td:contains("True Vertical PB depth:")').next_element.text.gsub(nbsp, " ").strip
          	end
            if !bore_html.at('td:contains("Top PZ Location:")').nil? then
              st.top_pz_location = bore_html.at('td:contains("")').text.split("")[1].gsub(nbsp, " ").strip
            end
            if !bore_html.at('td:contains("Footage:")').nil? then
          	  st.footage = bore_html.at('td:contains("Footage:")').text.split("Footage:")[1].gsub(nbsp, " ").strip
            end
            if !bore_html.at('td:contains("Bottom Hole Location:")').nil? then
          	  st.bottom_hole_location = bore_html.at('td:contains("Bottom Hole Location:")').text.split("Bottom Hole Location:")[1].gsub(nbsp, " ").strip
            end
            if !bore_html.at('td:contains("Footages:")').nil? then
          	  st.footages = bore_html.at('td:contains("Footages:")').text.split("Footages:")[1].gsub(nbsp, " ").strip
            end
            if !bore_html.at('td:contains("Log Types:")').nil? then
          	  st.log_types = bore_html.at('td:contains("Log Types:")').next_element.text.gsub(nbsp, " ").strip
            end

            # confidential end date
            if !bore_html.at('th:contains("Completion data is confidential")').nil? then
              st.completion_data_confidential = true
              confidential_text = bore_html.at('th:contains("Completion data is confidential")').text
              if confidential_text.include? "until" then
                st.confidential_end_date = confidential_text.split("until")[1].gsub(nbsp, " ").strip  
              end
            end

            puts st.inspect
            st.save!

            # objective formations loop
            begin_obj_form_comment = bore_html.at("//comment()[contains(.,'LOOP FOR EACH OBJ_FORMATION')]")
            end_obj_form_comment = "<!-- END Objective Formation LOOP -->"
            obj_form_html = Nokogiri::XML::NodeSet.new(bore_html)
            obj_form_node = begin_obj_form_comment.next_sibling
            loop do
              break if obj_form_node.to_s == end_obj_form_comment
              obj_form_html << obj_form_node
              obj_form_node = obj_form_node.next_sibling
            end
            obj_form_html = "<table>" + obj_form_html.to_html + "</table>"
            obj_form_html = Nokogiri::HTML(obj_form_html)
            if !obj_form_html.nil? then
              num_rows = obj_form_html.css('tr').size
              (1..num_rows).step do |row|
                of = CogccWellObjectiveFormations.new
                of.well_id = well.well_id
                of.cogcc_well_scout_card_id = sc.id
                of.cogcc_well_sidetrack_id = st.id
                of.description = obj_form_html.xpath("//tr[#{row}]/td[2]").text.gsub(nbsp, " ").strip
                puts of.inspect
                of.save!
              end
            end

            # planned casings loop
            begin_plan_case_comment = bore_html.at("//comment()[contains(.,'LOOP FOR EACH Planned Casing')]")
            end_plan_case_comment = "<!-- END Planned Casing LOOP -->"
            plan_case_html = Nokogiri::XML::NodeSet.new(bore_html)
            plan_case_node = begin_plan_case_comment.next_sibling
            loop do
              break if plan_case_node.to_s == end_plan_case_comment
              plan_case_html << plan_case_node
              plan_case_node = plan_case_node.next_sibling
            end
            plan_case_html = "<table>" + plan_case_html.to_html + "</table>"
            plan_case_html = Nokogiri::HTML(plan_case_html)
            if !plan_case_html.nil? then
              num_rows = plan_case_html.css('tr').size
              (1..num_rows).step(2) do |row|
                pc = CogccWellPlannedCasings.new
                pc.well_id = well.well_id
                pc.cogcc_well_scout_card_id = sc.id
                pc.cogcc_well_sidetrack_id = st.id
                pc.casing_description = plan_case_html.xpath("//tr[#{row}]/td[2]").text.gsub(nbsp, " ").strip
                pc.cement_description = plan_case_html.xpath("//tr[#{row+1}]/td[2]").text.gsub(nbsp, " ").strip
                puts pc.inspect
                pc.save!
              end
            end

            # increment sidetrack number and instantiate sidetrack html block
            track_num += 1
            sidetracks[track_num] = Nokogiri::XML::NodeSet.new(doc)

          end # end track num switch

        end # end sidetrack html builder do loop

        well.html_status = "data saved"

      else

        well.html_status = "data not found"

      end # end results check

      well.html_saved = true
      well.in_use = false
      well.save!

    end # activerecord transaction

    rescue Mechanize::ResponseCodeError => e
      well.html_saved = true
      well.in_use = false
      well.html_status = "data not found"
      well.save!
      puts "ResponseCodeError: " + e.to_s
    end

    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> WELL SCRAPE COMPLETED!"

  end # end well loop

  end # in use check

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"
  puts " "

  rescue Exception => e
    puts e.message
  end
#end
