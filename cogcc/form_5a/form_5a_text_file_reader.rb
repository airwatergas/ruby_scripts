# COGCC Form 5A Text File Reader

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_form5a_documents'

# begin error trapping
begin

  start_time = Time.now

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  CogccForm5aDocuments.find_by_sql("SELECT * FROM cogcc_form5a_documents WHERE text_imported IS FALSE").each do |r|

  begin

    text_file_name = "form_5a_text/#{r.well_api_number}_#{r.document_id}.txt"

    puts "#{r.well_api_number}_#{r.document_id}.txt"

    file_text = IO.read(text_file_name)

    doc_text = file_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
    doc_text = doc_text.encode!('UTF-8', 'UTF-16')

    puts doc_text

    r.report_text = doc_text
    r.text_imported = true
    r.save!

    rescue Exception => e
      puts e.message
    end

  end

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end
