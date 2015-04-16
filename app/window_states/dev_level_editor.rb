class WindowStates::DevLevelEditor < WindowState
  Dir[File.join(WINDOW_STATES_PATH, 'dev_level_editor', '*.rb')].each { |file| require file }
  
  attr_accessor :shapes, :current_shape, :cursor
  
  def initialize
    Resources::Stages.require!
    @stage         = Resources::Stages['test_level']
    @stage['shapes'][0] ||= ShapeHelper.create_shape
    
    set_shape_index 0
    
    NeutralCursor.load_images $window
    
    @point = Gosu::Image.new $window, File.join(WINDOW_STATES_PATH, 'dev_level_editor', 'point.png'), false
    
    @camera = Camera.new 0, 0, 1.0
    @start_drag_x = 0
    @start_drag_y = 0
  end
  
  def set_shape_index index
    delete_current_shape if @current_shape && @current_shape['convexes'].empty?
    @current_shape_index = index % @stage['shapes'].length
    @current_shape = @stage['shapes'][@current_shape_index]
    @edit_shape_tool.release! if @edit_shape_tool
    @edit_shape_tool = EditShapeTool.new @current_shape, self
  end
  
  def set_new_shape
    unless @current_shape['outline'].empty?
      if @stage['shapes'].last['outline'].empty?
        set_shape_index @stage['shapes'].length-1
      else
        index = @stage['shapes'].length
        @stage['shapes'][index] = ShapeHelper.create_shape
        set_shape_index index
      end      
    end
  end
  
  def delete_current_shape
    warn "No spawn!" if @stage['spawn']['shape_index'] == @current_shape_index
    @stage['shapes'].delete @current_shape
    @current_shape = nil
    set_shape_index @current_shape_index - 1
  end
  
  def select_mouse_over_shape
    @stage['shapes'].each_with_index do |shape, shape_index|
      shape['convexes'].each do |convex_points|
        if ShapeHelper::Point.hits_point? convex_points, mouse_x, mouse_y
          set_shape_index shape_index
          break
        end
      end
    end
  end
  
  def key_down key
    @edit_shape_tool.key_down key
    
    case key
    when 'backspace'
      if $window.key_down_match? 'alt'
        delete_current_shape
      end
    when 'escape'
      MouseTrap.release!
      $window.cursor_visible = true
      $window.set_state :main_menu
    when 'return'
      @edit_shape_tool.release!
      set_new_shape
    when 'space'
      prev_shape_index = @current_shape_index
      select_mouse_over_shape
      drag_current_shape if @current_shape_index && (@current_shape_index == prev_shape_index) && MouseTrap.capture(self)
    when 'tab'
      if $window.key_down_match?('shift')
        set_shape_index @current_shape_index - 1
      else
        set_shape_index @current_shape_index + 1
      end
    when 's'
      puts "Setting Spawn"
      outline = @current_shape['outline']
      
      @stage['spawn'] = {
        'shape_index' => @current_shape_index,
        'x' => mouse_x,
        'y' => mouse_y
      }
      p @stage['spawn']
    end
  end
  
  def key_up key
    @edit_shape_tool.key_up key
    
    case key
    when 'space'
      if MouseTrap.release(self)
        stop_drag_current_shape
      end
    when 'escape'
      
    when 'mouse_left'
      MouseTrap.release(self)
    end
  end
  
  def drag_current_shape
    @start_drag_x = mouse_x
    @start_drag_y = mouse_y
    @drag_shape   = @current_shape
  end
  
  def stop_drag_current_shape
    dx = mouse_x - @start_drag_x
    dy = mouse_y - @start_drag_y
    ShapeHelper.translate_shape! @drag_shape, dx, dy
    @drag_shape = nil
    @start_drag_x = 0
    @start_drag_y = 0
  end
  
  def update
    @edit_shape_tool.update
    
    edge_thickness = 150
    right_edge = $window.width-edge_thickness
    left_edge = edge_thickness
    top_edge  = edge_thickness
    bottom_edge = $window.height-edge_thickness
    
    if $window.mouse_x > right_edge
      @camera.look_x = (@camera.look_x - (right_edge - $window.mouse_x)/2).to_i
    end
    
    if $window.mouse_x < left_edge
      @camera.look_x = (@camera.look_x - (left_edge - $window.mouse_x)/2).to_i
    end
    
    if $window.mouse_y > bottom_edge
      @camera.look_y = (@camera.look_y - (bottom_edge - $window.mouse_y)/2).to_i
    end
    
    if $window.mouse_y < top_edge
      @camera.look_y = (@camera.look_y - (top_edge - $window.mouse_y)/2).to_i
    end
    
    if $window.key_down? 'up'
      @camera.zoom += 0.05
      @camera.zoom = 1.0 if @camera.zoom > 1.0
    end
    
    if $window.key_down? 'down'
      @camera.zoom -= 0.05
      @camera.zoom = 0.4 if @camera.zoom < 0.4
    end
    
    #dx = mouse_x - @start_drag_x
    #dy = mouse_y - @start_drag_y
  end
  
  def mouse_x
    #(($window.mouse_x-$window.width/2)/@zoom + @camera_x).to_i
    @camera.x_for_screen_x $window.mouse_x
    #((($window.mouse_x-@camera_x)/@zoom)).to_i
  end
  
  def mouse_y
    #(($window.mouse_y-$window.height/2)/@zoom + @camera_y).to_i
    
    @camera.y_for_screen_y $window.mouse_y
    #((($window.mouse_y-@camera_y)/@zoom)).to_i
  end
  
  def draw
    #$window.scale @zoom, @zoom, $window.width/2, $window.height/2 do
    #  $window.translate @camera_x-$window.width/2, @camera_y-$window.height/2 do
    #    
    #  end
    #end
    
    
    
    @camera.view do
      @stage['shapes'].each do |shape|
        ShapeHelper::Render.draw_convexes shape, 0x55FFFFFF
        ShapeHelper::WalkRender.draw_non_walkable shape, 0x55FF3333
        ShapeHelper::Render.draw_walls shape, 0x550000FF
        ShapeHelper::Render.draw_ceilings shape, 0x550000FF
        ShapeHelper::WalkRender.draw_walkable shape, 0xAA33FF33
      end
      
      if @current_shape
        ShapeHelper::WalkRender.draw_non_walkable @current_shape, 0x55FF0000
        ShapeHelper::Render.draw_walls @current_shape, 0xFF0000FF
        ShapeHelper::Render.draw_ceilings @current_shape, 0xFF0000FF
        ShapeHelper::WalkRender.draw_walkable @current_shape, 0xFF00FF00
      end
      
      if @drag_shape
        dx = mouse_x - @start_drag_x
        dy = mouse_y - @start_drag_y
      else
        dx = 0
        dy = 0
      end
      $window.translate dx, dy do
        @current_shape['outline'].each do |point|
          @point.draw_rot point[0], point[1], Z, 0, 0.5, 0.5
        end
      end
    end
    
    NeutralCursor.draw $window.mouse_x, $window.mouse_y, Z
  end
end