class SpriteTagUI  
  TAGS = %w[
    whole_body
    upper_body
    lower_body
    takes_damage
    deals_damage
    bonus_damage
    tick
    pushes
    holds
    pulls
    stuns
    special
    left
    right
    up
    down
  ]
  
  attr_accessor :tags
  
  def initialize
    @font = Resources::Fonts[:Arial12]
    @tags = []
    @width = 100
    @height = TAGS.length * @font.height
    @x = 203
    @y = 20
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
          tag = TAGS[index]
          if @tags.include? tag
            @tags.delete tag
            @on_update.call @tags if @on_update
          else
            @tags << tag
            @on_update.call @tags if @on_update
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
    
    TAGS.each_with_index do |tag, index|
      active = @tags.include? tag
      color = active ? 0xFF000000 : CloudyUi::INACTIVE_TEXT_COLOR
      @font.draw "#{active ? '(x) ' : '(  ) '}#{tag}", @x, @y+@font.height*index, 0, 1, 1, color
    end
  end
end