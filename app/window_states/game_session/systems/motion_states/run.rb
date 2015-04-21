module WindowStates::GameSession::Systems::MotionStates::Run
  extend WindowStates::GameSession::Systems::MotionState
  
  class << self
    def set entity_manager, entity, time
      stats = character_stats entity_manager, entity
      drawable = entity_manager.get_component entity, :Drawable
    
      transition_to_speed_point_10 entity, \
        'time'              => time, 
        'speed'             => stats['run_speed']*drawable.factor_x, 
        'duration'          => stats['run_transition_time'],
        'push_beyond_ledge' => true
    
    
    end
  end
end