WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    
    set_sprite_command = WindowStates::GameSession::Commands::SetSprite.new @entity_manager, entity, {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'fps' => :sprite_resource_fps,
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
    
    set_sprite_command.do!
    
    character.queued_animation_state = 'run'
    
    _stats = stats(entity)
    speed           = _stats['run_speed']*drawable.factor_x
    transition_time = _stats['run_transition_time']
    transition_to_speed_point_10 entity, time, speed, transition_time
  end
  
  def control_down entity, control, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    if control == 'right' && drawable.factor_x == 1
      _stats = stats(entity)
      speed           = _stats['run_speed']*drawable.factor_x
      transition_time = _stats['run_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time
      character.queued_animation_state = 'run'
    end
    
    if control == 'left' && drawable.factor_x == -1
      _stats = stats(entity)
      speed           = _stats['run_speed']*drawable.factor_x
      transition_time = _stats['run_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time
      character.queued_animation_state = 'run'
    end
    
    if control == 'attack'
      character.queued_animation_state = 'punch_1'
    end
  end
  
  def control_up entity, control, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    if control == 'right' && drawable.factor_x == 1
      _stats = stats(entity)
      speed           = 0
      transition_time = _stats['stop_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time
    end
    
    if control == 'left' && drawable.factor_x == -1
      _stats = stats(entity)
      speed           = 0
      transition_time = _stats['stop_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time
    end
  end
  
  def update entity, time
    sprite = @entity_manager.get_component(entity, :Sprite)
    if sprite.done
      character = @entity_manager.get_component(entity, :Character)
      character.set_animation_state = character.queued_animation_state
    end
  end
end