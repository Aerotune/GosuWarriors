def write_error_log e  
  log_folder = %w[. logs crash_logs]
  filename = Time.now.strftime('%y-%m-%d_%H_%M_%S') + '.txt'
  
  FileUtils.mkpath(File.join(*log_folder))
  
  File.open(File.join(*log_folder, filename), 'w') do |f|
    f << "#{e.class}: #{e}"
    f << "\n\t#{e.backtrace.join("\n\t")}"
  end
end

begin
  require 'rubygems'
  require 'gosu'
  require 'msgpack'
  require 'pathname'
  require 'fileutils'
  require_relative 'constants'

  dev_constants_path = File.join(MAIN_PATH, 'constants', 'dev_constants.rb')
  developer_mode_available = File.exists?(dev_constants_path)
  enable_developer_mode = true

  DEVELOPER_MODE = enable_developer_mode && developer_mode_available

  if DEVELOPER_MODE
    require 'v8'
    require dev_constants_path
  end

  require_relative 'window'
  Window.new.show
  
rescue Exception => e
  write_error_log e
  raise e
  
ensure
  begin
    Resources::Sprites.save_all!
  rescue
    write_error_log e
    raise e
  end
end