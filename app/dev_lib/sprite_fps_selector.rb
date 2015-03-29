class SpriteFPSSelector  
  def initialize
    @x = 203+100+3+77
    @y = 20
    @width = 26
    @height = 14
    @font = Resources::Fonts[:Arial12]
    @text_input = Gosu::TextInput.new
    def @text_input.filter(text_in)
      text_in.gsub(/[^0-9]/, '')
    end
  end
  
  def sprite=sprite
    @sprite = sprite
    @text_input.text = "#{sprite['fps']}"
  end
  
  def update
    
  end
  
  def key_down key
    case key
    when 'mouse_left'
      MouseTrap.capture self if @sprite && mouse_hover?
    when 'return'
      if @sprite && $window.text_input == @text_input 
        fps = @text_input.text.to_i
        @sprite['fps'] = fps if fps > 0
        @text_input.text = @sprite['fps'].to_s
        $window.text_input = nil
      end
    when 'escape'
      if @sprite && $window.text_input == @text_input 
        @text_input.text = @sprite['fps'].to_s
        $window.text_input = nil
      end
    end
  end
  
  def key_up key
    case key
    when 'mouse_left'
      if MouseTrap.release(self) && mouse_hover?
        $window.text_input = @text_input
        @text = @text_input.text
      end
    end
  end
  
  def mouse_hover?
    $window.mouse_x > @x && $window.mouse_y > @y && $window.mouse_x < @x+@width  && $window.mouse_y < @y+@height
  end
  
  def draw
    state = :normal
    if mouse_hover?
      if MouseTrap.captured?(self)
        #state = :active
        state = :hover
      else
        state = :hover
      end
    end
    CloudyUi::DynamicField.draw $window, @x+1, @y+2, 0, @width-1, @height-4
    #CloudyUi::Button.draw @x, @y, 0, @width, @height, state
    return unless @text_input
    active = $window.text_input == @text_input
    color = active ? 0xFF000000 : CloudyUi::NEUTRAL_TEXT_COLOR
    @font.draw "#{@text_input.text}", @x, @y, 0, 1, 1, color
    
    if active
      caret_color = 0xAA550000
      caret_x = @x + @font.text_width(@text_input.text[0...@text_input.caret_pos])
      $window.draw_line caret_x, @y, caret_color, caret_x, @y+@font.height, caret_color
    end
  end
end