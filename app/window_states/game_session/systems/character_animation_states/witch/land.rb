WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    character['cooldown']['jump_in_air'] = false
        
    WindowStates::GameSession::Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
        
    controls = @entity_manager.get_component entity, :Controls
    #drawable = @entity_manager.get_component entity, :Drawable
    
    left_or_right = controls.held.select { |control| ['left', 'right'].include? control }
    if left_or_right.last
      factor_x = left_or_right.last == 'right' ? 1 : -1
      _stats = stats(entity)
      speed           = _stats['run_speed']*factor_x*8/10
      transition_time = _stats['run_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time
    else
      _stats = stats(entity)
      speed           = 0
      transition_time = _stats['stop_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time
    end
  end
  
  def control_down entity, control, time
    case control
    when 'left'
      _stats = stats(entity)
      speed           = (_stats['run_speed']*-1)*8/10
      transition_time = _stats['run_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time
    when 'right'
      _stats = stats(entity)
      speed           = (_stats['run_speed']*1)*8/10
      transition_time = _stats['run_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time
    end
  end
  
  def control_up entity, control, time
    case control
    when 'left'
      _stats = stats(entity)
      speed           = 0#(_stats['run_speed']*-1)*8/10 #!!! check if the other direction control is held
      transition_time = _stats['stop_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time
    when 'right'
      _stats = stats(entity)
      speed           = 0#(_stats['run_speed']*1)*8/10 #!!! check if the other direction control is held
      transition_time = _stats['stop_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time
    end
  end
  
  def update entity, time
    sprite    = @entity_manager.get_component entity, :Sprite
    character = @entity_manager.get_component entity, :Character
    
    if sprite.done
      character.set_animation_state = 'idle'
    end
  end
end