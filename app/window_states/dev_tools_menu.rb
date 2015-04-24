class WindowStates::DevToolsMenu < WindowState
  def initialize
    @previous_menu = :main_menu
    @menu = Menu.new
    
    @menu.add_menu_item "Spritesheets" do
      state = WindowStates::DevLoader.new do
        $window.set_state WindowStates::DevSpriteFolderList.new
      end
      $window.set_state state
    end
    
    @menu.add_menu_item "Character Stats" do
      state = WindowStates::DevLoader.new false do
        $window.set_state WindowStates::DevCharacterList.new
      end
      $window.set_state state
    end
    
    @menu.add_menu_item "Export Level Shape Images" do
      state = WindowStates::DevLoader.new false do
        Resources::Stages.require!
        Resources::Stages.save_as_images!
        $window.set_state :main_menu
      end
      $window.set_state state
    end
    
    @menu.add_menu_item "Level Editor" do
      state = WindowStates::DevLoader.new false do
        $window.set_state WindowStates::DevLevelEditor.new
      end
      $window.set_state state
    end
    
    @menu.add_menu_item "" do; end
    
    @menu.add_menu_item "Import image sequence (Don't overwrite existing sprites)" do
      state = WindowStates::DevLoader.new false do
        ImageSequenceImporter.import_all! overwrite: false
        $window.set_state :main_menu
      end
      $window.set_state state      
    end
    
    @menu.add_menu_item "Import image sequence (Overwrite existing sprite sheets)" do
      state = WindowStates::DevLoader.new false do
        ImageSequenceImporter.import_all! overwrite: true
        $window.set_state :main_menu
      end
      $window.set_state state      
    end
    
    @menu.add_menu_item "Import flash sprite sheets (Don't overwrite existing sprites)" do
      state = WindowStates::DevLoader.new do
        SpriteSheetImporter.import_all! overwrite: false
        $window.set_state :main_menu
      end
      $window.set_state state      
    end
    
    @menu.add_menu_item "Import flash sprite sheets (Overwrite existing sprite sheets)" do
      state = WindowStates::DevLoader.new do
        SpriteSheetImporter.import_all! overwrite: true
        $window.set_state :main_menu
      end
      $window.set_state state
    end
    
    @menu.add_menu_item "" do; end
    
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