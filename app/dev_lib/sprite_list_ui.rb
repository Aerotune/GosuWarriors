class SpriteListUI
  def initialize list
    @list = list
    @keys = @list.keys
    @selected_key_index = nil
    @font = Resources::Fonts[:Arial12]
    @line_height = @font.height
    @width = 200
  end
  
  def key_down key
    case key
    when 'tab'
      if $window.key_down_match? "shift"#button_down?(Gosu::KbLeftShift) || $window.button_down?(Gosu::KbRightShift)
        @selected_key_index ||= 0
        @selected_key_index -= 1
        @selected_key_index %= @keys.length
        call_on_click
      else
        @selected_key_index ||= -1
        @selected_key_index += 1
        @selected_key_index %= @keys.length
        call_on_click
      end
    when 'mouse_left'
      if $window.mouse_x < @width
        MouseTrap.capture self
      end
    end
  end
  
  def key_up key
    case key
    when 'mouse_left'
      if MouseTrap.release self
        selected_key_index = ($window.mouse_y/@line_height).to_i
        if @keys[selected_key_index]
          @selected_key_index = selected_key_index
          call_on_click
        end
      end
    end
  end
  
  def on_click &block
    @on_click = block
  end
  
  def draw
    CloudyUi::Window.draw $window, 2, 2, 0, @width-4, $window.height-4
    @keys.each_with_index do |element, index|
      text = element.last#join(File::SEPARATOR)
      
      if @selected_key_index == index
        color = 0xFF000000
      else
        color = CloudyUi::INACTIVE_TEXT_COLOR
      end
      $window.clip_to 0, 0, @width, $window.height do
        @font.draw text, 2, index*@line_height, 0, 1, 1, color
      end
    end
  end
  
  private
  
  def call_on_click
    @on_click.call @list[@keys[@selected_key_index]]
  end
end