class WindowStates::DevCharacterEditor < WindowState
  TRANSITION_RANGE = 1..120
  MOVESPEED_RANGE  = 8_000..20_000
  @@stat_types = {
    'run_speed'            => { range: MOVESPEED_RANGE  },
    'run_transition_time'  => { range: TRANSITION_RANGE },
    'stop_transition_time' => { range: TRANSITION_RANGE }
  }
  @@stat_types.default_proc = ->(h, k) { h[k] = Hash.new }
  
  class Row
    attr_reader :edit_key
    
    def initialize x, y, stats, keys, font
      @x     = x
      @y     = y
      @margin= 10
      @stats = stats
      @keys  = keys
      @font  = font
      @row_width = [
        @keys.map { |key| @font.text_width(key.to_s) }.max, 
        80
      ]
      @text_input = Gosu::TextInput.new
    end
    
    def edit key
      return if @edit_key == key
      enter_edit
      @edit_key = key
      @text_input.text = value_for_key(key)
      $window.text_input = @text_input
    end
    
    def cancel_edit
      @edit_key = nil
      $window.text_input = nil
    end
    
    def enter_edit
      if @edit_key
        result = @text_input.text.to_i
        @stats[@edit_key] = result if result > 0
      end
      
      @edit_key = nil
      $window.text_input = nil
    end
    
    def point_over_key x, y
      if x > row_x_2 && x < row_x_3
        index = column_index(y)
        return @keys[index] if index
        return nil
      end
    end
    
    def move_caret x, y
      if $window.text_input == @text_input
        width = 0
        index = 0
        text = ''
        @text_input.text.each_char do |char|
          text_right = @font.text_width(text)
          text_left  = ((x-row_x_2)-(@font.height/3))
          break if text_right > text_left
          text << char
        end
        @text_input.caret_pos = text.length
        @text_input.selection_start = @text_input.caret_pos
      end
    end
    
    def prev!
      if @edit_key
        index = @keys.index(@edit_key)
        enter_edit
        edit @keys[(index-1)]
      else
        edit @keys.last
      end
    end
    
    def next!
      if @edit_key
        index = @keys.index(@edit_key)
        enter_edit
        edit @keys[(index+1) % @keys.length]
      else
        edit @keys.first
      end
    end
    
    def row_x_1
      @x + @margin*1
    end
    
    def row_x_2
      @x + @margin*2 + @row_width[0]
    end
    
    def row_x_3
      @x + @margin*3 + @row_width[0] + @row_width[1]
    end
    
    def column_y index
      @margin + @font.height * index
    end
    
    def column_index y
      index = (y - @margin) / @font.height
      return index if index >= 0
      return index if index < @keys.length
      return nil
    end
    
    def value_for_key key
      @stats[key].to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1_")
    end
    
    def draw
      index = 0
      @keys.each do |key|
        val = value_for_key(key)
        column_y = self.column_y(index)
        
        color = CloudyUi::INACTIVE_TEXT_COLOR 
        @font.draw "#{key}", row_x_1, column_y, 0, 1, 1, color
        CloudyUi::DynamicField.draw $window, row_x_2, column_y+2, 0, @row_width[1], @font.height-1
        
        if @edit_key == key
          @font.draw @text_input.text, row_x_2, column_y, 0, 1, 1, 0xFF000000
          caret_x = row_x_2 + @font.text_width(val[0...@text_input.caret_pos])
          caret_y = column_y
          caret_color = 0xAA550000
          $window.draw_line caret_x, caret_y, caret_color, caret_x, caret_y + @font.height, caret_color
        else
          @font.draw val, row_x_2, column_y, 0, 1, 1, color
        end
        
        index += 1
      end  
    end
  end
  
  def initialize character_name
    Resources::CharacterStats.require!
    Resources::Fonts.require!
    CloudyUi.load_images $window
    @stats = Resources::CharacterStats.stats[character_name]
    @keys  = @stats.keys.sort
    @font  = Resources::Fonts[:Arial12]
    
    @row   = Row.new 0, 0, @stats, @keys, @font
  end
  
  def key_down key
    case key
    when 'escape'
      MouseTrap.release!
      $window.set_state WindowStates::DevCharacterList.new unless @row.edit_key
      @row.cancel_edit
    when 'return'
      @row.enter_edit
    when 'tab'
      $window.key_down_match?('shift') ? @row.prev! : @row.next!
    when 'down'
      @row.next!
    when 'up'
      @row.prev!
    when 'mouse_left'
      if MouseTrap.capture(self)
        @row.move_caret $window.mouse_x, $window.mouse_y
      end
    end
  end
  
  def key_up key
    case key
    when 'mouse_left'
      key = @row.point_over_key($window.mouse_x, $window.mouse_y)
      if MouseTrap.release(self) && key
        @row.edit(key)
      end
    end
  end
  
  def update
    
  end
  
  def draw
    CloudyUi::Window.draw $window, 0, 0, 0, $window.width, $window.height
    @row.draw  
  end
end