class NeutralCursor
  class << self
    def load_images window, load_path=File.join(WINDOW_STATES_PATH, 'dev_level_editor', 'neutral_cursor', 'source')
      @window = window
      @states = {
        normal:  [4,  5,  Gosu::Image.new( window, File.join(load_path, 'left_ptr.png'))],
        pointer: [8,  4,  Gosu::Image.new( window, File.join(load_path, 'hand1.png'   ))],
        grab:    [11, 10, Gosu::Image.new( window, File.join(load_path, 'fleur.png'   ))]
      }
      set_state :normal
    end
    
    def set_state name
      @state = @states[name]
    end

    def draw x, y, z
      $window.cursor_visible = false
      if x > 0 && x < @window.width && y > 0 && y < @window.height
        @state[2].draw x-@state[0], y-@state[1], z
      end
    end
  end
end