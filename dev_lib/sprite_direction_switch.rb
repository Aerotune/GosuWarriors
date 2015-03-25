class SpriteDirectionSwitch
  attr_accessor :sprite, :direction
  
  def initialize
    @x = 203+100+3
    @y = 20
    @width = 75
    @height = 14
    @font = Resources::Fonts[:Arial12]
    @direction = 1
  end
  
  def update
    
  end
  
  def key_down key
    case key
    when 'mouse_left'
      MouseTrap.capture self if mouse_hover?
    end
  end
  
  def key_up key
    case key
    when 'mouse_left'
      if MouseTrap.release(self) && mouse_hover?
        @sprite['face_direction'] = -@sprite['face_direction']
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
    CloudyUi::Button.draw @x, @y, 0, @width, @height, state
    return unless @sprite
    @font.draw "#{@sprite['face_direction'] == 1 ? ' >> Face right' : ' << Face left'}", @x, @y, 0, 1, 1, CloudyUi::NEUTRAL_TEXT_COLOR
  end
end