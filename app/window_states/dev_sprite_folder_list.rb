class WindowStates::DevSpriteFolderList < WindowState
  def initialize
    @previous_menu = :dev_tools_menu
    @menu = Menu.new
    
    sprite_resource_folders = []
    Dir[File.join(SPRITE_RESOURCE_PATH, '**', '*')].each do |directory|
      next unless File.directory? directory
      next if Dir[File.join(directory, '*.msgpack')].empty?
      sprite_resource_folders << directory
    end
    
    sprite_resource_folders.each do |sprite_resource_folder_name|
      sprite_resource_folder_name = \
        Pathname.new(sprite_resource_folder_name)
        .relative_path_from(SPRITE_RESOURCE_PATH)
        .to_s
        .split(File::SEPARATOR)
              
      @menu.add_menu_item "%w[#{sprite_resource_folder_name.join(' ')}]" do
        $window.set_state WindowStates::DevSpriteEditor.new(sprite_resource_folder_name)
      end
    end
    
    @menu.add_menu_item "<< Back" do
      $window.set_state @previous_menu
    end
  end
  
  def key_down key
    case key
    when 'escape'
      $window.set_state @previous_menu
    end
  end
  
  def key_up key
    @menu.key_up key
  end
  
  def update
    @menu.update
  end
  
  def draw
    $window.fill 0xFF121212
    @menu.draw
  end
end