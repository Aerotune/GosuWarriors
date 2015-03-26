class WindowStates::MainMenu < WindowState
  def initialize
    require_fonts!
    require File.join(GAME_LIB_PATH, 'menu')
    @menu = Menu.new
    @menu.add_menu_item "Start Game" do
      $window.set_state :game_session_loader
    end
    
    if DEVELOPER_MODE
      @menu.add_menu_item "(dev) Development Tools" do
        $window.set_state :dev_tools_menu
      end
    end
  end
  
  def key_down key
    
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
  
  
  private
  
  
  def require_fonts!
    require File.join(GAME_LIB_PATH, 'resources.rb')
    Resources::Fonts.require!
  end
end