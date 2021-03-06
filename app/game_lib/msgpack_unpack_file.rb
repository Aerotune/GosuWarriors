def MessagePack.unpack_file msgpack_path
  result = nil
  
  File.open(msgpack_path, 'rb') do |f|
    result = nil
    
    begin
      result = MessagePack::Unpacker.new(f).unpack
      #u.each do |obj|
      #  result = obj
      #  break
      #end
    rescue EOFError => e
      # Reached end of file
    end 
  end
  
  result
end