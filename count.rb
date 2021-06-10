require 'json'

def count(uuid)
  dir_count_cmd = "oss du oss://white-cn-doc-convert/dynamicConvert/#{uuid} | grep 'du size' | cut -f2 -d ':'"
  zip_count_cmd = "oss du oss://white-cn-doc-convert/dynamicConvert/#{uuid}.zip | grep 'du size' | cut -f2 -d ':'"
  dir_size = `#{dir_count_cmd}`.to_f / 1024.0 / 1024.0
  zip_size = `#{zip_count_cmd}`.to_f / 1024.0 / 1024.0
  total = dir_size + zip_size
  result = "room: #{uuid}, dir_size: #{dir_size}MB, zip_size: #{zip_size}MB, total: #{dir_size + zip_size}Mb"
  return result, total
end

list = Dir.children "/home/siyu/netless/oss2aws/tasks"
list.each do |task|
  File.open("tasks/#{task}") do |file|
    File.open("task_count/#{task}.log", 'w') do |wfile|
      totalcount = 0
      data = JSON.load(file).each do |uuid|
        result, total = count(uuid)
        p result
        wfile.puts result
        totalcount += total
      end
      p "#{task} totalcount: #{totalcount}"
      wfile.puts ""
      wfile.puts "total: #{totalcount}"
    end
  end
end