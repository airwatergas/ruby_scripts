#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# TEXAS Well API Cataloger

# while true; do ./well_api_catalog_static.rb & sleep 30; done

# url=http://webapps2.rrc.state.tx.us/EWA/wellboreQueryAction.do

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require 'mechanize'
require 'nokogiri'
require 'csv'

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'txrrc_api_searches'
require mappings_directory + 'txrrc_wells'

agent_aliases = [ 'Windows IE 7', 'Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla', 'Linux Mozilla', 'Linux Firefox' ]

#well_type_codes = ['AB','BM','DW','GJ','GL','GT','GW','HI','LP','LU','NP','OB','OS','PF','PP','RT','SD','SM','TR','WS','ZZ']
well_type_codes = ['ZZ']
# none found => HI,LU,SD
county_code = "None Selected"


# begin error trapping
begin

  start_time = Time.now

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  well_type_codes.each do |well_type_code|
    
  begin

    puts "Well Type: #{well_type_code}"

    agent_alias = agent_aliases[rand(0..6)]
    agent = Mechanize.new { |agent| agent.user_agent_alias = agent_alias }
    puts agent_alias
    
    post_url = "http://webapps2.rrc.state.tx.us/EWA/wellboreQueryAction.do"

    search_results = agent.post(post_url, {
      "methodToCall" => "search",
      "searchArgs.fieldNumbersArg" => "",
      "searchArgs.operatorNumbersArg" => "",
      "searchArgs.leaseTypeArg" => "",
      "searchArgs.districtCodeArg" => "None Selected",
      "searchArgs.leaseNumberArg" => "",
      "searchArgs.wellTypeArg" => well_type_code,
      "searchArgs.countyCodeArg" => county_code,
      "searchArgs.drillingPermitArg" => "",
      "searchArgs.apiNoPrefixArg" => "",
      "searchArgs.apiNoSuffixArg" => "",
      "searchArgs.scheduleTypeArg" => "Y",
    })

    results_doc = Nokogiri.HTML(search_results.body)

    search_completed = false

    if !results_doc.at('//span[@id="messageArea"]/tr[2]/td').nil? then

      results_check = results_doc.at('//span[@id="messageArea"]/tr[2]/td').text

      if results_check.include? "No results found" then
        search_completed = true
      end

      if results_check.include? "exceeds the maximum records allowed" then
        search_completed = true
        puts 'maximum records exceeded'
      end

    end

    if !search_completed then

      download_results = agent.post(post_url, {
        "searchArgs.orderByColumnName" => "",
        "searchArgs.countyCodeArgHndlr.inputValue" => county_code,
        "searchArgs.drillingPermitArgHndlr.inputValue" => "",
        "searchArgs.apiNoPrefixArgHndlr.inputValue" => "",
        "searchArgs.apiNoSuffixArgHndlr.inputValue" => "",
        "searchArgs.scheduleTypeArgHndlr.inputValue" => "Y",
        "searchArgs.wellTypeArgHndlr.inputValue" => well_type_code,
        "searchArgs.orderByHndlr.inputValue" => "",
        "searchArgs.leaseTypeArgHndlr.inputValue" => "",
        "searchArgs.districtCodeArgHndlr.inputValue" => "None Selected",
        "searchArgs.leaseNumberArgHndlr.inputValue" => "",
        "searchArgs.fieldNumbersArgHndlr.inputValue" => "",
        "searchArgs.operatorNumbersArgHndlr.inputValue" => "",
        "methodToCall" => "generateWellboreCriteriaReportCsv",
      })

      file_download = download_results.body

      csv_file = CSV.new(file_download)

      csv_file.each_with_index do |row,i|
        if i > 6 then
          w = TxrrcWells.new
          w.well_type_code = well_type_code
#          w.county_fips_code = county_code
          w.api_number = row[0]
        	w.district = row[1]
        	w.lease_number = row[2]
        	w.lease_name = row[3]
        	w.well_number = row[4]
        	w.field_name = row[5]
        	w.operator_name = row[6]
        	w.county_name = row[7]
        	w.on_schedule = row[8]
        	w.api_depth = row[9]
      	  w.save!
        end
      end

      puts 'well data saved'

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
