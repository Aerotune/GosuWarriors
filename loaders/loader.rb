module Loader
  class << self
    attr_accessor :loaded
    
    def loaded?
      @loaded
    end
    
    def load!
      require_rubies!
      Resources::Fonts.load!
      Resources::Sprites.load!
      @loaded = true
    end
  
    def require!
      require_rubies!
      Resources::Fonts.require!
      Resources::Sprites.require!
      @loaded = true
    end
  
    def require_fonts!
      require File.join(GAME_LIB_PATH, 'resources.rb')
      Resources::Fonts.require!
    end
  
    def require_rubies!
      return if @loaded_rubies
      @loaded_rubies = true
    
      Dir[File.join(GAME_LIB_PATH,         '*.rb')].each { |file| require file }
      Dir[File.join(GAME_SESSION_PATH,     '*.rb')].each { |file| require file }
    end
  end
end