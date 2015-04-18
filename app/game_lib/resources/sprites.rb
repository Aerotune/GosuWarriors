require 'pathname'

module Resources::Sprites
  class << self
    attr_reader :loaded
    attr_accessor :sprites
    
    def require!
      load! unless @sprites
    end
  
    def load!
      @loaded = false
      
      @sprites = {}
      @spritesheets = {}
      
      resource_folders = get_resource_folders
      resource_folders.each do |resource_folder|
        msgpack_paths = Dir[File.join(resource_folder, '*.msgpack')].sort!
              
        msgpack_paths.each do |msgpack_path|
          sprite_resource_path = SpriteResourceFileTool.to_a(msgpack_path, SPRITE_RESOURCE_PATH)
          sprite_resource_folder    = sprite_resource_path[0...-1]
          
          msgpack = MessagePack.unpack_file(msgpack_path)
          p sprite_resource_path
          @sprites[sprite_resource_path] ||= {
            'id'             => msgpack['id'] || sprite_resource_path.last,
            'face_direction' => msgpack['face_direction'] || -1,
            'fps'            => msgpack['fps'] || 27,
            'frames'         => [],
            'bounding_box'   => [[-20, -200], [20, -200], [20, 10], [-20, 10]]
          }
          
          msgpack["frames"].each do |frame|
            sheet_path = [*sprite_resource_folder, frame["sheet"]]
            require_sheet sheet_path
            add_frame     sheet_path, sprite_resource_path, frame
          end          
        end
      end
      
      @loaded = true
    end
  
    def [] sprite_resource_path
      @sprites[sprite_resource_path]
    end
    
    def in_folder sprite_resource_folder
      @sprites.select { |sprite_resource_path, sprite| sprite_resource_path[0...-1] == sprite_resource_folder }
    end
    
    def to_hash sprite_resource_path, sprites=@sprites
      sprite = sprites[sprite_resource_path].dup
      frames = []
      sprite['frames'].each do |frame|
        frames << frame.select do |key, value|
          case key
          when 'sheet', 'source', 'offset_x', 'offset_y', 'shapes', 'blending_mode', 'sfx'; true
          end
        end
      end
      
      frames.each_with_index do |frame, index|
        frame['shapes'].each do |shape|
          shape['convex_hull'] = ShapeHelper.convex_hull shape['outline']
        end
      end
      
      sprite['frames'] = frames
      
      return Marshal.load(Marshal.dump(sprite))
    rescue Exception => e
      warn "Failed to convert sprite to hash for #{sprite_resource_path}"
      raise e
    end
    
    def save_all! options={sprites: @sprites, overwrite: true}
      options[:sprites].each do |sprite_resource_path, frames|
        msgpack_path = [SPRITE_RESOURCE_PATH, *sprite_resource_path].join(File::SEPARATOR) + '.msgpack'
        
        if options[:overwrite] || !File.exist?(msgpack_path)
          File.open(msgpack_path, 'wb') do |file|
            file << to_hash(sprite_resource_path, options[:sprites]).to_msgpack
          end
        end
      end
    end
    
    def create_shapes_hash
      Array.new(10) {{'tags' => [], 'outline' => [], 'convexes' => [], 'convex_hull' => []}}
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
      loaded_frame['shapes']         = frame['shapes'] || create_shapes_hash
      loaded_frame['blending_mode']  = frame['blending_mode'] || 'normal'
      loaded_frame['sfx']            = frame['sfx'] || ''
      loaded_frame['shapes'].each do |shape|
        shape['convexes'].each do |convex|
          convex.each_with_index do |point, index|
            #!!! shouldn't be needed anymore
            convex[index] = [point[0].to_i, point[1].to_i]
          end
        end
        
        shape['convex_hull'] ||= ShapeHelper.convex_hull shape['outline']
      end
      
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