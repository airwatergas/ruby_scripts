# COGCC Form 5A PDF Text Parser (used for second batch of downloaded PDFs)

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'
require 'pdf-reader'

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_form5a_documents'


# begin error trapping
begin

  start_time = Time.now

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  CogccForm5aDocuments.find_by_sql("SELECT * FROM cogcc_form5a_documents WHERE parsed IS FALSE").each do |doc|

  begin

    pdf_file_name = "form_5a_resaved/#{doc.well_api_number}_#{doc.document_id}.pdf"

    puts pdf_file_name

    reader = PDF::Reader.new(pdf_file_name)

    file_text = ""

    reader.pages.each do |page|
      this_page = page.text + "\r\n"
      file_text.concat(this_page)
    end

    puts file_text

    doc.pdf_text = file_text
    doc.parsed = true
    doc.save!

    rescue Exception => e
      puts e.message
    end

  end # query loop

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
  end
#end
