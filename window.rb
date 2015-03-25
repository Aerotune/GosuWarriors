require_relative 'loaders'
require_relative 'window_states'

class Window < Gosu::Window
  attr_accessor :clipboard
  attr_reader :state, :states
  
  def initialize
    _width  = 0#Gosu.available_width*7/8
    _height = 0#Gosu.available_height*7/8
    
    min_width = 1280
    min_height = 720
    
    _width = min_width if _width < min_width
    _height = min_height if _height < min_height
    
    super _width, _height, false
    $window = self
    @clipboard = []
    @states = {}
    @states[:main_menu]     = WindowStates::MainMenu.new
    @states[:game_session_loader] = WindowStates::Loader.new do
      $window.set_state WindowStates::GameSession.new
    end
    
    if DEVELOPER_MODE
      @states[:dev_tools_menu]         = WindowStates::DevToolsMenu.new
      @states[:dev_edit_shapes_loader] = WindowStates::DevLoader.new do
        $window.set_state WindowStates::DevEditShapes.new
      end
    end
    
    @state = @states[:main_menu]
  end
  
  def needs_cursor?
    true
  end
  
  def set_state symbol_or_state
    case symbol_or_state
    when Symbol
      @state = @states[symbol_or_state]
      raise RuntimeError, "No window state #{symbol_or_state.inspect}" unless @state
    else
      @state = symbol_or_state
    end
    @state.on_set
  end
  
  def button_down id
    key_symbol = KEY_SYMBOLS[id]
    @state.key_down key_symbol
  end
  
  def button_up id
    key_symbol = KEY_SYMBOLS[id]
    @state.key_up key_symbol
  end
  
  def key_down? key_symbol
    id = KEY_SYMBOLS.key(key_symbol)
    button_down?(id)
  end
  
  def key_down_match? *patterns
    matches = []
    
    patterns.each do |pattern|
      matches.push *KEY_SYMBOLS.values.select { |value| value.match pattern }
    end
    
    matches.each do |match|
      return true if key_down? match
    end
    
    false
  end
  
  def update
    @state.update
  end
  
  def draw
    @state.draw
  end
  
  def fill c1, c2=c1, c3=c2, c4=c3
    x1 = 0
    y1 = 0
    
    x2 = width
    y2 = 0
    
    x3 = width
    y3 = height
    
    x4 = 0
    y4 = height
    
    $window.draw_quad x1, y1, c1, x2, y2, c2, x3, y3, c3, x4, y4, c4
  end
end

