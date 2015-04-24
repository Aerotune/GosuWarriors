module Resources::Stages
  @stages = {}
  
  class << self
    attr_reader :loaded
    
    def require!
      load! unless @loaded
    end
    
    def load!
      @loaded = false
      
      Dir[File.join(STAGE_RESOURCE_PATH, '*.msgpack')].each do |msgpack_path|
        stage_id = File.basename(msgpack_path, '.msgpack')
        msgpack  = MessagePack.unpack_file(msgpack_path) || {}
        
        @stages[stage_id] = {
          'id' => stage_id,
          'shapes' => msgpack['shapes'] || [],
          'spawn' => msgpack['spawn']
        }
      end
      
      @loaded = true
    end
    
    def [] stage_id
      @stages[stage_id]
      #@stages[stage_id] ||= {
      #  'id' => stage_id,
      #  'shapes' => [],
      #  'spawn' => {}
      #}
    end
    
    def save_all!
      @stages.each do |stage_id, stage|
        msgpack = stage.to_msgpack
        msgpack_path = File.join(STAGE_RESOURCE_PATH, stage_id) + '.msgpack'
        File.open msgpack_path, 'wb' do |f|
          f << msgpack
        end
      end
    end
    
    def translate_stage stage_id, dx, dy
      stage = self[stage_id]
      stage['shapes'].each do |shape|
        ShapeHelper::Transform.translate! shape['outline'], dx, dy
        shape['convexes'].each do |convex|
          ShapeHelper::Transform.translate! convex, dx, dy
        end
      end
      stage['spawn']['x'] += dx
      stage['spawn']['y'] += dy
    end
    
    def stage_bounds stage_id
      stage = @stages[stage_id]
      first_point = stage['shapes'].first['outline'].first
      min_x, min_y, max_x, max_y = first_point[0], first_point[1], first_point[0], first_point[1]
      stage['shapes'].each do |shape|
        shape['outline'].each do |point|
          min_x = point[0] if point[0] < min_x
          max_x = point[0] if point[0] > max_x
          min_y = point[1] if point[1] < min_y
          max_y = point[1] if point[1] > max_y
        end
      end
      
      return min_x, min_y, max_x, max_y
    end
    
    def save_as_images!
      puts "save_as_images..."
      
      floor_color = 0xFF00FF00
      ceiling_color = 0xFFFF0000
      wall_color = 0xFF0000FF
      
      @stages.each do |stage_id, stage|
        min_x, min_y, max_x, max_y = stage_bounds stage_id
                
        stage_folder = File.join(STAGE_RESOURCE_PATH, stage_id, 'images')
        FileUtils.rmdir stage_folder
        FileUtils.mkdir_p stage_folder
        
        square_size = 1024
        
        range_x_min = (min_x.to_f/square_size).floor
        range_y_min = (min_y.to_f/square_size).floor
        
        translate_stage stage_id, -range_x_min * square_size, -range_y_min * square_size
        
        ( range_x_min .. (max_x.to_f/square_size).ceil ).each do |x|
          ( range_y_min .. (max_y.to_f/square_size).ceil ).each do |y|
            x = x.to_i
            y = y.to_i
            texture = Ashton::Texture.new square_size, square_size
            texture.render do
              #!!! for some reason the image is flipped upside down so I'm using this to fix it
              $window.scale 1.0, -1.0, $window.width/2.0, $window.height/2.0 do
                $window.translate -x * square_size, -y * square_size do
                  stage['shapes'].each do |shape|
                    ShapeHelper::WalkRender.draw_walkable shape, floor_color
                    ShapeHelper::Render.draw_ceilings shape, ceiling_color
                    ShapeHelper::Render.draw_walls shape, wall_color
                  end
                end
              end
            end
            
            x_string = (x-range_x_min).to_s#.gsub('-', 'm')
            y_string = (y-range_y_min).to_s#.gsub('-', 'm')
            
            png_path = File.join stage_folder, "#{x_string}_#{y_string}.png"
            image = texture.to_image
            image.save png_path
            #File.open png_path, 'wb' do |f|
            #  f << msgpack
            #end
          end
        end
        
        
      end
      
      puts "save_as_images done!"
    end
  end
end