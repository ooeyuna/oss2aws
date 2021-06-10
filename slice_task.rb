require 'json'

file = File.open "/home/siyu/Downloads/akasuo-taskmanager-static-uuid.json"

data = JSON.load(file)

p data.length

data.each_slice(3000).with_index do | slice, index |
  File.open("tasks/#{index + 13}.json", 'w') { |file| file.write(JSON.dump(slice.map{|data| data["uuid"]})) }
  
end