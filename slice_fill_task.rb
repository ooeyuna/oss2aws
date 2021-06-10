require 'json'

file = File.open "/home/siyu/Downloads/akasuo-taskmanager-static-uuid.json"

data = JSON.load(file)

p data.length

data.each_slice(10000).with_index do | slice, index |
  File.open("fill_tasks/#{index}.json", 'w') { |file| file.write(JSON.dump(slice)) }
  
end