WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    
    WindowStates::GameSession::Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
        
    character.queued_animation_state = 'run'
    
    _stats = stats(entity)
    speed           = _stats['run_speed']*drawable.factor_x
    transition_time = _stats['run_transition_time']
    transition_to_speed_point_10 entity, time, speed, transition_time, 'push_beyond_ledge' => true
  end
  
  def control_down entity, control, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    case control
    when 'attack'
      character.queued_animation_state = 'dash_attack'
    when 'jump'
      character.set_animation_state = 'jump_from_ground'
    end
    
    if control == 'right' && drawable.factor_x == 1
      _stats = stats(entity)
      speed           = _stats['run_speed']*drawable.factor_x
      transition_time = _stats['run_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time, 'push_beyond_ledge' => true
      character.queued_animation_state = 'run'
    end
    
    if control == 'left' && drawable.factor_x == -1
      _stats = stats(entity)
      speed           = _stats['run_speed']*drawable.factor_x
      transition_time = _stats['run_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time, 'push_beyond_ledge' => true
      character.queued_animation_state = 'run'
    end
  end
  
  def control_up entity, control, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    if control == 'right' && drawable.factor_x == 1
      _stats = stats(entity)
      speed           = 0
      transition_time = _stats['stop_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time, 'push_beyond_ledge' => true
    end
    
    if control == 'left' && drawable.factor_x == -1
      _stats = stats(entity)
      speed           = 0
      transition_time = _stats['stop_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time, 'push_beyond_ledge' => true
    end
  end
  
  def update entity, time
    sprite = @entity_manager.get_component(entity, :Sprite)
    character = @entity_manager.get_component entity, :Character
    
    if sprite.done
      character.set_animation_state = character.queued_animation_state
    end
    
    character.set_animation_state = 'fall_down' if character['stage_collisions']['path_movement']['direction_beyond_ledge']
  end
end