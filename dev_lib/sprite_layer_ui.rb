class SpriteLayerUI
  attr_reader :layer, :layer_amount
  def initialize
    @font = Resources::Fonts[:Arial12]
    
    @layer = 0
    @layer_amount = 10
    @width = 50
    @height = @layer_amount * @font.height
    @x = 203
    @y = 20+12*16+5
  end
  
  def key_down key
    case key
    when 'mouse_left'
      MouseTrap.capture(self) if mouse_over_layer
    when '0'..'9'
      @layer = key.to_i
    end
  end
  
  def key_up key
    case key
    when 'mouse_left'
      if MouseTrap.release(self)
        layer = mouse_over_layer
        @layer = layer if layer
      end
    end
  end
  
  def mouse_over_layer
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
    @layer_amount.times do |layer|
      active = layer == @layer
      color = active ? 0xFF000000 : CloudyUi::INACTIVE_TEXT_COLOR
      @font.draw "Layer #{layer} #{active ? ' <' : ''}", @x, @y+@font.height*layer, 0, 1, 1, color
    end
  end
end