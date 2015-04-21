module WindowStates::GameSession::Systems::MotionStates::Stand
  extend WindowStates::GameSession::Systems::MotionState
  
  class << self
    def set entity_manager, entity, time
      stats = character_stats entity_manager, entity
      
      transition_to_speed_point_10 entity_manager, entity, time,
        'speed_point_10'    => 0,
        'duration'          => stats['stop_transition_time'],
        'push_beyond_ledge' => true
    
    
    end
  end
end