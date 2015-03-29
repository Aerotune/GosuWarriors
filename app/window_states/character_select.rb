class WindowStates::CharacterSelect < WindowState
  def initialize
    @previous_menu = :main_menu
    @menu = Menu.new
        
    Dir[File.join(RESOURCES_PATH, 'stats', 'characters', '*.msgpack')].each do |msgpack_path|
      character_name = File.basename(msgpack_path, '.msgpack')
      
      @menu.add_menu_item character_name do
        loader = WindowStates::Loader.new do
          $window.set_state WindowStates::GameSession.new(character_name)
        end
        
        $window.set_state loader
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