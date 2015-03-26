module DevLoader
  class << self
    attr_accessor :loaded
    
    def loaded?
      @loaded
    end
    
    def require!
      load! unless @loaded
    end
    
    def load!
      require_rubies!
      CloudyUi::Button.load_images $window, File.join(DEV_LIB_PATH, 'cloudy_ui', 'images')
      @loaded = true
    end
    
    def require_rubies!
      return if @loaded_rubies
      @loaded_rubies = true
      Dir[File.join(DEV_LIB_PATH, '*.rb')].each { |file| require file }
    end
  end
end