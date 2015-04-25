class Systems::FreeMotion
  def initialize game_session
    @game_session   = game_session
    @entity_manager = game_session.entity_manager
  end
  
  def update time
    stage = @game_session.stage
    
    @entity_manager.each_entity_with_component :FreeMotionX do |entity, free_motion_x|
      drawable = @entity_manager.get_component entity, :Drawable
      
      if drawable
        drawable.prev_x = drawable.x
        drawable.x = SystemHelpers::FreeMotion.x(@entity_manager, entity, time)
      end
    end
    
    @entity_manager.each_entity_with_component :FreeMotionY do |entity, free_motion_Y|
      drawable = @entity_manager.get_component entity, :Drawable
      
      if drawable
        drawable.prev_y = drawable.y
        drawable.y = SystemHelpers::FreeMotion.y(@entity_manager, entity, time)
      end
    end
  end
end