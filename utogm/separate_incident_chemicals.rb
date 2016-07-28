# UTAH Environmental Incidents Chemical Name Separator

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'utah_environmental_incidents'
require mappings_directory + 'utah_environmental_incident_chemicals'

# begin error trapping
begin

  start_time = Time.now

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

  UtahEnvironmentalIncidents.find_by_sql("SELECT id, chemicals_reported FROM utah_environmental_incidents WHERE chemicals_reported IS NOT NULL AND id > 12473 ORDER BY id").each do |inr|

    puts "[#{inr.id}] - #{inr.chemicals_reported}"

    inr.chemicals_reported.split('~~').each do |c_name|

      c = UtahEnvironmentalIncidentChemicals.new
      c.utah_environmental_incident_id = inr.id
      c.chemical_name = c_name
      c.save!

    end

  end

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
end
