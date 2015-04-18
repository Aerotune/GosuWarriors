WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    #character.queued_animation_state = 'idle'
    WindowStates::GameSession::Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
    
    _stats = stats(entity)
    controls = @entity_manager.get_component entity, :Controls
    left_or_right = controls.held.select { |control| ['left', 'right'].include? control }
    case left_or_right.last
    when 'left'
      float_speed entity, time, -1, _stats['run_speed']/2
    when 'right'
      float_speed entity, time, 1, _stats['run_speed']/2
    else
      float_speed entity, time, 0      
    end
  end
  
  def control_down entity, control, time
    _stats = stats(entity)
    case control
    when 'left'
      float_speed entity, time, -1, _stats['run_speed']/2
    when 'right'
      float_speed entity, time, 1, _stats['run_speed']/2
    end
  end
  
  #def control_down entity, control, time
  #  character = @entity_manager.get_component entity, :Character
  #  sprite = @entity_manager.get_component entity, :Sprite
  #  case control
  #  when 'attack'
  #    character.queued_animation_state = 'kick_1' 
  #  when 'left'
  #    character.queued_animation_state = 'idle'
  #  when 'right'
  #    character.queued_animation_state = 'idle'
  #  end
  #end
  
  def update entity, time
    sprite = @entity_manager.get_component(entity, :Sprite)
    character = @entity_manager.get_component(entity, :Character)
    
    #if character.queued_animation_state == 'kick_1' && (8..15) === sprite.index
    #  character.set_animation_state = character.queued_animation_state
    #end
    
    if sprite.done
      character.set_animation_state = 'jump_fall'
    end
  end
end