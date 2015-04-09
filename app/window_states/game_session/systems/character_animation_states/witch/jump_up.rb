WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    character.queued_animation_state = 'jump_down'
    WindowStates::GameSession::Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
    set_free_motion entity
    #_stats = stats(entity)
    #speed           = 0
    #transition_time = _stats['stop_transition_time']*2
    #transition_to_speed_point_10 entity, time, speed, transition_time    
  end
  
  JUMP_SPEED_POINT_10 = -29_500
  FALL_SPEED_POINT_10 = 29_500
  TRANSITION_TIME_Y   = 45
  
  def control_down entity, control, time
    sprite = @entity_manager.get_component entity, :Sprite
    return unless sprite.index > 4
      
    case control
    when 'left'
      float_speed entity, time, -1
    when 'right'
      float_speed entity, time, 1
    end
  end
  
  def control_up entity, control, time
    sprite = @entity_manager.get_component entity, :Sprite
    return unless sprite.index > 4
    
    controls = @entity_manager.get_component entity, :Controls
    case control
    when 'right'
      if controls.held.detect { |control| control == 'left' }
        float_speed entity, time, -1
      else
        float_speed entity, time, 0
      end
    when 'left'
      if controls.held.detect { |control| control == 'right' }
        float_speed entity, time, 1
      else
        float_speed entity, time, 0
      end
    when 'jump'
      speed_y_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_y_point_10 @entity_manager, entity, time
      
      if speed_y_point_10 < 0
        transition_time_y = 4_9
        free_motion_y entity, time, \
          'start_speed_point_10' => speed_y_point_10, 
          'end_speed_point_10' => FALL_SPEED_POINT_10,
          'transition_time' => transition_time_y
      end
    end
  end
  
  def float_speed entity, time, factor_x
    speed_x_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_x_point_10 @entity_manager, entity, time
    _stats = stats(entity)
    free_motion_x entity, time, \
      'start_speed_point_10' => speed_x_point_10,
      'end_speed_point_10' => _stats['run_speed']*factor_x,
      'transition_time' => 3_7
  end
  
  def update entity, time
    sprite    = @entity_manager.get_component entity, :Sprite
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    controls  = @entity_manager.get_component entity, :Controls
    
    #speed_x_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_x_point_10 @entity_manager, entity, time
    speed_y_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_y_point_10 @entity_manager, entity, time
    
    
    
    if sprite.index == 4 && sprite.prev_index != 4
      path_speed_point_10 = WindowStates::GameSession::SystemHelpers::PathMotion.speed_point_10 @entity_manager, entity, time
      
      if controls.held.detect { |control| control == 'jump' }
        transition_time_y = TRANSITION_TIME_Y * 2
      else
        transition_time_y = TRANSITION_TIME_Y
      end
      
      free_motion_y entity, time, \
        'start_speed_point_10' => JUMP_SPEED_POINT_10, 
        'end_speed_point_10' => FALL_SPEED_POINT_10,
        'transition_time' => transition_time_y
      
      
      _stats = stats(entity)
      x_speed_point_10 = \
      case controls.held.select { |control| ['left', 'right'].include? control }.last
      when 'left'
        -_stats['run_speed']
      when 'right'
        _stats['run_speed']
      else
        0
      end
      free_motion_x entity, time, \
        'start_speed_point_10' => path_speed_point_10,
        'end_speed_point_10' => x_speed_point_10,
        'transition_time' => 3_7
    end
    
    if speed_y_point_10 > 0
      character.set_animation_state = 'jump_down'
    end
  end
end