require_relative 'menu'

class Menu::Item
  TEXT_COLOR = 0xFFC0C0C0
  TEXT_HOVER_COLOR = 0xFFFFFFFF
  
  def initialize text, text_size, x, y, z, &on_click
    @text = text
    @on_click = on_click
    case text_size
    when 13
      @font = Resources::Fonts[:Arial13]
    when 16
      @font = Resources::Fonts[:Arial16]
    when 24
      @font = Resources::Fonts[:Arial24]
    else
      raise "Unable to use text size #{text_size.inspect} for menu"
    end
    
    @x = x
    @y = y
    @z = z
    @color = TEXT_COLOR
  end
  
  def update
    if hit_point? $window.mouse_x, $window.mouse_y
      @color = TEXT_HOVER_COLOR
    else
      @color = TEXT_COLOR
    end
  end
  
  def key_up key
    case key
    when 'mouse_left'
      if hit_point? $window.mouse_x, $window.mouse_y
        @on_click.call
      end
    end
  end
  
  def draw
    @font.draw_rel @text, @x, @y, @z, 0.5, 0.0, 1, 1, @color
  end
  
  def width
    @font.text_width(@text)
  end
  
  def height
    @font.height
  end
  
  def hit_point? x, y
    x > @x-width/2  && x < @x+width/2 &&
    y > @y          && y < @y+height
  end
end