class WindowStates::GameSession::Systems::CharacterAnimationState
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def transition_to_speed_point_10 entity, time, speed_point_10, duration
    path_start_delta_distance = WindowStates::GameSession::SystemHelpers::PathMotion.pmc_distance(@entity_manager, entity, time)
    
    pmc_options = {
      'id'                   => Identifier.create_id,
      'start_time'           => time,
      'distance'             => 0,
      'start_speed_point_10' => WindowStates::GameSession::SystemHelpers::PathMotion.speed_point_10(@entity_manager, entity, time),
      'end_speed_point_10'   => speed_point_10,
      'duration'             => duration
    }
    
    @entity_manager.remove_component entity, :PathMotionContinuous
    WindowStates::GameSession::Systems::PathMotionContinuousAdd.do @entity_manager, entity, pmc_options
    
    WindowStates::GameSession::Systems::Commands::PathStartAddDistance.do @entity_manager, entity, 'distance' => path_start_delta_distance
  end
  
  def tween entity, time, distance, duration
    #!!!
    # add pmt distance to path_start.distance when you despawn pmt
    pmt_distance = WindowStates::GameSession::SystemHelpers::PathMotion.pmt_distance(@entity_manager, entity, time)
    WindowStates::GameSession::Systems::Commands::PathStartAddDistance.do @entity_manager, entity, 'distance' => pmt_distance
    @entity_manager.remove_component entity, :PathMotionTween
    
    WindowStates::GameSession::Systems::PathMotionTweenAdd.do @entity_manager, entity, \
      'start_time'           => time,
      'distance'             => distance,
      'duration'             => duration
  end
  
  def free_motion entity, time, options
    drawable = @entity_manager.get_component entity, :Drawable
    @entity_manager.remove_component entity, :PathStart
    @entity_manager.remove_component entity, :PathMotionContinuous
    @entity_manager.remove_component entity, :PathMotionTween
    
    component = WindowStates::GameSession::Components::FreeMotion.new \
      'start_time'              => time,
      'start_x'                 => drawable.x,
      'start_y'                 => drawable.y,
      'start_speed_y_point_10'  => options['start_speed_y_point_10'],
      'start_speed_x_point_10'  => options['start_speed_x_point_10'],
      'end_speed_y_point_10'    => options['end_speed_y_point_10'],
      'end_speed_x_point_10'    => options['end_speed_x_point_10'],
      'transition_time_y'       => options['transition_time_y'],      
      'transition_time_x'       => options['transition_time_x']
    
    @entity_manager.add_component entity, component
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