class WindowStates::GameSession::Systems::Graphics
  Dir[File.join(GAME_SESSION_PATH, *%w[systems graphics *.rb])].each { |file| require file }
  
  def initialize entity_manager
    @entity_manager = entity_manager
    @drawable_entities = []
    @sprite_system = WindowStates::GameSession::Systems::Graphics::Sprite.new @entity_manager
  end
  
  def update time
    sort_drawable_entities!
    @drawable_entities.each do |entity|
      @sprite_system.update entity, time if @entity_manager.get_component(entity, :Sprite)
    end
  end
  
  def draw
    @drawable_entities.each do |entity|
      @sprite_system.draw entity if @entity_manager.get_component(entity, :Sprite)
    end
  end
  
  
  private
  
  
  def sort_drawable_entities!
    drawables_store = @entity_manager.store[:Drawable]
    unless @drawables_hash == drawables_store.hash
      @drawables_hash = drawables_store.hash
      @drawable_entities.clear
      drawables = []
      @entity_manager.each_entity_with_component :Drawable do |entity, drawable|
        drawables << {
          'drawable' => drawable,
          'entity' => entity
        }
      end
      drawables.sort! { |a,b| a['drawable'].z_order <=> b['drawable'].z_order }
      @drawable_entities = drawables.map { |drawable| drawable['entity'] }
    end
  end
end