require 'json'

task = ARGV[0]
TASK = task

INFO_LOG = File.open("log/#{task}_output.log", 'w')
DOWNLOAD_DONE_LIST = File.open("#{task}_download_done.json", 'w')
ERROR_LOG = File.open("log/#{task}_err_log.log", 'w')

def download(uuid)
  dir_count_cmd = "oss cp -rf oss://white-cn-doc-convert/dynamicConvert/#{uuid} data/#{TASK}/#{uuid}"
  zip_count_cmd = "oss cp -f oss://white-cn-doc-convert/dynamicConvert/#{uuid}.zip data/#{TASK}/#{uuid}.zip"
  dir_result = `#{dir_count_cmd}`
  if dir_result.include?("Error")
    return false, "download room dir: #{uuid} Error"
  end
  zip_result = `#{zip_count_cmd}`
  if zip_result.include?("Error") and not zip_result.include?("StatusCode=404")
    return false, "download room zip: #{uuid} Error"
  end
  result = "download room: #{uuid} complete"
  return true, result
end

def upload
  dir_sync = "aws s3 sync data/#{TASK}/ s3://white-cn-doc-convert/test/#{uuid}/"

  dir_result = `#{dir_sync}`
  if $?.exitstatus != 0
    return false, "upload room dir: #{uuid} Error"
  end

  zip_result = `#{zip_sync}`

  if $?.exitstatus != 0 and not $?.exitstatus == 255
    return false, "upload room zip: #{uuid} Error"
  end
  result = "upload room: #{uuid} complete"
  return true, result
end

def write_error(result)
  ERROR_LOG.puts(result)
end

def write_log(result)
  INFO_LOG.puts(result)
end

File.open("tasks/#{task}") do |file|
  data = JSON.load(file).each do |uuid|
    # download
    success, result = download(uuid)
    if not success
      write_error(result)
    else
      DOWNLOAD_DONE_LIST.write(uuid + ",")
    end
    write_log(result)
    p result
  end
end

File.open("tasks/#{task}") do |file|
  data = JSON.load(file).each do |uuid|
    # upload
    success, result = upload(uuid)
    if not success
      write_error(result)
    else
      UPLOAD_DONE_LIST.write(uuid + ",")
    end
    write_log(result)
    p result
  end
end
