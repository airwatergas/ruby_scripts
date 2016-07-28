#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# COGCC Well Scout Card Scraper

# sample URL: cogcc.state.co.us/cogis/FacilityDetail.asp?facid=12335263&type=WELL

# UNIX shell script to run scraper: while true; do ./well_scout_card_scrape.rb & sleep 10; done

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

  CogccWellScoutCardScrapes.find_by_sql("SELECT * FROM cogcc_well_scout_card_scrapes WHERE in_use IS FALSE AND html_saved IS FALSE AND well_facility_id NOT IN ('00109801','00109803','00109804','00109802','00507191','00507222','00507189','00507219','00507221','00507192','00507220','00507194','00906675','01106194','01106199','01707773','01707774','01707752','02906109','03306155','04306219','04306226','04306225','04516947','04512084','04512121','04512255','04522488','04513105','04513284','04520514','04520515','04520521','04520516','04520513','04522155','04522157','04520517','04520518','04513286','04513297','05106125','05706524','05706509','06706777','06708988','07306603','07306594','07306421','07306475','07306583','07306628','07306629','07306486','07306567','07306615','07306642','07306634','07306569','07306621','07306638','07306563','07509417','07710095','07710079','08107720','08107774','08107769','08107683','08107770','08107771','08107773','08107804','08107763','08107760','08107811','08107761','08107742','08107762','08105709','08107624','08107749','08107754','08107641','08306662','08306663','08708173','08708174','08708171','08708170','10311886','10311887','10311954','10706263','10706260','10706258','10706246','11306271','12111037','12111042','12334405','12324340','12324341','12325739','12326467','12326505','12326705','12326841','12329061','12329060','12329088','12330086','12330090','12330168','12331632','12332151','12333855','12335751','12335803','12335864','12335890','12335889','12336108','12337701','12336121','12336388','12336420','12336587','12336726','12336881','12336973','12337044','12338011','12337985','12337986','12338010','12338019','12338020','12338021','12338022','12338023','12338307','12338619','12338620','12338618','12338780','12338781','12338777','12338778','12338779','12338782','12338813','12338814','12338815','12338879','12338880','12338881','12338882','12338883','12338884','12338885','12339390','12339462','12338812','12339392','12338878','12339393','12338893','12338925','12338926','12338927','12338928','12338892','12339024','12339518','12339519','12339520','12339517','12339701','12339863','12340089','12331573','12334144','12337912','12338776','12326704') LIMIT 1").each do |well|
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

        # check if completion data is confidential
#        not_confidential = true
#        if doc.at('th:contains("Completion data is confidential")').nil? then
#          not_confidential = false
#        end

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

