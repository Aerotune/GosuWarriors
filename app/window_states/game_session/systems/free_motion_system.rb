class WindowStates::GameSession::Systems::FreeMotion
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def update time
    stage = Resources::Stages['test_level']
    
    @entity_manager.each_entity_with_component :FreeMotion do |entity, free_motion|
      drawable = @entity_manager.get_component entity, :Drawable
      
      if drawable
        drawable.x, drawable.y = WindowStates::GameSession::SystemHelpers::FreeMotion.position(@entity_manager, entity, time)
      end
    end
  end
end