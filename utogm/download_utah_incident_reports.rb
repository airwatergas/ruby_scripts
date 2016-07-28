#!/Users/troyburke/.rvm/rubies/ruby-2.1.2/bin/ruby

# UTAH Environmental Incident PDF Downloader

# Include required classes and models:

require 'pg'
require 'mechanize'


# begin error trapping
begin

  start_time = Time.now

  agent_aliases = [ 'Windows IE 7', 'Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla', 'Linux Mozilla', 'Linux Firefox' ]

  #(1..8875) start to 06/12/2013
  #(11340..) 06/13/2013 to current (12473 as of 12/27/2015)

  (12481..12500).each do |i|

    # use random browser

    agent_alias = agent_aliases[rand(0..6)]
    puts agent_alias
    agent = Mechanize.new { |agent| agent.user_agent_alias = agent_alias }

    document_url = "http://eqspillsps.deq.utah.gov/frmIncidentNotification_View.aspx?INR_Num=#{i}"

    puts document_url

    doc_file_name = "utah_inr_#{i}.pdf"

    puts doc_file_name

    agent.get(document_url).save "utah_incidents/#{doc_file_name}"
    
    puts "Document downloaded!"

    sleep 5

  end

  puts "Time Start: #{start_time}"
  puts "Time End: #{Time.now}"

  rescue Exception => e
    puts e.message
end
