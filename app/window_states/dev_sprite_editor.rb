class WindowStates::DevSpriteEditor < WindowState
  Dir[File.join(WINDOW_STATES_PATH, 'dev_edit_shapes', '*.rb')].each { |file| require file }
  
  HINTS = [
    "(Tab): Next sprite.",
    "(Shift+Tab) Previous sprite.",
    "(Right) Next frame.",
    "(Left) Previous frame.",
    "(P) Play/Pause",
    "",
    "(space + drag) move center point for selected frames.",
    "(alt + space + drag) move shapes for selected frames.",
    "",
    "(left click) add next point in shape.",
    "(ctrl + z) remove latest point.",
    "(ctrl + c) copy selected frame shape.",
    "(ctrl + v) paste onto selected frames.",
    "(backspace) delete shapes on selected frames.",
    "You can selected multiple frames and paste them if your",
    "paste selection has exactly the same size as your copy selection.",
    "",
    "(0-9) select layer.",
    "Max one shape per layer.",
    "Set tags for each shape.",
    "Select multiple frames and set tags for them.",
    "Remember to deselect frames.",
    "Check the tick tag on the first frame of each hit.",
    "",
    "(Escape) Back to menu.",
    "Autosaves when you exit the program.",
  ]
  
  def initialize sprite_resource_folder_name
    @sprites = Resources::Sprites.in_folder(sprite_resource_folder_name)
    @create_previous_menu = -> {
      WindowStates::DevLoader.new do
        $window.set_state WindowStates::DevSpriteFolderList.new
      end
    }
    @sprite_frames_ui = SpriteFramesUI.new
    @sprite_list_ui   = SpriteListUI.new @sprites
    @sprite_list_ui.on_click do |sprite|
      @sprite_frames_ui.frames = sprite['frames']
      @sprite_frames_ui.sprite = sprite
      @sprite_direction_switch.sprite = sprite
      
      @sprite_fps_selector.key_down 'return'
      @sprite_fps_selector.sprite = sprite
    end
    @sprite_layer_ui = SpriteLayerUI.new
    @sprite_tag_ui = SpriteTagUI.new
    @sprite_tag_ui.on_update do |selected_tags|
      @sprite_frames_ui.selected_frames.each do |frame|
        new_tags = Marshal.load(Marshal.dump(selected_tags))
        tags = frame['shapes'][@sprite_layer_ui.layer]['tags']
        tags.clear
        tags.push *new_tags
      end
    end
    @sprite_direction_switch = SpriteDirectionSwitch.new
    @sprite_blending_mode_ui = SpriteBlendingModeUI.new
    @sprite_blending_mode_ui.on_update do |blending_mode|
      if @current_frame
        @current_frame['blending_mode'] = blending_mode
      end
      @sprite_frames_ui.selected_frames and @sprite_frames_ui.selected_frames.each do |frame|
        frame['blending_mode'] = blending_mode
      end
    end
    @sprite_fps_selector = SpriteFPSSelector.new
    
    @font = Resources::Fonts[:Arial12]
    
    @shape_layer = Array.new @sprite_layer_ui.layer_amount do |index|
      shape_tool_for = Hash.new do |shape_tool_for, frame|
        shape_tool_for[frame] = ShapeTool.new frame['shapes'][index]['outline'], frame['shapes'][index]['convexes']
      end
      shape_tool_for.compare_by_identity
      shape_tool_for
    end
    
    @factor_x = 1
    @anchor_point_x = $window.width/2
    @anchor_point_y = $window.height*2/3
    @delta_drag_x = 0
    @delta_drag_y = 0
    @delta_shape_drag_x = 0
    @delta_shape_drag_y = 0
  end
  
  def get_current_shape_tool
    shape_tool_for_frame(@current_frame)
  end
  
  def shape_tool_for_frame frame
    if frame
      @shape_layer[@sprite_layer_ui.layer][frame]
    end
  end
  
  def update
    #@sprite_list_ui.update
    @sprite_frames_ui.update
    @current_frame = @sprite_frames_ui.current_frame
    if @current_frame
      @sprite_tag_ui.tags = @current_frame['shapes'][@sprite_layer_ui.layer]['tags']
      @sprite_blending_mode_ui.blending_mode = @current_frame['blending_mode']
    end
    if @start_drag_x && @start_drag_y
      @delta_drag_x = $window.mouse_x - @start_drag_x
      @delta_drag_y = $window.mouse_y - @start_drag_y
    end
    
    if @start_shape_drag_x && @start_shape_drag_y
      @delta_shape_drag_x = $window.mouse_x - @start_shape_drag_x
      @delta_shape_drag_y = $window.mouse_y - @start_shape_drag_y
    end
  end
  
  def key_down key
    if key == 'escape' && !$window.text_input
      $window.set_state @create_previous_menu.call
      MouseTrap.release! #!!!
    end
    
    @sprite_list_ui.key_down key
    @sprite_frames_ui.key_down key
    @sprite_layer_ui.key_down key
    @sprite_tag_ui.key_down key
    @sprite_direction_switch.key_down key
    @sprite_blending_mode_ui.key_down key
    @sprite_fps_selector.key_down key
    case key
    when 'escape'
      
      
      
    when 'mouse_left'
      if MouseTrap.capture(self)
        @sprite_frames_ui.paused = true
      end
      
    when 'space'
      if $window.key_down_match? 'alt'
        @start_shape_drag_x = $window.mouse_x
        @start_shape_drag_y = $window.mouse_y
        @sprite_frames_ui.paused = true
      else
        @start_drag_x = $window.mouse_x
        @start_drag_y = $window.mouse_y
        @sprite_frames_ui.paused = true
      end
      
    when 'z'
      shape_tool = get_current_shape_tool
      if shape_tool && $window.key_down_match?('ctrl', 'meta')
        shape_tool.undo! 
        @sprite_frames_ui.paused = true
        write_selected_frames shape_tool.points, shape_tool.convexes
      end
      
    when 'c'
      shape_tool = get_current_shape_tool
      if shape_tool && $window.key_down_match?('ctrl', 'meta')
        $window.clipboard = []
        @sprite_frames_ui.selected_frames.each do |selected_frame|
          $window.clipboard << {
            'outline'  => selected_frame['shapes'][@sprite_layer_ui.layer]['outline'],
            'convexes' => selected_frame['shapes'][@sprite_layer_ui.layer]['convexes']
          }
        end
        @sprite_frames_ui.paused = true
      end
      
    when 'v'
      if $window.clipboard.kind_of?(Array) && $window.clipboard.first && $window.key_down_match?('ctrl', 'meta')
        @sprite_frames_ui.paused = true
        
        if $window.clipboard.length == @sprite_frames_ui.selected_frames.length
          @sprite_frames_ui.selected_frames.each_with_index do |frame, index|
            new_outline  = Marshal.load(Marshal.dump($window.clipboard[index]['outline']))
            new_convexes = Marshal.load(Marshal.dump($window.clipboard[index]['convexes']))
            
            outline  = frame['shapes'][@sprite_layer_ui.layer]['outline']
            convexes = frame['shapes'][@sprite_layer_ui.layer]['convexes']
            
            outline.clear
            convexes.clear
            
            outline.push *new_outline
            convexes.push *new_convexes
          end
        else
          write_selected_frames $window.clipboard.first['outline'], $window.clipboard.first['convexes']
        end
      end
      
    when 'backspace'
      @sprite_frames_ui.selected_frames.each do |frame|
        frame['shapes'][@sprite_layer_ui.layer]['outline'].clear
        frame['shapes'][@sprite_layer_ui.layer]['convexes'].clear
      end
      @sprite_frames_ui.paused = true
      
    when 's'
      puts "Saving!"
      Resources::Sprites.save_all!
    end
  end
  
  def write_selected_frames outline, convexes
    @sprite_frames_ui.selected_frames.each do |frame|
      new_outline  = Marshal.load(Marshal.dump(outline))
      new_convexes = Marshal.load(Marshal.dump(convexes))
      
      outline  = frame['shapes'][@sprite_layer_ui.layer]['outline']
      convexes = frame['shapes'][@sprite_layer_ui.layer]['convexes']
      outline.clear
      convexes.clear
      
      outline.push *new_outline
      convexes.push *new_convexes
    end
  end
  
  def key_up key
    @sprite_list_ui.key_up key
    @sprite_frames_ui.key_up key
    @sprite_layer_ui.key_up key
    @sprite_tag_ui.key_up key
    @sprite_direction_switch.key_up key
    @sprite_blending_mode_ui.key_up key
    @sprite_fps_selector.key_up key
    
    case key
    when 'mouse_left'
      shape_tool = get_current_shape_tool
      if MouseTrap.release(self) && shape_tool
        x = $window.mouse_x - @anchor_point_x
        y = $window.mouse_y - @anchor_point_y
        shape_tool.add_point x, y
        write_selected_frames shape_tool.points, shape_tool.convexes
      end
      
    when 'space'
      if @start_shape_drag_x && @start_shape_drag_y
        @sprite_frames_ui.selected_frames.each do |frame|
          
          outline  = frame['shapes'][@sprite_layer_ui.layer]['outline']
          convexes = frame['shapes'][@sprite_layer_ui.layer]['convexes']
          outline.each do |point|
            point[0] += @delta_shape_drag_x
            point[1] += @delta_shape_drag_y
          end
          
          convexes.each do |convex|
            convex.each do |point|
              point[0] += @delta_shape_drag_x
              point[1] += @delta_shape_drag_y
            end
          end
        end
        @delta_shape_drag_x = 0
        @delta_shape_drag_y = 0
        @start_shape_drag_x = nil
        @start_shape_drag_y = nil
      end
      
      if @start_drag_x && @start_drag_y
        @sprite_frames_ui.selected_frames and @sprite_frames_ui.selected_frames.each do |frame|
          frame['offset_x'] = (frame['offset_x'] + @delta_drag_x).to_i
          frame['offset_y'] = (frame['offset_y'] + @delta_drag_y).to_i
        end
        @delta_drag_x = 0
        @delta_drag_y = 0
        @start_drag_x = nil
        @start_drag_y = nil
      end
    end
  end
  
  def draw
    $window.fill 0xFF424242
        
    x = @anchor_point_x+@delta_drag_x
    y = @anchor_point_y+@delta_drag_y
    
    
    
    if @current_frame
      WindowStates::GameSession::Systems::Graphics::Sprite.draw_frame @current_frame, x, y, Z, @factor_x
      shape_tool = get_current_shape_tool
      shape_tool.draw x+@delta_shape_drag_x, y+@delta_shape_drag_y if shape_tool
    end
    color = 0xFFFF0000
    $window.draw_quad @anchor_point_x-2, @anchor_point_y-2, color,
                      @anchor_point_x+2, @anchor_point_y-2, color,
                      @anchor_point_x+2, @anchor_point_y+2, color,
                      @anchor_point_x-2, @anchor_point_y+2, color
    @sprite_layer_ui.draw
    @sprite_tag_ui.draw
    @sprite_frames_ui.draw @sprite_layer_ui.layer
    @sprite_list_ui.draw
    @sprite_direction_switch.draw
    @sprite_blending_mode_ui.draw
    @sprite_fps_selector.draw
    
    x = $window.width
    y = 1
    
    HINTS.each_with_index do |hint, index|
      @font.draw_rel hint, x, y+@font.height*index, 0, 1.0, 0.0
    end
    

  end
end