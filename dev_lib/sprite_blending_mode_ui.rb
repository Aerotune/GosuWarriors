class SpriteBlendingModeUI  
  BLENDING_MODES = [
    "BLENDING MODES",
    'normal',
    'add'
  ]
  
  attr_accessor :blending_mode
  
  def initialize
    @font = Resources::Fonts[:Arial12]
    @tags = []
    @width = 100
    @height = BLENDING_MODES.length * @font.height
    @blending_mode = 'normal'
    @x = 308
    @y = 36
  end
  
  def key_down key
    case key
    when 'mouse_left'
      MouseTrap.capture(self) if mouse_over_index
    end
  end
  
  def key_up key
    case key
    when 'mouse_left'
      if MouseTrap.release(self)
        index = mouse_over_index
        if index
          blending_mode = BLENDING_MODES[index]
          unless index == 0
            @blending_mode = blending_mode
            @on_update.call(blending_mode)
          end
        end
      end
    end
  end
  
  def on_update &block
    @on_update = block
  end
  
  def mouse_over_index
    mx = $window.mouse_x
    my = $window.mouse_y
    if mx > @x && mx < @x+@width && my > @y && my < @y+@height
      return ((my-@y)/@font.height).to_i
    else
      return nil
    end
  end
  
  def update
    
  end
  
  def draw
    CloudyUi::Window.draw $window, @x, @y, 0, @width, @height
    
    BLENDING_MODES.each_with_index do |blending_mode, index|
      if index == 0
        @font.draw "#{blending_mode}", @x, @y+@font.height*index, 0, 1, 1, 0xFF000000
      else
        active = blending_mode == @blending_mode
        color = active ? 0xFF000000 : CloudyUi::INACTIVE_TEXT_COLOR
        @font.draw "#{active ? '(x) ' : '(  ) '}#{blending_mode}", @x, @y+@font.height*index, 0, 1, 1, color
      end
    end
  end
end