module Resources::Fonts
  class << self
    def require!
      load! unless @fonts
    end
    
    def load!
      @fonts = {
        Arial8: Gosu::Font.new($window, 'Arial', 8),
        Arial12: Gosu::Font.new($window, 'Arial', 12),
        Arial13: Gosu::Font.new($window, 'Arial', 13),
        Arial16: Gosu::Font.new($window, 'Arial', 16),
        Arial24: Gosu::Font.new($window, 'Arial', 24),
        Arial32: Gosu::Font.new($window, 'Arial', 32)
      }
    end
  
    def [] font_id
      @fonts[font_id]
    end
  end
end