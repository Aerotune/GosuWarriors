class WindowStates::GameSession::Systems::CharacterAnimationState
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def transition_to_speed_point_10 entity, time, speed_point_10, duration
    
    path_start = @entity_manager.get_component entity, :PathStart
    
    set_pmc_command = WindowStates::GameSession::Commands::SetPathMotionContinuous.new @entity_manager, entity, {
      'start_time'           => time,
      'distance'             => 0,
      'start_speed_point_10' => WindowStates::GameSession::SystemHelpers::PathMotion.speed_point_10(@entity_manager, entity, time),
      'end_speed_point_10'   => speed_point_10,
      'duration'             => duration
    }, {
      'distance' => path_start.distance + WindowStates::GameSession::SystemHelpers::PathMotion.pmc_distance(@entity_manager, entity, time)
    }
    set_pmc_command.do!
  end
  
  def tween entity, time, distance, duration
    #!!!
    # add pmt distance to path_start.distance when you despawn pmt
    path_start = @entity_manager.get_component entity, :PathStart
    path_start.distance += WindowStates::GameSession::SystemHelpers::PathMotion.pmt_distance(@entity_manager, entity, time)
    
    set_pmt_command = WindowStates::GameSession::Commands::SetPathMotionTween.new @entity_manager, entity, {
      'start_time'           => time,
      'distance'             => distance,
      'duration'             => duration
    }
    set_pmt_command.do!
  end
  
  def stats entity
    character = @entity_manager.get_component entity, :Character
    Resources::CharacterStats[character.type]
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