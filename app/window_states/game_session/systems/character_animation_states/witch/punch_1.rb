WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    #drawable  = @entity_manager.get_component entity, :Drawable
    
    character.queued_animation_state = 'idle'
    set_sprite_command = WindowStates::GameSession::Commands::SetSprite.new @entity_manager, entity, {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'fps' => :sprite_resource_fps,
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
    
    set_sprite_command.do!
    
    _stats = stats(entity)
    speed           = 0
    transition_time = _stats['stop_transition_time']
    transition_to_speed_point_10 entity, time, speed, transition_time
  end
  
  def control_down entity, control, time
    character = @entity_manager.get_component entity, :Character
    sprite = @entity_manager.get_component entity, :Sprite
    case control
    when 'attack'
      character.queued_animation_state = 'punch_2' 
    when 'left'
      character.queued_animation_state = 'idle'
    when 'right'
      character.queued_animation_state = 'idle'
    end
  end
  
  def update entity, time
    sprite = @entity_manager.get_component(entity, :Sprite)
    character = @entity_manager.get_component(entity, :Character)
    
    if character.queued_animation_state == 'punch_2' && (13...20) === sprite.index
      character.set_animation_state = character.queued_animation_state
    end
    
    if sprite.done
      character.set_animation_state = 'idle'
    end
  end
end