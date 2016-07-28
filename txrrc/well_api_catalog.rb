#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# TEXAS Well API Cataloger

# while true; do ./well_api_catalog.rb & sleep $(( ( RANDOM % 10 )  + 5 )); done

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


# begin error trapping
begin

  start_time = Time.now

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  agent_proxies =  [ ['165.139.149.169',3128], ['165.2.139.51',80], ['199.189.80.13',8080], ['97.77.104.22',80],  ['168.213.3.106',80], ['205.189.170.150',80] ]
# slow ['54.186.105.158',80], ['173.73.19.153',80], ['52.89.226.152',80], 
# very slow ['192.240.46.126',80], ['54.191.214.172',8080], ['24.172.34.114',8181], 
# bad? , ['107.170.221.9',8080], ['50.56.218.144',3129]
  agent_proxy = agent_proxies[rand(0..5)]
  agent_aliases = [ 'Windows IE 7', 'Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla', 'Linux Mozilla', 'Linux Firefox' ]
  agent_alias = agent_aliases[rand(0..6)]

  if TxrrcApiSearches.where(in_use: true).count == 0 then

    # IN, PR, SH, TA
    TxrrcApiSearches.find_by_sql("SELECT * FROM txrrc_api_searches WHERE well_type_code = 'PR' AND search_completed IS FALSE LIMIT 1").each do |search|

    search.in_use = true
    search.save!

    begin

      agent = Mechanize.new { |agent| agent.user_agent_alias = agent_alias }
      agent.set_proxy agent_proxy[0], agent_proxy[1]
      puts "#{agent_proxy[0]}, #{agent_proxy[1]}"
      puts agent_alias

      well_type_code_value = search.well_type_code
      county_code_value = search.county_code
      puts "Well Type: #{well_type_code_value}"
      puts "County Code: #{county_code_value}"

      post_url = "http://webapps2.rrc.state.tx.us/EWA/wellboreQueryAction.do"

      search_results = agent.post(post_url, {
        "methodToCall" => "search",
        "searchArgs.fieldNumbersArg" => "",
        "searchArgs.operatorNumbersArg" => "",
        "searchArgs.leaseTypeArg" => "",
        "searchArgs.districtCodeArg" => "None Selected",
        "searchArgs.leaseNumberArg" => "",
        "searchArgs.wellTypeArg" => well_type_code_value,
        "searchArgs.countyCodeArg" => county_code_value,
        "searchArgs.drillingPermitArg" => "",
        "searchArgs.apiNoPrefixArg" => "",
        "searchArgs.apiNoSuffixArg" => "",
        "searchArgs.scheduleTypeArg" => "Y",
      })

      results_doc = Nokogiri.HTML(search_results.body)

      search.search_completed = false

      if !results_doc.at('//span[@id="messageArea"]/tr[2]/td').nil? then

        results_check = results_doc.at('//span[@id="messageArea"]/tr[2]/td').text

        if results_check.include? "No results found" then
          search.search_completed = true
          search.search_comments = 'no results found'
          search.in_use = false
          search.save!
          puts 'no results found'
        end

        if results_check.include? "exceeds the maximum records allowed" then
          search.search_completed = true
          search.search_comments = 'maximum records exceeded'
          search.in_use = false
          search.save!
          puts 'maximum records exceeded'
        end

      end

      if !search.search_completed then

        download_results = agent.post(post_url, {
          "searchArgs.orderByColumnName" => "",
          "searchArgs.countyCodeArgHndlr.inputValue" => county_code_value,
          "searchArgs.drillingPermitArgHndlr.inputValue" => "",
          "searchArgs.apiNoPrefixArgHndlr.inputValue" => "",
          "searchArgs.apiNoSuffixArgHndlr.inputValue" => "",
          "searchArgs.scheduleTypeArgHndlr.inputValue" => "Y",
          "searchArgs.wellTypeArgHndlr.inputValue" => well_type_code_value,
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
          if i > 7 then 
            w = TxrrcWells.new
            w.well_type_code = well_type_code_value
            w.county_fips_code = county_code_value
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

        search.search_completed = true
        search.search_comments = "well data saved"
        search.in_use = false
        search.save!
        puts 'well data saved'

      end

    rescue Mechanize::ResponseCodeError => e
      puts "ResponseCodeError: " + e.to_s
      search.in_use = false
      search.save!

    rescue Exception => e
      puts e.message
      search.in_use = false
      search.save!

    end # error trap block

    end # active record loop

  end # in use check

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
end
