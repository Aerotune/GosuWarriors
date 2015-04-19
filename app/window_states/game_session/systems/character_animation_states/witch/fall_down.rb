WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    character.queued_animation_state = 'idle'
    WindowStates::GameSession::Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, 'jump_down'],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
        
    _stats = stats(entity)
    speed_point_10 = WindowStates::GameSession::SystemHelpers::PathMotion.speed_point_10 @entity_manager, entity, time
    #speed_y_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_y_point_10 @entity_manager, entity, time
  
    set_free_motion entity, time, drawable.x, drawable.y-2
    
    free_motion_y entity, time, \
      'start_speed_point_10' => -500, 
      'end_speed_point_10' => 19_500,
      'transition_time' => 29,
      'easer' => 'sin_in'
      
    if speed_point_10 >= 0
      speed_point_10 = 8_000 if speed_point_10 < 8_000
    else
      speed_point_10 = -8_000 if speed_point_10 > -8_000
    end
    
    free_motion_x entity, time, \
      'start_speed_point_10' => speed_point_10, 
      'end_speed_point_10' => 0,
      'transition_time' => 5_0,
      'easer' => 'sin_in'
    
    controls = @entity_manager.get_component entity, :Controls
    left_or_right = controls.held.select { |control| ['left', 'right'].include? control }
    case left_or_right.last
    when 'left'
      float_speed entity, time, -1
    when 'right'
      float_speed entity, time, 1
    end
    #speed           = 0
    #transition_time = _stats['stop_transition_time']
    #transition_to_speed_point_10 entity, time, speed, transition_time    
    #tween entity, time, (50<<10)*drawable.factor_x, 16
  end
  
  def control_down entity, control, time
    case control
    when 'left'
      float_speed entity, time, -1
    when 'right'
      float_speed entity, time, 1
    end
  end
  
  def control_up entity, control, time
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
    end
  end
  
  def update entity, time
    sprite    = @entity_manager.get_component entity, :Sprite
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
  end
  
  def float_speed entity, time, factor_x
    speed_x_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_x_point_10 @entity_manager, entity, time
    _stats = stats(entity)
    free_motion_x entity, time, \
      'start_speed_point_10' => speed_x_point_10,
      'end_speed_point_10' => _stats['run_speed']*factor_x,
      'transition_time' => 5_0
  end
end