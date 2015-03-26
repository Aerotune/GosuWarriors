require 'fileutils'
require_relative 'json'

module SpriteSheetImporter
  class << self
    def import_all! options={overwrite: false}
      
      @sprites = {}
      @single_sheet_sprites = {}
      @multi_sheet_sprites = {}
      
      @folders = {}
      
      Dir[File.join(DEV_SPRITE_SHEETS_IMPORT_QUEUE_PATH, '**', '*.json')].each do |json_path|
        sprite_resource_path   = SpriteResourceFileTool.to_a(json_path, DEV_SPRITE_SHEETS_IMPORT_QUEUE_PATH)
        sprite_resource_folder = sprite_resource_path[0...-1]
        
        image_path = json_path.gsub(/\.json$/, '.png')
              
        @folders[sprite_resource_folder] ||= {'single_sheet' => [], 'multi_sheet' => []}
        
        if match = sprite_resource_path[-1].match(FILE_PART_PATTERN)
          id    = sprite_resource_path[-1].gsub(FILE_PART_PATTERN, '')
          sheet = sprite_resource_path[-1]
          sprite_sheet_path = sprite_resource_path
          sprite_resource_path = sprite_resource_path.dup
          sprite_resource_path[-1] = id
          
          @folders[sprite_resource_folder]['multi_sheet'] << {
            'part_number'          => match['part_number'].to_i,
            'sheet'                => sheet,
            'id'                   => id,
            'json_path'            => json_path,
            'image_path'           => image_path,
            'sprite_sheet_path'    => sprite_sheet_path,
            'sprite_resource_path' => sprite_resource_path
          }
        else
          @folders[sprite_resource_folder]['single_sheet'] << {
            'sheet'                => sprite_resource_path[-1],
            'id'                   => sprite_resource_path[-1],
            'json_path'            => json_path,
            'image_path'           => image_path,
            'sprite_sheet_path'    => sprite_resource_path,
            'sprite_resource_path' => sprite_resource_path
          }
        end
      end
      
      @folders.each do |array_path, sheets|
        sheets['multi_sheet'].sort! { |a,b| a['part_number'] <=> b['part_number']  }
      end
      
      @folders.each do |array_path, sheets|
        folder_path = File.join(SPRITE_RESOURCE_PATH, *array_path)
        FileUtils.mkdir_p(folder_path)
        sheets['single_sheet'].each do |sheet|
          raw_meta_data = JSON.parse_file(sheet['json_path'])
          copy_image sheet['image_path'], sheet['sprite_sheet_path'], options
          add_frames sheet['id'],         sheet['sheet'], raw_meta_data, sheet['sprite_resource_path']
        end
        sheets['multi_sheet'].each do |sheet|
          raw_meta_data = JSON.parse_file(sheet['json_path'])
          copy_image sheet['image_path'], sheet['sprite_sheet_path'], options
          add_frames sheet['id'],         sheet['sheet'], raw_meta_data, sheet['sprite_resource_path']
        end
      end

      Resources::Sprites.save_all! sprites: @sprites, overwrite: options[:overwrite]
      FileUtils.cp_r "#{DEV_SPRITE_SHEETS_IMPORT_QUEUE_PATH}#{File::SEPARATOR}.", DEV_SPRITE_SHEETS_IMPORTED_PATH
      FileUtils.rm_rf("#{DEV_SPRITE_SHEETS_IMPORT_QUEUE_PATH}/.", secure: true)
      Resources::Sprites.sprites = nil
      Loader.loaded = false
      
      #FileUtils.mv Dir[File.join(DEV_SPRITE_SHEETS_IMPORT_QUEUE_PATH, '*')], DEV_SPRITE_SHEETS_IMPORTED_PATH.to_s
    end
    
    
    private
    
    
    def add_frames id, sheet_id, raw_meta_data, sprite_resource_path
      @sprites[sprite_resource_path] ||= {
        'id'             => id,
        'face_direction' => -1,
        'frames'         => []
      }
      
      frames = []
      raw_meta_data['frames'].each do |raw_frame|
        frame = {}
        frame['sheet']    = sheet_id
        frame['source']   = raw_frame['frame']
        frame['offset_x'] = raw_frame['spriteSourceSize']['x']
        frame['offset_y'] = raw_frame['spriteSourceSize']['y']
        frame['shapes']   = Resources::Sprites.create_shapes_hash
        frames << frame
      end
      
      @sprites[sprite_resource_path]['frames'].push *frames
    end
    
    def copy_image source_image_path, sprite_resource_path, options
      destination_image_path = File.join(SPRITE_RESOURCE_PATH, *sprite_resource_path) + '.png'
      if options[:overwrite] || !File.exist?(destination_image_path)
        FileUtils.copy source_image_path, destination_image_path
      end
    end
  end
end