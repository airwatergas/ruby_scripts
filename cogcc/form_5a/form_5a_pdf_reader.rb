# COGCC Form 5A PDF Text Reader

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require 'pdf-reader'
require 'open-uri'

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_document_names'
require mappings_directory + 'cogcc_form5a_documents'


# begin error trapping
begin

  start_time = Time.now

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  if CogccDocumentNames.where(in_use: true).count == 0 then

    CogccDocumentNames.find_by_sql("SELECT * FROM cogcc_document_names WHERE form_5a_imported IS FALSE AND form_5a_downloaded = 'PDF downloaded'").each do |doc|

    begin

      ActiveRecord::Base.transaction do

        doc.in_use = true
        doc.save!

        pdf_file_name = "form_5a_resaved/#{doc.well_api_number}_#{doc.document_id}.pdf"

        reader = PDF::Reader.new(pdf_file_name)

        file_text = ""
        reader.pages.each do |page|
          this_page = page.text + "\r\n"
          file_text.concat(this_page)
        end

        puts file_text

        form_5a = CogccForm5aDocuments.new
        form_5a.cogcc_document_id = doc.id
        form_5a.well_id = doc.well_id
        form_5a.well_api_number = doc.well_api_number
        form_5a.document_id = doc.document_id
        form_5a.document_number = doc.document_number
        form_5a.pdf_text = file_text
        form_5a.save

        doc.form_5a_imported = true
        doc.in_use = false
        doc.save!

      end # transaction

      rescue Exception => e
        puts e.message
      end

    end # query loop

  end # in use check

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end