#            if not_confidential then

              # completed casings loop
              begin_comp_case_comment = bore_html.at("//comment()[contains(.,'LOOP FOR EACH Casing')]")
              end_comp_case_comment = "<!-- END Casing LOOP -->"
              comp_case_html = Nokogiri::XML::NodeSet.new(bore_html)
              comp_case_node = begin_comp_case_comment.next_sibling
              loop do
                break if comp_case_node.to_s == end_comp_case_comment
                comp_case_html << comp_case_node
                comp_case_node = comp_case_node.next_sibling
              end
              comp_case_html = "<table>" + comp_case_html.to_html + "</table>"
              comp_case_html = Nokogiri::HTML(comp_case_html)
              if !comp_case_html.nil? then
                num_rows = comp_case_html.css('tr').size
                (1..num_rows).step(2) do |row|
                  cc = CogccWellCompletedCasings.new
                  cc.well_id = well.well_id
                  cc.cogcc_well_scout_card_id = sc.id
                  cc.cogcc_well_sidetrack_id = st.id
                  cc.casing_description = comp_case_html.xpath("//tr[#{row}]/td[2]").text.gsub(nbsp, " ").strip
                  cc.cement_description = comp_case_html.xpath("//tr[#{row+1}]/td[2]").text.gsub(nbsp, " ").strip
                  puts cc.inspect
                  cc.save!
                end
              end

              # additional cement completions
              begin_add_cem_comment = bore_html.at("//comment()[contains(.,'Begin Cement LOOP')]")
              end_add_cem_comment = "<!-- END Cement LOOP -->"
              add_cem_html = Nokogiri::XML::NodeSet.new(bore_html)
              add_cem_node = begin_add_cem_comment.next_sibling
              loop do
                break if add_cem_node.to_s == end_add_cem_comment
                add_cem_html << add_cem_node
                add_cem_node = add_cem_node.next_sibling
              end
              add_cem_html = "<table>" + add_cem_html.to_html + "</table>"
              add_cem_html = Nokogiri::HTML(add_cem_html)
              if !add_cem_html.nil? then
                num_rows = add_cem_html.css('tr').size
                (1..num_rows).step do |row|
                  cc = CogccWellCompletedCasings.new
                  cc.well_id = well.well_id
                  cc.cogcc_well_scout_card_id = sc.id
                  cc.cogcc_well_sidetrack_id = st.id
                  cc.casing_description = add_cem_html.xpath("//tr[#{row}]/td[2]").text.gsub(nbsp, " ").strip
                  cc.is_additional = true
                  puts cc.inspect
                  cc.save!
                end
              end

              # completed formations loop
              begin_comp_form_comment = bore_html.at("//comment()[contains(.,'LOOP FOR EACH Formation WITHIN WELLBORE')]")
              end_comp_form_comment = "<!-- END Formation LOOP -->"
              comp_form_html = Nokogiri::XML::NodeSet.new(bore_html)
              comp_form_node = begin_comp_form_comment.next_sibling
              loop do
                break if comp_form_node.to_s == end_comp_form_comment
                comp_form_html << comp_form_node
                comp_form_node = comp_form_node.next_sibling
              end
              comp_form_html = "<table>" + comp_form_html.to_html + "</table>"
              comp_form_html = Nokogiri::HTML(comp_form_html)
              if !comp_form_html.nil? then
                num_rows = comp_form_html.css('tr').size
                (1..num_rows).step do |row|
                  cf = CogccWellCompletedFormations.new
                  cf.well_id = well.well_id
                  cf.cogcc_well_scout_card_id = sc.id
                  cf.cogcc_well_sidetrack_id = st.id
                  cf.formation_name = comp_form_html.xpath("//tr[#{row}]/td[1]").text.gsub(nbsp, " ").strip
                  cf.log_top = comp_form_html.xpath("//tr[#{row}]/td[2]").text.gsub(nbsp, " ").strip
                  cf.log_bottom = comp_form_html.xpath("//tr[#{row}]/td[3]").text.gsub(nbsp, " ").strip
                  cf.cored = comp_form_html.xpath("//tr[#{row}]/td[4]").text.gsub(nbsp, " ").strip
                  cf.dst = comp_form_html.xpath("//tr[#{row}]/td[5]").text.gsub(nbsp, " ").strip
                  puts cf.inspect
                  cf.save!
                end
              end

              if bore_html.at('td:contains("No additional interval records were found for sidetrack")').nil? then

                # completed interval nodes/comments
                begin_interval_loop_node = bore_html.at("//comment()[contains(.,'REPEAT FOR EACH COMPLETED INTERVAL')]")
                end_interval_comment = "<!-- MOVE TO NEXT FORMATION AND LOOP -->"
                end_interval_loop_comment = "<!-- END OF FORMATION INFORMATION -->"

                num_intervals = bore_html.xpath("//comment()[contains(.,'MOVE TO NEXT FORMATION AND LOOP')]").size

                intervals = Array.new
                interval_num = 0
                intervals[interval_num] = Nokogiri::XML::NodeSet.new(bore_html)
                interval_contained_node = begin_interval_loop_node.next_sibling

                loop do
                  break if interval_contained_node.to_s == end_interval_loop_comment
                  intervals[interval_num] << interval_contained_node
                  interval_contained_node = interval_contained_node.next_sibling
                  if interval_contained_node.to_s == end_interval_comment then
                    # completed interval html captured in array intervals[interval_num]
                    interval_node = intervals[interval_num]
                    interval_html = Nokogiri::HTML(interval_node.to_html)
                    # record completed interval details
                    ci = CogccWellCompletedIntervals.new
                    ci.well_id = well.well_id
                    ci.cogcc_well_scout_card_id = sc.id
                    ci.cogcc_well_sidetrack_id = st.id
                    if !interval_html.at('td:contains("Completed information for formation")').nil? then
                      interval_heading_left = interval_html.at('td:contains("Completed information for formation")').text.split("Status")[0]
                  	  ci.formation_code = interval_heading_left.split("Completed information for formation ")[1].gsub(nbsp, " ").strip
                  	  interval_heading_right = interval_html.at('td:contains("Completed information for formation")').text.split("Status:")[1].gsub(nbsp, " ").strip
                  	  ci.status_code = interval_heading_right[0..1]
                  	end
                  	if !interval_html.at('td:contains("1st Production Date:")').nil? then
                  	  ci.first_production_date = interval_html.at('td:contains("1st Production Date:")').next_element.text.gsub(nbsp, " ").strip
                  	end
                  	if !interval_html.at('td:contains("Choke Size:")').nil? then
                      ci.choke_size = interval_html.at('td:contains("Choke Size:")').next_element.text.gsub(nbsp, " ").strip
                    end
                    if !interval_html.at('td:contains("Status Date:")').nil? then
                      ci.status_date = interval_html.at('td:contains("Status Date:")').next_element.text.gsub(nbsp, " ").strip
                    end
                  	if !interval_html.at('td:contains("Open Hole Completion:")').nil? then
                      ci.open_hole_completion = interval_html.at('td:contains("Open Hole Completion:")').next_element.text.gsub(nbsp, " ").strip
                    end
                  	if !interval_html.at('td:contains("Commingled:")').nil? then
                      ci.commingled = interval_html.at('td:contains("Commingled:")').next_element.text.gsub(nbsp, " ").strip
                    end
                  	if !interval_html.at('td:contains("Production Method:")').nil? then
                      ci.production_method = interval_html.at('td:contains("Production Method:")').next_element.text.gsub(nbsp, " ").strip
                    end
                  	if !interval_html.at('td:contains("Formation Name:")').nil? then
                      ci.formation_name = interval_html.at('td:contains("Formation Name:")').next_element.text.gsub(nbsp, " ").strip
                    end
                  	if !interval_html.at('td:contains("Tubing Size:")').nil? then
                      ci.tubing_size = interval_html.at('td:contains("Tubing Size:")').next_element.text.gsub(nbsp, " ").strip
                    end
                	  if !interval_html.at('td:contains("Tubing Setting Depth:")').nil? then
                      ci.tubing_setting_depth = interval_html.at('td:contains("Tubing Setting Depth:")').next_element.text.gsub(nbsp, " ").strip
                    end
              	    if !interval_html.at('td:contains("Tubing Packer Depth:")').nil? then
                      ci.tubing_packer_depth = interval_html.at('td:contains("Tubing Packer Depth:")').next_element.text.gsub(nbsp, " ").strip
                    end
            	      if !interval_html.at('td:contains("Tubing Multiple Packer:")').nil? then
                      ci.tubing_multiple_packer = interval_html.at('td:contains("Tubing Multiple Packer:")').next_element.text.gsub(nbsp, " ").strip
                    end
          	        if !interval_html.at('td:contains("Open Hole Top:")').nil? then
                      ci.open_hole_top = interval_html.at('td:contains("Open Hole Top:")').next_element.text.gsub(nbsp, " ").strip
                    end
        	          if !interval_html.at('td:contains("Open Hole Bottom:")').nil? then
                      ci.open_hole_bottom = interval_html.at('td:contains("Open Hole Bottom:")').next_element.text.gsub(nbsp, " ").strip
                    end
      	            if !interval_html.at('td:contains("Test Date:")').nil? then
                      ci.test_date = interval_html.at('td:contains("Test Date:")').next_element.text.gsub(nbsp, " ").strip
                    end
    	              if !interval_html.at('td:contains("Test Method:")').nil? then
                      ci.test_method = interval_html.at('td:contains("Test Method:")').next_element.text.gsub(nbsp, " ").strip
                    end
                    if !interval_html.at('td:contains("Hours Tested:")').nil? then
                      ci.hours_tested = interval_html.at('td:contains("Hours Tested:")').next_element.text.gsub(nbsp, " ").strip
                    end
                    if !interval_html.at('td:contains("Gas Type:")').nil? then
                      ci.test_gas_type = interval_html.at('td:contains("Gas Type:")').next_element.text.gsub(nbsp, " ").strip
                    end
                    if !interval_html.at('td:contains("Gas Disposal:")').nil? then
                      ci.gas_disposal = interval_html.at('td:contains("Gas Disposal:")').next_element.text.gsub(nbsp, " ").strip
                    end
                    if !interval_html.at('td:contains("BBLS_H2O")').nil? then
                      ci.bbls_h20 = interval_html.at('td:contains("BBLS_H2O")').next_element.text.gsub(nbsp, " ").strip
                    end
                    if !interval_html.at('td:contains("BBLS_OIL")').nil? then
                      ci.bbls_oil = interval_html.at('td:contains("BBLS_OIL")').next_element.text.gsub(nbsp, " ").strip
                    end
              	    if !interval_html.at('td:contains("BTU_GAS")').nil? then
                      ci.btu_gas = interval_html.at('td:contains("BTU_GAS")').next_element.text.gsub(nbsp, " ").strip
                    end
            	      if !interval_html.at('td:contains("CALC_BBLS_H2O")').nil? then
                      ci.calc_bbls_h20 = interval_html.at('td:contains("CALC_BBLS_H2O")').next_element.text.gsub(nbsp, " ").strip
                    end
          	        if !interval_html.at('td:contains("CALC_BBLS_OIL")').nil? then
                      ci.calc_bbls_oil = interval_html.at('td:contains("CALC_BBLS_OIL")').next_element.text.gsub(nbsp, " ").strip
                    end
        	          if !interval_html.at('td:contains("CALC_GOR")').nil? then
                      ci.calc_gor = interval_html.at('td:contains("CALC_GOR")').next_element.text.gsub(nbsp, " ").strip
                    end
      	            if !interval_html.at('td:contains("CALC_MCF_GAS")').nil? then
                      ci.calc_mcf_gas = interval_html.at('td:contains("CALC_MCF_GAS")').next_element.text.gsub(nbsp, " ").strip
                    end
    	              if !interval_html.at('td:contains("CASING_PRESS")').nil? then
                      ci.casing_press = interval_html.at('td:contains("CASING_PRESS")').next_element.text.gsub(nbsp, " ").strip
                    end
                  	if !interval_html.at('td:contains("GRAVITY_OIL")').nil? then
                      ci.gravity_oil = interval_html.at('td:contains("GRAVITY_OIL")').next_element.text.gsub(nbsp, " ").strip
                    end
                  	if !interval_html.at('td:contains("MCF_GAS")').nil? then
                      ci.mcf_gas = interval_html.at('td:contains("MCF_GAS")').next_element.text.gsub(nbsp, " ").strip
                    end
                  	if !interval_html.at('td:contains("TUBING_PRESS")').nil? then
                      ci.tubing_press = interval_html.at('td:contains("TUBING_PRESS")').next_element.text.gsub(nbsp, " ").strip
                    end
                  	if !interval_html.at('td:contains("Interval Bottom:")').nil? then
                      ci.perf_bottom = interval_html.at('td:contains("Interval Bottom:")').next_element.text.gsub(nbsp, " ").strip
                    end
                  	if !interval_html.at('td:contains("Interval Top:")').nil? then
                      ci.perf_top = interval_html.at('td:contains("Interval Top:")').next_element.text.gsub(nbsp, " ").strip
                    end
                  	if !interval_html.at('td:contains("# of Holes:")').nil? then
                      ci.perf_holes_number = interval_html.at('td:contains("# of Holes:")').next_element.text.gsub(nbsp, " ").strip
                    end
                  	if !interval_html.at('td:contains("Hole Size:")').nil? then
                      ci.perf_hole_size = interval_html.at('td:contains("Hole Size:")').next_element.text.gsub(nbsp, " ").strip
                    end

                    puts ci.inspect
                    ci.save!

                    if !interval_html.at('td:contains("Formation Treatment")').nil? then

                      # formation treatments loop
                      begin_treat_loop_node = interval_html.at("//comment()[contains(.,'INITIAL TREAT LOOP')]")
                      end_treat_comment = "<!-- MOVE TO NEXT TREATMENT AND LOOP -->"
                      end_treat_loop_comment = "<!-- END INITIAL TREAT LOOP -->"

                      num_treats = interval_html.xpath("//comment()[contains(.,'MOVE TO NEXT TREATMENT AND LOOP')]").size

                      treats = Array.new
                      treat_num = 0
                      treats[treat_num] = Nokogiri::XML::NodeSet.new(interval_html)
                      treat_contained_node = begin_treat_loop_node.next_sibling

                      loop do
                        break if treat_contained_node.to_s == end_treat_loop_comment
                        treats[treat_num] << treat_contained_node
                        treat_contained_node = treat_contained_node.next_sibling
                        if treat_contained_node.to_s == end_treat_comment then
                          # completed treat html captured in array treats[treat_num]
                          treat_node = treats[treat_num]
                          treat_html = Nokogiri::HTML(treat_node.to_html)
                          # record completed treat details
                          ft = CogccWellFormationTreatments.new
                          ft.well_id = well.well_id
                          ft.cogcc_well_scout_card_id = sc.id
                          ft.cogcc_well_sidetrack_id = st.id
                          ft.cogcc_well_completed_interval_id = ci.id

                        	if !treat_html.at('td:contains("Treatment Type:")').nil? then
                            ft.treatment_type = treat_html.at('td:contains("Treatment Type:")').next_element.text.gsub(nbsp, " ").strip
                          end
                      	  if !treat_html.at('td:contains("Treatment Date:")').nil? then
                            ft.treatment_date = treat_html.at('td:contains("Treatment Date:")').next_element.text.gsub(nbsp, " ").strip
                          end
                    	    if !treat_html.at('td:contains("Treatment End Date:")').nil? then
                            ft.treatment_end_date = treat_html.at('td:contains("Treatment End Date:")').next_element.text.gsub(nbsp, " ").strip
                          end
                  	      if !treat_html.at('td:contains("Treatment summary:")').nil? then
                            ft.treatment_summary = treat_html.at('td:contains("Treatment summary:")').text.split("Treatment summary:")[1].gsub(nbsp, " ").strip
                          end
                	        if !treat_html.at('td:contains("Total fluid used in treatment (bbls):")').nil? then
                            ft.total_fluid_used = treat_html.at('td:contains("Total fluid used in treatment (bbls):")').next_element.text.gsub(nbsp, " ").strip
                          end
              	          if !treat_html.at('td:contains("Max pressure during treatment (psi):")').nil? then
                            ft.max_pressure = treat_html.at('td:contains("Max pressure during treatment (psi):")').next_element.text.gsub(nbsp, " ").strip
                          end
            	            if !treat_html.at('td:contains("Total gas used in treatment (mcf):")').nil? then
                            ft.total_gas_used = treat_html.at('td:contains("Total gas used in treatment (mcf):")').next_element.text.gsub(nbsp, " ").strip
                          end
                          if !treat_html.at('td:contains("Fluid density (lbs/gal):")').nil? then
                            ft.fluid_density = treat_html.at('td:contains("Fluid density (lbs/gal):")').next_element.text.gsub(nbsp, " ").strip
                          end
                        	if !treat_html.at('td:contains("Type of gas:")').nil? then
                            ft.gas_type = treat_html.at('td:contains("Type of gas:")').next_element.text.gsub(nbsp, " ").strip
                          end
                      	  if !treat_html.at('td:contains("Number of staged intervals:")').nil? then
                            ft.staged_intervals = treat_html.at('td:contains("Number of staged intervals:")').next_element.text.gsub(nbsp, " ").strip
                          end
                    	    if !treat_html.at('td:contains("Total acid used in treatment (bbls):")').nil? then
                            ft.total_acid_used = treat_html.at('td:contains("Total acid used in treatment (bbls):")').next_element.text.gsub(nbsp, " ").strip
                          end
                  	      if !treat_html.at('td:contains("Max frac gradient (psi/ft):")').nil? then
                            ft.max_frac_gradient = treat_html.at('td:contains("Max frac gradient (psi/ft):")').next_element.text.gsub(nbsp, " ").strip
                          end
                	        if !treat_html.at('td:contains("Recycled water used in treatment (bbls):")').nil? then
                            ft.recycled_water_used = treat_html.at('td:contains("Recycled water used in treatment (bbls):")').next_element.text.gsub(nbsp, " ").strip
                          end
              	          if !treat_html.at('td:contains("Total flowback volume recovered (bbls):")').nil? then
                            ft.total_flowback_recovered = treat_html.at('td:contains("Total flowback volume recovered (bbls):")').next_element.text.gsub(nbsp, " ").strip
                          end
            	            if !treat_html.at('td:contains("Produced water used in treatment (bbls):")').nil? then
                            ft.produced_water_used = treat_html.at('td:contains("Produced water used in treatment (bbls):")').next_element.text.gsub(nbsp, " ").strip
                          end
          	              if !treat_html.at('td:contains("Disposition method for flowback:")').nil? then
                            ft.flowback_disposition = treat_html.at('td:contains("Disposition method for flowback:")').next_element.text.gsub(nbsp, " ").strip
                          end
                          if !treat_html.at('td:contains("Total proppant used (lbs):")').nil? then
                            ft.total_proppant_used = treat_html.at('td:contains("Total proppant used (lbs):")').next_element.text.gsub(nbsp, " ").strip
                          end
                          if !treat_html.at('td:contains("Green completions techniques utilized:")').nil? then
                            ft.green_completions = treat_html.at('td:contains("Green completions techniques utilized:")').next_element.text.gsub(nbsp, " ").strip
                          end
                          if !treat_html.at('td:contains("Reason green techniques not utilized:")').nil? then
                            ft.no_green_reasons = treat_html.at('td:contains("Reason green techniques not utilized:")').text.split("Reason green techniques not utilized:")[1].gsub(nbsp, " ").strip
                          end

                          puts ft.inspect
                          ft.save!

                          # increment treat number and instantiate treat html block
                          treat_num += 1
                          treats[treat_num] = Nokogiri::XML::NodeSet.new(interval_html)

                        end
                      end

                    end

                    # increment interval number and instantiate interval html block
                    interval_num += 1
                    intervals[interval_num] = Nokogiri::XML::NodeSet.new(bore_html)

                  end
                end

              end

#            end # confidential info check

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


















