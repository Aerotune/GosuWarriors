def write_error_log e  
  log_folder = %w[. logs crash_logs]
  filename = Time.now.strftime('%y-%m-%d_%H_%M_%S') + '.txt'
  
  FileUtils.mkpath(File.join(*log_folder))
  
  File.open(File.join(*log_folder, filename), 'w') do |f|
    f << "#{e.class}: #{e}"
    if e.respond_to? :backtrace
      f << "\n\t#{e.backtrace.join("\n\t")}"
    end
  end
end

begin
  require 'rubygems'
  require 'gosu'
  #require 'yaml'
  require 'msgpack'
  require 'pathname'
  require 'fileutils'
  require_relative File.join('app', 'constants')

  dev_constants_path = File.join(APP_PATH, 'constants', 'dev_constants.rb')
  developer_mode_available = File.exists?(dev_constants_path)
  enable_developer_mode = true

  DEVELOPER_MODE = enable_developer_mode && developer_mode_available

  if DEVELOPER_MODE
    require 'v8'
    require 'json'
    require 'texplay'
    require dev_constants_path
  end

  require File.join(APP_PATH, 'window')
  Window.new.show
  
rescue Exception => e
  write_error_log e
  raise e
  
ensure
  begin
    if Object.const_defined?('Resources')
      if Resources.const_defined?("Sprites") && Resources::Sprites.loaded
        puts "Saving Sprites!"
        Resources::Sprites.save_all!
      end
      if Resources.const_defined?("CharacterStats") && Resources::CharacterStats.loaded
        puts "Saving CharacterStats!"
        Resources::CharacterStats.save_all!
      end
    end
  rescue Exception => e
    write_error_log e
    raise e
  end
end