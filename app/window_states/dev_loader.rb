class WindowStates::DevLoader < WindowState
  attr_accessor :loaded
  
  def initialize require_sprites=true, &after_load
    @after_load = after_load
    @drawn = false
    @require_sprites = require_sprites
    @loader_loaded = false
    Loader.require_fonts!
  end
  
  def update
    return unless @drawn
    
    if loaded?
      @after_load.call
    else
      if @require_sprites
        Loader.require!
      else
        Loader.require_rubies!
        Loader.require_fonts!
        @loader_loaded = true
      end
      DevLoader.require!
      @after_load
    end
  end
  
  def on_set
    @after_load.call if loaded?
  end
  
  def loaded?
    (@loader_loaded || Loader.loaded?) && DevLoader.loaded?
  end
  
  def draw
    x = $window.width/2
    y = $window.height/2
    rel_x = 0.5
    rel_y = 0.5
    Resources::Fonts[:Arial32].draw_rel "Loading...", x, y, Z, rel_x, rel_y, 1, 1, 0xFF9eb5ce
    @drawn = true
  end
end