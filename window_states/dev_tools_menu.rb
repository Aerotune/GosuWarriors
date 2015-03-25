class WindowStates::DevToolsMenu < WindowState
  def initialize
    @previous_menu = :main_menu
    @menu = Menu.new
    
    @menu.add_menu_item "(dev) Spritesheets" do
      state = WindowStates::DevLoader.new do
        $window.set_state WindowStates::DevSpriteFolderList.new
      end
      $window.set_state state
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