module WindowStates::GameSession::Factories::Character
  class << self
    def build entity_manager, character_animation_states_system, character_type, control_type, set_animation_state="idle"
      entity = entity_manager.create_entity
      
      character = WindowStates::GameSession::Components::Character.new(
        'type' => character_type,
        'set_animation_state' => set_animation_state, 
        'control_type' => control_type
      )
      controls  = WindowStates::GameSession::Components::Controls.new(
        'pressed' => [],
        'released' => [],
        'held' => []
      )
      drawable  = WindowStates::GameSession::Components::Drawable.new(
        'x' => 400,
        'y' => 400, 
        'z_order' => ZOrder::CHARACTER,
        'factor_x' => 1
      )
      path_start = WindowStates::GameSession::Components::PathStart.new 'distance' => 400
      path_motion_continuous = WindowStates::GameSession::Components::PathMotionContinuous.new(
        'start_time'           => 0,
        'distance'             => 0,
        'start_speed_point_10' => 9000,
        'end_speed_point_10'   => 0,
        'duration'             => 60*3
        
      )
      
      entity_manager.add_component entity, character
      entity_manager.add_component entity, controls
      entity_manager.add_component entity, drawable
      entity_manager.add_component entity, path_start
      entity_manager.add_component entity, path_motion_continuous
            
      return entity
    end
  end
end