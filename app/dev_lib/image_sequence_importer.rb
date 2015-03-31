require 'fileutils'

module ImageSequenceImporter
  class << self
    def import_all! options={overwrite: false}
      puts "Image Sequence Importer started!"
      directories = []
      
      Dir[File.join(DEV_IMAGE_SEQUENCES_IMPORT_QUEUE_PATH, '**', '*.png')].each do |png_path|
        dirname = File.dirname(png_path)
        directories << dirname unless directories.include? dirname
      end
      
      p directories
      
      directories.each do |directory|
        basename = File.basename(directory)
        sprite_resource_path = Pathname.new(directory).relative_path_from(DEV_IMAGE_SEQUENCES_IMPORT_QUEUE_PATH).to_s.split(File::SEPARATOR)
        msgpack_hash = {
          'id' => basename,
          'face_direction' => 1,
          'frames' => []
        }
        
        sprite_sheets = {}
        sheet_part    = 1
        sheet_name    = "#{basename}_part_#{sheet_part}"
        quad_size     = 1022#TexPlay::TP_MAX_QUAD_SIZE
        sprite_sheet  = TexPlay.create_blank_image($window, quad_size, quad_size)
        sprite_sheets[sheet_name] = sprite_sheet
        x = 0
        y = 0
        max_height = 0
        
        Dir[File.join(directory, '*.png')].sort.each do |png_path|
          image = Gosu::Image.new($window, png_path, false)
          max_height = image.height if image.height > max_height
          raise "Image too large: #{png_path}" if image.width > quad_size && image.height > quad_size
          
          if ((x + image.width) > sprite_sheet.width)
            x = 0
            y += max_height
            max_height = 0
          end
          
          if ((y + image.height) > sprite_sheet.height)
            # next spritesheet
            sheet_part   += 1
            sheet_name    = "#{basename}_part_#{sheet_part}"
            sprite_sheet  = TexPlay.create_blank_image $window, quad_size, quad_size
            sprite_sheets[sheet_name] = sprite_sheet
            x = 0
            y = 0
            max_height = 0
          end 
          
          if ((x + image.width) < sprite_sheet.width) && ((y + image.height) < sprite_sheet.height)
            sprite_sheet.splice image, x, y
            
            msgpack_hash['frames'] << {
              'sheet' => sheet_name,
              'source' => {
                'x' => x,
                'y' => y,
                'w' => image.width,
                'h' => image.height
              },
              'offset_x' => 0,
              'offset_y' => 0
            }
            
            x += image.width
          end
        end # png_paths.each
        
        result_directory = File.join(RESOURCES_PATH, 'sprites', *sprite_resource_path[0...-1])
        
        FileUtils.mkdir_p(result_directory)
        
        sprite_sheets.each do |sheet_name, image|
          sheet_file_path = File.join(result_directory, sheet_name) + '.png'
          image.save(sheet_file_path) if options[:overwrite] || !File.exist?(sheet_file_path)
        end        
        
        msgpack_file_path = File.join(result_directory, basename) + '.msgpack'
        if options[:overwrite] || !File.exist?(msgpack_file_path)
          msgpack = msgpack_hash.to_msgpack
          File.open(msgpack_file_path, 'wb') do |f|
            f << msgpack
          end
        end
        
        FileUtils.mkdir_p(DEV_IMAGE_SEQUENCES_IMPORTED_PATH)
        FileUtils.cp_r "#{DEV_IMAGE_SEQUENCES_IMPORT_QUEUE_PATH}#{File::SEPARATOR}.", DEV_IMAGE_SEQUENCES_IMPORTED_PATH
        FileUtils.rm_rf("#{DEV_IMAGE_SEQUENCES_IMPORT_QUEUE_PATH}#{File::SEPARATOR}.", secure: true)
        Resources::Sprites.load!
      end # directories.each
    end # import_all!
  end # class << self
end # class