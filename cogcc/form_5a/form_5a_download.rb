#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# COGCC Form 5A Completed Interval Report Downloader

# DOWNLOAD LINK => http://ogccweblink.state.co.us/DownloadDocument.aspx?DocumentId=_document_id_

# UNIX shell script to run scraper: while true; do ./form_5a_download.rb & sleep 10; done

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require "mechanize"

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_document_names'

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

  if CogccDocumentNames.where(in_use: true).count == 0 then

    CogccDocumentNames.find_by_sql("SELECT id, document_id, well_api_number FROM cogcc_document_names WHERE form_5a_downloaded = 'not downloaded' AND well_api_county IN ('045','123') AND document_date > '8/15/2010' AND (document_name ILIKE '%completed interval report%' OR document_name ILIKE '%5A%') LIMIT 1").each do |doc|

      puts "#{doc.well_api_number}_#{doc.document_id}"

      ActiveRecord::Base.transaction do

        doc.in_use = true
        doc.save!

        download_link = "http://ogccweblink.state.co.us/DownloadDocument.aspx?DocumentId=#{doc.document_id}"
        puts download_link

        form_5a = agent.get(download_link)

        file_extension = form_5a.filename.split('.').last

        if file_extension == "pdf"

          file_name = "form_5a/pdf/#{doc.well_api_number}_#{doc.document_id}.pdf"
          puts file_name

          form_5a.save file_name

          doc.form_5a_downloaded = "PDF downloaded"
          puts "PDF document downloaded!"

        else 

          doc.form_5a_downloaded = "TIFF image"
          puts "TIFF image skipped."

        end

        doc.in_use = false
        doc.save!
        puts " "

      end # transaction
      
    end # query loop

  end # in use check

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end