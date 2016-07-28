require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'cogcc_form5a_documents'
require mappings_directory + 'cogcc_form5a_formations'

# begin error trapping
begin

  start_time = Time.now

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  CogccForm5aDocuments.find_by_sql("select * from cogcc_form5a_documents where report_text_contains_fluid_amounts is true order by id").each do |doc|

  puts "Doc ID: #{doc.id}"

  begin

    ActiveRecord::Base.transaction do

      doc_text = doc.report_text

      formations = doc_text.split('FORMATION: ')

      if !formations.nil?

        formations.each_with_index do |f,i|

          if i > 0
            form_text = CogccForm5aFormations.new
            form_text.cogcc_form5a_document_id = doc.id
            form_text.well_id = doc.well_id
            form_text.formation_text = f
            form_text.save!
          end

        end

      end

    end # transaction

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
