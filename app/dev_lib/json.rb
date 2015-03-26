require 'json'

module JSON
  def self.parse_file file_path
    # why did I have to go through this...
    begin
      file = File.open(file_path, 'r:bom|utf-8')
      raw = file.read
      file.close
    rescue
      file = File.open file_path, 'rb:bom|utf-16le:utf-8'
      raw = file.read
      file.close
      
      File.open(file_path, 'w:utf-8') do |f|
        f << raw
      end
      file = File.open(file_path, 'r:bom|utf-8')
      raw = file.read
      file.close
    end
    
    raw.gsub!(/[\u201c\u201d]/, '"')

    JSON.parse(raw)    
  end
end