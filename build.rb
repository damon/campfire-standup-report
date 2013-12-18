#!/usr/bin/env ruby

require 'tinder'
require 'active_support/core_ext'
require 'chronic'

# expects a participant's standup report starting with "Yesterday:" or "Friday:"

begin
 campfire = Tinder::Campfire.new 'yourdomain', :username => 'youruname', :password => 'yourpwd'
rescue
  raise "fix the script first to use your Campfire credentials"
end

room_name = ARGV[0]
raise "please pass in the exact room name - ./build.rb <roomname>" if room_name.blank?

puts "Name: "
name = $stdin.gets.chomp

raise "please supply a name" if name.blank?

puts "Start Date: "
date1 = $stdin.gets.chomp

puts "End Date: "
date2 = $stdin.gets.chomp

d1 = Chronic.parse(date1)
d2 = Chronic.parse(date2)

if !(d1&&d2) || (d1>d2)
  raise "please supply a valid date range"
end
d1,d2=d1.to_date,d2.to_date

class String 
  def starts_with?(str)
    str = str.to_str
    head = self[0, str.length]
    head == str
  end
end

def messages_for(messages, username)
  messages.reject {|m| !m.user.name.upcase.include?(username) rescue nil}.reject {|m| m.type!="TextMessage"}
end

room = campfire.find_room_by_name(room_name)

puts "Standup Report for #{name} from #{d1} to #{d2}"

$d = d1
while $d <= d2  do
   puts $d.to_s(:long)
   messages = room.transcript($d)
   messages_for(messages,name.upcase).select{|m| m.body.upcase.starts_with?("YESTERDAY:")||m.body.upcase.starts_with?("FRIDAY:") }.each do |m|
     puts m.body
   end
   $d +=1
end
