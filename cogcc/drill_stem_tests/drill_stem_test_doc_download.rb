#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# COGCC Drill Stem Test Report Downloader

# DOWNLOAD LINK => http://ogccweblink.state.co.us/DownloadDocument.aspx?DocumentId=_document_id_

# UNIX shell script to run scraper: while true; do ./drill_stem_test_doc_download.rb & sleep 10; done

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_drill_stem_tests'

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

  if CogccDrillStemTests.where(in_use: true).count == 0 then

  CogccDrillStemTests.find_by_sql("SELECT * FROM cogcc_drill_stem_tests WHERE in_use IS FALSE AND doc_downloaded IS FALSE LIMIT 1").each do |doc|

    doc.in_use = true
    doc.save!

    download_link = "http://ogccweblink.state.co.us/DownloadDocument.aspx?DocumentId=#{doc.document_id}"

    puts download_link

    dst = agent.get(download_link)

    file_extension = dst.filename.split('.').last

    if file_extension[0..2] != 'asp' then
      file_name = "drill_stem_tests/#{file_extension}/#{doc.well_api_number}_#{doc.document_number}__#{doc.document_id}___#{doc.document_date}.#{file_extension}"
    else
      file_name = "drill_stem_tests/#{doc.well_api_number}_#{doc.document_number}__#{doc.document_id}___#{doc.document_date}.#{file_extension}"
    end

    puts file_name

    dst.save file_name

    doc.in_use = false
    doc.doc_downloaded = true
    doc.save!

    puts "Document downloaded!"

  end

  end # in use check

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end