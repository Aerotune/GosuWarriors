class WindowStates::GameSession::Systems::CharacterStageCollisionSystem
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def update time
    stage = Resources::Stages['test_level']
    
    @entity_manager.each_entity_with_component :FreeMotion do |entity, free_motion|
      drawable = @entity_manager.get_component entity, :Drawable
      character = @entity_manager.get_component entity, :Character
      
      hit = false
      hit_shape_index = nil
      stage['shapes'].each_with_index do |shape, shape_index|
        shape['convexes'].each do |convex_points|
          if ConvexShapeCollision.hits_point? convex_points, drawable.x, drawable.y
            hit = true
            hit_shape_index = shape_index
          end
        end
      end
      
      if hit
        @entity_manager.remove_component entity, :FreeMotion
        WindowStates::GameSession::Systems::Commands::PathStartSet.do @entity_manager, entity, \
          'stage' => 'test_level',
          'shape_index' => hit_shape_index,
          'path_start_x' => drawable.x,
          'path_start_y' => drawable.y
        character.set_animation_state = 'land'
      end
      
    end
  end
end