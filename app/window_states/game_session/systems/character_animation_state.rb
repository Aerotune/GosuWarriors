class WindowStates::GameSession::Systems::CharacterAnimationState
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def transition_to_speed_point_10 entity, time, speed_point_10, duration
    set_pmc_command = WindowStates::GameSession::Commands::SetPathMotionContinuous.new @entity_manager, entity, {
      'start_time'           => time,
      'distance'             => 0,
      'start_speed_point_10' => WindowStates::GameSession::SystemHelpers::PathMotion.speed_point_10(@entity_manager, entity, time),
      'end_speed_point_10'   => speed_point_10,
      'duration'             => duration
    }, {
      'distance' => WindowStates::GameSession::SystemHelpers::PathMotion.distance(@entity_manager, entity, time)
    }
    set_pmc_command.do!
  end
  
  def on_set entity, time
    
  end
  
  def on_unset entity, time
    
  end

  def control_down entity, control, time
    
  end

  def control_up entity, control, time
  
  end

  def update entity, time
  
  end
end