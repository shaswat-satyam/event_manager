require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone(num)
    num = num.to_s.tr('( )-','')
    if num.length == 11 && num[0] == '1'
        num[1..11]
    elsif num.length == 10
        num
    else 
        puts "Bad Number"
    end
end

def best_time(time)
    hour = []
    time.each{|time| 
      hour.append(DateTime.strptime(time, "%m/%d/%y %H:%M").hour)

    }
    count = Hash.new(0)
    p hour
    hour.each {|hr| count[hr] += 1}
    count.sort_by { |hr,number| number}.last[0]
end

def best_day(time)
  day = []
  time.each{|time| 
    day.append(DateTime.strptime(time, "%m/%d/%y %H:%M").wday)
  }
  count = Hash.new(0)
    day.each {|day| count[day] += 1}
    Date::DAYNAMES[count.sort_by { |day,number| number}.last[0]]

end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

arr = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone = row[:homephone]
  time = row[:regdate]
  arr.append(time)
#   zipcode = clean_zipcode(row[:zipcode])
#   legislators = legislators_by_zipcode(zipcode)

#   form_letter = erb_template.result(binding)

#   save_thank_you_letter(id,form_letter)
end
 p best_day(arr)