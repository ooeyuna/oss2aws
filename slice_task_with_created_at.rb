require 'json'

file = File.open "/home/siyu/Downloads/akasuo-abacus-all-uuid-with-createAt.json"

data = JSON.load(file)

p data.length

data.each_slice(10000).with_index do | slice, index |
  File.open("fill_tasks/#{index + 21}.json", 'w') { |file| file.write(JSON.dump(slice.map{|data| data["uuid"]})) }
  
end 