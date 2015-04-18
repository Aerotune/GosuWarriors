class WindowStates::GameSession::Systems::CharacterAnimationState
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def float_speed entity, time, factor_x, speed=nil
    speed_x_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_x_point_10 @entity_manager, entity, time
    _stats = stats(entity)
    speed ||= _stats['run_speed']
    free_motion_x entity, time, \
      'start_speed_point_10' => speed_x_point_10,
      'end_speed_point_10' => speed*factor_x,
      'transition_time' => 5_0
  end
  
  def transition_to_speed_point_10 entity, time, speed_point_10, duration, options={}
    #change explicit
    path_start_delta_distance = WindowStates::GameSession::SystemHelpers::PathMotion.pmc_distance(@entity_manager, entity, time)
    
    pmc_options = {
      'id'                   => Identifier.create_id,
      'start_time'           => time,
      'distance'             => 0,
      'start_speed_point_10' => WindowStates::GameSession::SystemHelpers::PathMotion.speed_point_10(@entity_manager, entity, time),
      'end_speed_point_10'   => speed_point_10,
      'duration'             => duration,
      'push_beyond_ledge'    => options['push_beyond_ledge']
    }
    
    @entity_manager.remove_component entity, :PathMotionContinuous
    WindowStates::GameSession::Systems::PathMotionContinuousAdd.do @entity_manager, entity, pmc_options
    
    if path_start_delta_distance != 0
      WindowStates::GameSession::Systems::Commands::PathStartAddDistance.do @entity_manager, entity, 'distance' => path_start_delta_distance
    end
  end
  
  def tween entity, time, distance, duration, options={}
    #!!!
    # add pmt distance to path_start.distance when you despawn pmt
    #change explicit
    pmt_distance = WindowStates::GameSession::SystemHelpers::PathMotion.pmt_distance(@entity_manager, entity, time)
    WindowStates::GameSession::Systems::Commands::PathStartAddDistance.do @entity_manager, entity, 'distance' => pmt_distance
    @entity_manager.remove_component entity, :PathMotionTween
    
    WindowStates::GameSession::Systems::PathMotionTweenAdd.do @entity_manager, entity, \
      'start_time'           => time,
      'distance'             => distance,
      'duration'             => duration,
      'push_beyond_ledge'    => options['push_beyond_ledge']
  end
  
  def set_free_motion entity, time, x, y    
    #speed_x_point_10 = WindowStates::GameSession::SystemHelpers::PathMotion.speed_point_10 @entity_manager, entity, 0
    #change explicit
    free_motion_x = WindowStates::GameSession::Components::FreeMotionX.new \
      'start_time'            => time,
      'start_x'               => x,
      'start_speed_point_10'  => 0,
      'end_speed_point_10'    => 0,
      'transition_time'       => 10
        
    free_motion_y = WindowStates::GameSession::Components::FreeMotionY.new \
      'start_time'            => time,
      'start_y'               => y,
      'start_speed_point_10'  => 0,
      'end_speed_point_10'    => 0,
      'transition_time'       => 10
    
    @entity_manager.add_component entity, free_motion_x
    @entity_manager.add_component entity, free_motion_y
    
    @entity_manager.remove_component entity, :PathStart
    @entity_manager.remove_component entity, :PathMotionContinuous
    @entity_manager.remove_component entity, :PathMotionTween
  end
  
  def free_motion_x entity, time, options
    return unless @entity_manager.get_component(entity, :FreeMotionX)
    #change explicit
    drawable = @entity_manager.get_component entity, :Drawable
    @entity_manager.remove_component entity, :PathStart
    @entity_manager.remove_component entity, :PathMotionContinuous
    @entity_manager.remove_component entity, :PathMotionTween
    @entity_manager.remove_component entity, :FreeMotionX
    
    component = WindowStates::GameSession::Components::FreeMotionX.new \
      'start_time'            => time,
      'start_x'               => drawable.x,
      'start_speed_point_10'  => options['start_speed_point_10'],
      'end_speed_point_10'    => options['end_speed_point_10'],
      'transition_time'       => options['transition_time'],
      'easer'                 => options['easer']
    
    @entity_manager.add_component entity, component
  end
  
  def free_motion_y entity, time, options
    return unless @entity_manager.get_component(entity, :FreeMotionY)
    #change explicit
    drawable = @entity_manager.get_component entity, :Drawable
    @entity_manager.remove_component entity, :PathStart
    @entity_manager.remove_component entity, :PathMotionContinuous
    @entity_manager.remove_component entity, :PathMotionTween
    @entity_manager.remove_component entity, :FreeMotionY
    
    component = WindowStates::GameSession::Components::FreeMotionY.new \
      'start_time'            => time,
      'start_y'               => drawable.y,
      'start_speed_point_10'  => options['start_speed_point_10'],
      'end_speed_point_10'    => options['end_speed_point_10'],
      'transition_time'       => options['transition_time'],
      'easer'                 => options['easer']
    
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