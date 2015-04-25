module Systems::MotionStates::Run
  extend Systems::MotionState
  
  class << self
    def set game_session, entity, time
      entity_manager = game_session.entity_manager
      stats = character_stats entity_manager, entity
      drawable = entity_manager.get_component entity, :Drawable
    
      transition_to_speed_point_10 entity_manager, entity, time, \
        'speed_point_10'    => stats['run_speed']*drawable.factor_x, 
        'duration'          => stats['run_transition_time'],
        'push_beyond_ledge' => true
    
    
    end
    
    def control_down game_session, entity, time, control
      character = game_session.entity_manager.get_component entity, :Character
      drawable = game_session.entity_manager.get_component entity, :Drawable
      
      if control == 'right' && drawable.factor_x == 1
        stats = SystemHelpers::Character.stats(game_session, entity)
        speed           = stats['run_speed']*drawable.factor_x
        transition_time = stats['run_transition_time']
        transition_to_speed_point_10 entity, time, speed, transition_time, 'push_beyond_ledge' => true
        character.queued_animation_state = 'run'
      end
    
      if control == 'left' && drawable.factor_x == -1
        stats = SystemHelpers::Character.stats(game_session, entity)
        speed           = stats['run_speed']*drawable.factor_x
        transition_time = stats['run_transition_time']
        transition_to_speed_point_10 entity, time, speed, transition_time, 'push_beyond_ledge' => true
        character.queued_animation_state = 'run'
      end
    end
    
    def control_up game_session, entity, time, control
      character = game_session.entity_manager.get_component entity, :Character
      drawable  = game_session.entity_manager.get_component entity, :Drawable
    
      if control == 'right' && drawable.factor_x == 1
        stats = SystemHelpers::Character.stats(game_session, entity)
        speed           = 0
        transition_time = stats['stop_transition_time']
        transition_to_speed_point_10 entity, time, speed, transition_time, 'push_beyond_ledge' => true
      end
    
      if control == 'left' && drawable.factor_x == -1
        stats = SystemHelpers::Character.stats(game_session, entity)
        speed           = 0
        transition_time = stats['stop_transition_time']
        transition_to_speed_point_10 entity, time, speed, transition_time, 'push_beyond_ledge' => true
      end
    end
  end
end