require 'pathname'

module Resources::Sprites
  class << self
    attr_reader :sprites
    
    def require!
      load! unless @sprites
    end
  
    def load!
      @sprites = {}
      @spritesheets = {}
      
      resource_folders = get_resource_folders
      resource_folders.each do |resource_folder|
        msgpack_paths = Dir[File.join(resource_folder, '*.msgpack')].sort!
              
        msgpack_paths.each do |msgpack_path|
          sprite_resource_path_name = Pathname.new(msgpack_path).relative_path_from(SPRITE_RESOURCE_PATH)
          sprite_resource_path      = sprite_resource_path_name.to_s.split(File::SEPARATOR)
          sprite_resource_path[-1]  = File.basename(sprite_resource_path[-1], '.msgpack')
          sprite_resource_folder    = sprite_resource_path[0...-1]
          
          msgpack = MessagePack.unpack_file(msgpack_path)
          
          @sprites[sprite_resource_path] ||= {
            'id'             => msgpack['id'] || sprite_resource_path.last,
            'face_direction' => msgpack['face_direction'] || -1,
            'frames'         => []
          }
          
          msgpack["frames"].each do |frame|
            sheet_path = [*sprite_resource_folder, frame["sheet"]]
            require_sheet sheet_path
            add_frame     sheet_path, sprite_resource_path, frame
          end          
        end
      end
    end
  
    def [] sprite_resource_path
      @sprites[sprite_resource_path]
    end
    
    def in_folder sprite_resource_folder
      @sprites.select { |sprite_resource_path, sprite| sprite_resource_path[0...-1] == sprite_resource_folder }
    end
    
    def to_hash sprite_resource_path
      sprite = @sprites[sprite_resource_path].dup
      frames = []
      sprite['frames'].each do |frame|
        frames << frame.select do |key, value|
          case key
          when 'sheet', 'source', 'offset_x', 'offset_y', 'shapes'; true
          end
        end
      end
      sprite['frames'] = frames
      
      return Marshal.load(Marshal.dump(sprite))
    end
    
    def save_all!
      @sprites.each do |sprite_resource_path, frames|
        msgpack_path = [SPRITE_RESOURCE_PATH, *sprite_resource_path].join(File::SEPARATOR) + '.msgpack'
        File.open(msgpack_path, 'wb') do |file|
          file << to_hash(sprite_resource_path).to_msgpack
        end
      end
    end
  
  
    private
    
    def require_sheet sheet_path
      file_path = File.join(SPRITE_RESOURCE_PATH, *sheet_path) + ".png"
      @spritesheets[sheet_path] ||= Gosu::Image.new($window, file_path, true)
    end
    
    def add_frame sheet_path, sprite_resource_path, frame
      loaded_frames = @sprites[sprite_resource_path]['frames']
      loaded_frame  = {}
      loaded_frame['image']          = extract_frame_image sheet_path, frame
      loaded_frame['sheet']          = frame['sheet']
      loaded_frame['source']         = frame['source']
      loaded_frame['offset_x']       = frame['offset_x']
      loaded_frame['offset_y']       = frame['offset_y']
      loaded_frame['shapes']         = frame['shapes'] || Array.new(10) {{'tags' => [], 'outline' => [], 'convexes' => []}}
      
      loaded_frames << loaded_frame
    end
    
    def extract_frame_image sheet_path, frame
      sheet_image = @spritesheets[sheet_path]
      source = frame['source']
      image = sheet_image.subimage(source['x'], source['y'], source['w'], source['h'])
      warn "'#{File.join(SPRITE_RESOURCE_PATH, *sheet_path)}' is slow at loading! try making it a 1024x1024 spritesheet" unless image
      image ||= Gosu::Image.new $window, sheet_image, true, source['x'], source['y'], source['w'], source['h']
      image
    end
  
    def get_resource_folders
      resource_folders = []
    
      Dir[File.join(SPRITE_RESOURCE_PATH, '**', '*/')].each do |resource_folder|
        resource_folders << resource_folder unless Dir[File.join(resource_folder, '*.msgpack')].empty?
      end
    
      resource_folders
    end
  end
end