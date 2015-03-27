class WindowStates::GameSession::Systems::Graphics
  Dir[File.join(GAME_SESSION_PATH, *%w[systems graphics *.rb])].each { |file| require file }
  
  def initialize entity_manager
    @entity_manager = entity_manager
    @drawables = []
    @sprite_system = WindowStates::GameSession::Systems::Graphics::Sprite.new @entity_manager
  end
  
  def update time
    sort_drawables!
    @drawables.each do |drawable|
      case drawable.draw_component
      when WindowStates::GameSession::Components::Sprite; @sprite_system.update drawable, time if drawable.draw_component
      end
    end
  end
  
  def draw
    @drawables.each do |drawable|
      case drawable.draw_component
      when WindowStates::GameSession::Components::Sprite; @sprite_system.draw drawable if drawable.draw_component
      end
    end
  end
  
  
  private
  
  
  def sort_drawables!
    drawables_store = @entity_manager.store[:Drawable]
    unless @drawables_hash == drawables_store.hash
      @drawables_hash = drawables_store.hash
      @drawables.clear
      @entity_manager.each_entity_with_component :Drawable do |entity, drawable|
        @drawables << drawable
      end
      @drawables.sort! { |a,b| a.z_order <=> b.z_order }
    end
  end
end