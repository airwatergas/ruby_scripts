#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# UTAH Spill Report PDF Downloader

# http://eqspillsps.deq.utah.gov/frmIncidentNotification_View.aspx?INR_Num=129


# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require 'mechanize'
require 'nokogiri'


# begin error trapping
begin

  start_time = Time.now

  agent_aliases = [ 'Windows IE 7', 'Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla', 'Linux Mozilla', 'Linux Firefox' ]
  agent_alias = agent_aliases[rand(0..6)]
  puts agent_alias
  agent = Mechanize.new { |agent| agent.user_agent_alias = agent_alias }

  search_url = "http://eqspillsps.deq.utah.gov/Search_Public.aspx"
  search_page = agent.get(search_url)
  search_doc = Nokogiri::HTML(search_page.body)

  search_results_page = agent.post(search_url, {
    "__EVENTTARGET" => "",
    "__EVENTARGUMENT" => "",
    "__LASTFOCUS" => "",
    "__VIEWSTATE" => search_doc.at('input[@name="__VIEWSTATE"]')['value'],
    "__VIEWSTATEGENERATOR" => search_doc.at('input[@name="__VIEWSTATEGENERATOR"]')['value'],
    "__SCROLLPOSITIONX" => search_doc.at('input[@name="__SCROLLPOSITIONX"]')['value'],
    "__SCROLLPOSITIONY" => search_doc.at('input[@name="__SCROLLPOSITIONY"]')['value'],
    "__VIEWSTATEENCRYPTED" => "",
    "__EVENTVALIDATION" => search_doc.at('input[@name="__EVENTVALIDATION"]')['value'],
    "ctl00$ContentPlaceHolder1$txtIncident_start_date" => "",
    "ctl00$ContentPlaceHolder1$Incident_start_date" => "rbIncident_start_date_equals",
    "ctl00$ContentPlaceHolder1$txtRes_party_Name" => "",
    "ctl00$ContentPlaceHolder1$ddlChemicalMaterialID" => "27",
    "ctl00$ContentPlaceHolder1$txtIncident_address" => "",
    "ctl00$ContentPlaceHolder1$ddlNear_town" => "- Please Select -",
    "ctl00$ContentPlaceHolder1$ddlNear_town_ListSearchExtender_ClientState" => "",
    "ctl00$ContentPlaceHolder1$ddlCounty" => "- Please Select -",
    "ctl00$ContentPlaceHolder1$ddlCounty_ListSearchExtender_ClientState" => "",
    "ctl00$ContentPlaceHolder1$txtSearchPhrase" => "",
    "ctl00$ContentPlaceHolder1$cmdSearch" => "Search",
  })
  search_results_doc = Nokogiri.HTML(search_results_page.body)

  # click Select All button
  select_search_results_page = agent.post(search_url, {
    "__EVENTTARGET" => "",
    "__EVENTARGUMENT" => "",
    "__LASTFOCUS" => "",
    "__VIEWSTATE" => search_results_doc.at('input[@name="__VIEWSTATE"]')['value'],
    "__VIEWSTATEGENERATOR" => search_results_doc.at('input[@name="__VIEWSTATEGENERATOR"]')['value'],
    "__SCROLLPOSITIONX" => search_results_doc.at('input[@name="__SCROLLPOSITIONX"]')['value'],
    "__SCROLLPOSITIONY" => search_results_doc.at('input[@name="__SCROLLPOSITIONY"]')['value'],
    "__VIEWSTATEENCRYPTED" => "",
    "__EVENTVALIDATION" => search_results_doc.at('input[@name="__EVENTVALIDATION"]')['value'],
    "ctl00$ContentPlaceHolder1$txtIncident_start_date" => "",
    "ctl00$ContentPlaceHolder1$Incident_start_date" => "rbIncident_start_date_equals",
    "ctl00$ContentPlaceHolder1$txtRes_party_Name" => "",
    "ctl00$ContentPlaceHolder1$ddlChemicalMaterialID" => "27",
    "ctl00$ContentPlaceHolder1$txtIncident_address" => "",
    "ctl00$ContentPlaceHolder1$ddlNear_town" => "- Please Select -",
    "ctl00$ContentPlaceHolder1$ddlNear_town_ListSearchExtender_ClientState" => "",
    "ctl00$ContentPlaceHolder1$ddlCounty" => "- Please Select -",
    "ctl00$ContentPlaceHolder1$ddlCounty_ListSearchExtender_ClientState" => "",
    "ctl00$ContentPlaceHolder1$txtSearchPhrase" => "",
    "ctl00$ContentPlaceHolder1$cmdSearch" => "Select All",
  })
  select_search_results_doc = Nokogiri.HTML(select_search_results_page.body)

  # click Save Selected button













    no_results_check = results_doc.xpath("//table['MainContent_GridView1']/tr/td").text.strip.gsub("  ", "").gsub("\r\n","")

    if no_results_check == 'Your search did not match any documents.' then

      well.frac_focus_status = 'no documents found'
      well.save
      puts 'no documents found'

    else

      results_table_row_count = results_doc.xpath("//table['MainContent_GridView1']/tr").size

      for i in 2..results_table_row_count

        file_count = i-1

        result_row = results_doc.xpath("//table['MainContent_GridView1']/tr[#{i}]")

        download_form = search_results.forms[0]
        download_form['__EVENTTARGET'] = "ctl00$MainContent$GridView1"
        download_form['__EVENTARGUMENT'] = "OpenFile$0"
        download_form['__VIEWSTATE'] = results_doc.at('input[@name="__VIEWSTATE"]')['value']
        download_form['__VIEWSTATEENCRYPTED'] = results_doc.at('input[@name="__VIEWSTATEENCRYPTED"]')['value']
        download_form['__EVENTVALIDATION'] = results_doc.at('input[@name="__EVENTVALIDATION"]')['value']
        response = download_form.submit

        download_file = "nm_pdfs/fracfocus_#{well.well_api_number}.pdf"

        File.open(download_file, 'wb'){|f| f << response.body}

      end

      well.frac_focus_status = 'documents downloaded'
      well.save
      puts 'documents downloaded'

    end

    rescue Mechanize::ResponseCodeError => e
      well.frac_focus_status = 'not found'
      well.save
      puts "ResponseCodeError: " + e.to_s
    end

  end

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end