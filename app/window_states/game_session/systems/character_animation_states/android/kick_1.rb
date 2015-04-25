Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    character.queued_animation_state = 'idle'
    Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
        
    character.set_motion_state = 'Stand' unless character.motion_state == 'Stand'
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
    
    if character.queued_animation_state == 'punch_2' && (8..15) === sprite.index
      character.set_animation_state = character.queued_animation_state
    end
    
    if sprite.done
      character.set_animation_state = 'idle'
    end
  end
end