WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    character.queued_animation_state = 'idle'
    WindowStates::GameSession::Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
    
    
    _stats = stats(entity)
    speed           = 0
    transition_time = _stats['stop_transition_time']
    transition_to_speed_point_10 entity, time, speed, transition_time
    tween entity, time+6, (25<<10)*drawable.factor_x, 20
  end
  
  def control_down entity, control, time
    character = @entity_manager.get_component entity, :Character
    sprite = @entity_manager.get_component entity, :Sprite
    case control
    when 'attack'
      character.queued_animation_state = 'kick_1' 
    when 'left'
      character.queued_animation_state = 'idle'
    when 'right'
      character.queued_animation_state = 'idle'
    end
  end
  
  def update entity, time
    sprite = @entity_manager.get_component(entity, :Sprite)
    character = @entity_manager.get_component(entity, :Character)
    
    if character.queued_animation_state == 'kick_1' && (8..15) === sprite.index
      character.set_animation_state = character.queued_animation_state
    end
    
    if sprite.done
      character.set_animation_state = 'idle'
    end
  end
end