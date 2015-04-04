class WindowStates::DevLevelEditor < WindowState
  Dir[File.join(WINDOW_STATES_PATH, 'dev_level_editor', '*.rb')].each { |file| require file }
  
  attr_accessor :shapes, :current_shape, :cursor
  
  def initialize
    Resources::Stages.require!
    @stage         = Resources::Stages['test_level']
    @stage['shapes'][0] ||= ShapeLib.create_shape
    @current_shape = @stage['shapes'][0]
    
    @draw_tool = EditShapeTool.new @current_shape
    
    NeutralCursor.load_images $window
    
    @point = Gosu::Image.new $window, File.join(WINDOW_STATES_PATH, 'dev_level_editor', 'point.png'), false
    
    @camera_x = 0
    @camera_y = 0
  end
  
  def key_down key
    @draw_tool.key_down key
    
    case key
    when 'escape'
      MouseTrap.release!
      $window.cursor_visible = true
      $window.set_state :main_menu
    when 'space'
      start_point_index, x, y = IntMath.nearest_point_on_surface @current_shape['outline'], $window.mouse_x, $window.mouse_y
      
      @stage['spawn'] = {
        'shape_index' => 0,
        'start_point_index' => start_point_index,
        'distance' => IntMath.distance(x, y, *@current_shape['outline'][start_point_index])
      }
    end
  end
  
  def key_up key
    @draw_tool.key_up key
    
    case key
    when 'escape'
      
    when 'mouse_left'
      MouseTrap.release(self)
    end
  end
  
  def update
    @draw_tool.update
  end
  
  def draw
    $window.translate @camera_x, @camera_y do
      #@shapes.each do |shape|
      #  ShapeLib.draw_outline shape, 0xAAFF0000
      #end
      if @current_shape
        ShapeLib.draw_terrain @current_shape
      end
      
      @current_shape['outline'].each do |point|
        @point.draw_rot point[0], point[1], Z, 0, 0.5, 0.5
      end
    end
    
    NeutralCursor.draw $window.mouse_x, $window.mouse_y, Z
  end
end