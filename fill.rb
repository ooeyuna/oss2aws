require 'json'

task = ARGV[0]
TASK = task

INFO_LOG = File.open("log/#{task}_output.log", 'w')
ERROR_LOG = File.open("log/#{task}_err_log.log", 'w')
FILL_DONE_LIST = File.open("result/#{task}_fill_done.json", 'a')
SKIP_LIST = File.open("result/#{task}_skip_list.json", 'a')
ERROR_LIST = File.open("result/#{task}_error_list.json", 'a')

COMPLETE_ROOMS = File.read("result/#{task}_fill_done.json")

def check(uuid) # success, need_upload, result
  zip_stat_cmd = "oss stat oss://white-cn-doc-convert/test/#{uuid}.zip"
  result = `#{zip_stat_cmd}`
  status = $?.exitstatus
  return true, false, "check room: #{uuid} success, skip" if status == 0
  return true, true, "check room: #{uuid} success, need upload" if status == 1 and result.include?("ErrorCode=NoSuchKey")
  return true, true, "check room: #{uuid} Error, #{result}" if status != 0 and status != 1
end

def fill(uuid) # success, result
  zip_stat_cmd = "oss cp empty.zip oss://white-cn-doc-convert/test/#{uuid}.zip"
  result = `#{zip_stat_cmd}`
  status = $?.exitstatus
  return true, "fill room: #{uuid} success, skip" if status == 0
  return true, "fill room: #{uuid} Error, #{result}" if status != 0
end


def write_error(uuid, result)
  ERROR_LOG.puts(result)
  ERROR_LIST.write("#{uuid},")
  ERROR_LIST.flush
  write_log(result)
end

def write_log(result)
  INFO_LOG.puts(result)
  p result
end

p COMPLETE_ROOMS

File.open("fill_tasks/#{task}.json") do |file|
  data = JSON.load(file).each do |uuid|
    write_log("skip room: #{uuid}") and next if COMPLETE_ROOMS.include?(uuid)
    
    # download
    success, need_upload, result = check(uuid)
    write_error(uuid, result) and next if not success

    if need_upload
      success, result = fill(uuid)
      write_error(uuid, result) and next if not success

      FILL_DONE_LIST.write("#{uuid},")
      FILL_DONE_LIST.flush
      write_log(result)
      next
    else
      SKIP_LIST.write("#{uuid},")
      SKIP_LIST.flush
      result = "skip room: #{uuid} zip exist"
      write_log(result)
      next
    end

  end
end