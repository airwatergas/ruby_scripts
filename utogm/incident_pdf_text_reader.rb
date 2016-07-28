# UTAH Environmental Incidents Report Text Reader

# Include required classes and models:

require '../data_config'

require 'rubygems'
require 'active_record'
require 'pg'

# Include database table models:

mappings_directory = getMappings

require mappings_directory + 'utah_environmental_incidents'

# begin error trapping
begin

  start_time = Time.now

  # Establish a database connection
  ActiveRecord::Base.establish_connection( { adapter: 'postgresql', host: getDBHost, port: getDBPort, username: getDBUsername, database: getDBDatabase } )

#  (1..8875).each do |i|
#  (11340..12473).each do |i|
  (12474..12480).each do |i|

    text_file_name = "utah_incidents/utah_inr_#{i}.txt"

    puts "utah_inr_#{i}.txt"

    file_text = IO.read(text_file_name)

    doc_text = file_text.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
    doc_text = doc_text.encode!('UTF-8', 'UTF-16')

    puts doc_text

    r = UtahEnvironmentalIncidents.new

    r.id = i
    r.report_text = doc_text
    r.save!

  end

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
end
