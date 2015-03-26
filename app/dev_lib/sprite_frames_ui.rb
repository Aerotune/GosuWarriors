class SpriteFramesUI
  attr_reader :current_frame, :selected_frames
  attr_accessor :paused
  attr_accessor :frame_delta, :frames, :current_frame_index, :selection_range
  
  def initialize
    @x = 200
    @y = 0
    @height = 17
    @font = Resources::Fonts[:Arial8]
    @selected_frame_image = Gosu::Image.new $window, File.join(DEV_LIB_PATH, 'sprite_frames_ui', 'selected_frame.png'), true
    @frame_image          = Gosu::Image.new $window, File.join(DEV_LIB_PATH, 'sprite_frames_ui', 'frame.png'), true
    @head_image           = Gosu::Image.new $window, File.join(DEV_LIB_PATH, 'sprite_frames_ui', 'head.png'), true
    @colors = [
      Gosu::Color.new(0xFFFFFFFF),
      Gosu::Color.new(0xFFFF8888),
      Gosu::Color.new(0xFF88FF88),
      Gosu::Color.new(0xFF8888FF)
    ]
    @selection_range = 0..0
    @current_frame_index = 0
    @frame_delta = 0.5
    @selected_frames = []
  end
  
  def selection_range=selection_range
    @selection_range = selection_range
    update_current_frames
  end
  
  def toggle_pause
    @paused = !@paused
    @current_frame_index = @current_frame_index.to_i+0.5
  end  
  
  def move delta_frames
    @current_frame_index += delta_frames
    @current_frame_index %= @frames.length
    select_current_frame
    @paused = true
    @current_frame_index = @current_frame_index.to_i+0.5
    update_current_frames
  end
  
  def select_current_frame
    @selection_range = (@current_frame_index.to_i..@current_frame_index.to_i) if @selection_range.size == 1
  end
  
  def key_down key
    case key
    when 'p'; toggle_pause
    when 'right'; move 1
    when 'left';  move -1
    when 'mouse_left'
      if @frames
        if (@y .. @y+@height) === $window.mouse_y
          start_selection
        end
      end
    #when '5'; @frame_delta = 0.05
    #when '4'; @frame_delta = 0.1
    #when '3'; @frame_delta = 0.2
    #when '2'; @frame_delta = 0.35
    #when '1'; @frame_delta = 0.5
    end    
  end
  
  def key_up key
    case key
    when 'mouse_left'
      if MouseTrap.release self
        update_selection
      end
    end
  end
  
  def start_selection
    frame_index = mouse_over_frame
    if @frames[frame_index] 
      if MouseTrap.capture self
        @selection_range_start = frame_index
        @current_frame_index = frame_index+0.5
      end
    end
  end
  
  def update_selection
    frame_index = mouse_over_frame
    @selection_range_stop = frame_index if @frames[frame_index]
    if @selection_range_start && @selection_range_stop
      selection_frames = [@selection_range_start.to_i, @selection_range_stop.to_i]
      @selection_range = selection_frames.min..selection_frames.max
      update_current_frames
    end
  end
  
  def update
    if @frames && @frames.length > 0
      @current_frame_index += @frame_delta unless @paused
      @current_frame_index %= @frames.length
      select_current_frame
      update_current_frames
      
    end
    
    if MouseTrap.captured? self
      update_selection
    end
  end
  
  def update_current_frames
    @selected_frames = @frames[@selection_range]
    @current_frame   = @frames[@current_frame_index]
  end
  
  def mouse_over_frame
    (($window.mouse_x-@x) / 9).to_i
  end
    
  def draw shape_layer_index
    if @frames      
      $window.translate @x, @y do
        
        @frames.each_with_index do |frame, index|
          match = frame['sheet'].match(FILE_PART_PATTERN)
          frame_image = @selection_range === index ? @selected_frame_image : @frame_image
          if match
            part = match['part_number'].to_i
            color = @colors[part % @colors.length]
            draw_frame_image frame, index, frame_image, color, shape_layer_index
          else
            color = @colors.first
            draw_frame_image frame, index, frame_image, color, shape_layer_index
          end
        end
        
        @head_image.draw (@current_frame_index*9-4).to_i, 0, 0
      end
      
    end
  end
  
  def draw_frame_image frame, index, frame_image, color, shape_layer_index
    factor_y = 1.0
    shape_data = frame['shapes'][shape_layer_index]
    if shape_data['outline'].length > 0 && shape_data['convexes'].empty?
      color.alpha = 160
      factor_y = 0.9
    else
      color.alpha = 255
    end
    
    frame_image.draw index*9, 0, 0, 1, factor_y, color
    y = (index % 4) * 3
    @font.draw "#{index}", index*9+1, y, 0, 1, 1, 0xF0000000
  end
end