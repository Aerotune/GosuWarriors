require_relative 'loaders'
require_relative 'window_states'

class Window < Gosu::Window
  attr_accessor :scoreboard
  attr_accessor :clipboard
  attr_reader :state, :states
  
  attr_accessor :cursor_visible
  
  def initialize
    _width  = Gosu.available_width
    _height = Gosu.available_height
    
    
    
    if DEVELOPER_MODE
      min_width = 1280
      min_height = 1022
    else
      min_width = 1280
      min_height = 720
    end
    
    _width = min_width if _width < min_width
    _height = min_height if _height < min_height
    
    @cursor_visible = true
    
    super _width, _height, false#, 1000.0/20.0
    $window = self
    @clipboard = []
    @scoreboard = {}
    @states = {}
    @states[:main_menu] = WindowStates::MainMenu.new
    
    if DEVELOPER_MODE
      @states[:dev_tools_menu]         = WindowStates::DevToolsMenu.new
      @states[:dev_edit_shapes_loader] = WindowStates::DevLoader.new do
        $window.set_state WindowStates::DevEditShapes.new
      end
    end
    
    @state = @states[:main_menu]
    
    @line_image = Gosu::Image.new $window, 'resources/line_image.png', true
  end
  
  def needs_cursor?
    @cursor_visible
  end
  
  def mouse_x
    super.to_i
  end
  
  def mouse_y
    super.to_i
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
  
  def draw_image_line x1, y1, x2, y2, color, z
    angle = Gosu.angle x2, y2, x1, y1
    factor_x = Gosu.distance(x1, y1, x2, y2) / @line_image.width
    factor_y = 1
    @line_image.draw_rot x1, y1, z, angle+90, 0, 0.5, factor_x, factor_y, color
  end
end

