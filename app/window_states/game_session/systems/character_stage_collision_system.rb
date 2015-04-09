class WindowStates::GameSession::Systems::CharacterStageCollisionSystem
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def update time
    stage = Resources::Stages['test_level']
    
    @entity_manager.each_entity_with_component :FreeMotionX do |entity, free_motion_x|
      drawable = @entity_manager.get_component entity, :Drawable
      character = @entity_manager.get_component entity, :Character
      
      x = drawable.x
      y = drawable.y
      speed_x_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_x_point_10(@entity_manager, entity, time)
      speed_y_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_y_point_10(@entity_manager, entity, time)
      
      next unless speed_y_point_10 > 0
      
      prev_x = WindowStates::GameSession::SystemHelpers::FreeMotion.x(@entity_manager, entity, time-1)
      prev_y = WindowStates::GameSession::SystemHelpers::FreeMotion.y(@entity_manager, entity, time-1)
      feet_hit_shape = [
        [prev_x-6, prev_y],
        [prev_x+6, prev_y],
        [x+3, y],
        [x-3, y]
      ]
      
      hit = false
      hit_shape_index = nil
      stage['shapes'].each_with_index do |shape, shape_index|
        shape['convexes'].each do |convex_points|
          if ConvexShapeCollision.overlap? convex_points, feet_hit_shape
            hit = true
            hit_shape_index = shape_index
          end
        end
      end
      
      if hit
        @entity_manager.remove_component entity, :FreeMotionX
        @entity_manager.remove_component entity, :FreeMotionY
                
        WindowStates::GameSession::Systems::Commands::PathStartSet.do @entity_manager, entity, \
          'stage' => 'test_level',
          'shape_index' => hit_shape_index,
          'x' => (x+prev_x)/2,
          'y' => (y+prev_y)/2,
          'surface_only' => true
        
        @entity_manager.add_component entity, WindowStates::GameSession::Components::PathMotionContinuous.new(
          'id'                   => 0,
          'start_time'           => time,
          'start_speed_point_10' => speed_x_point_10,
          'end_speed_point_10'   => 0,
          'duration'             => 60
        )
        
        character.set_animation_state = 'land'
      end
      
    end
  end
end