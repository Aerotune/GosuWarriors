Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    
    Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
        
    character.queued_animation_state = 'run'
    character.set_motion_state = 'Run'
  end
  
  def control_up entity, control, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    if (drawable.factor_x == 1 && control == 'right') || (drawable.factor_x == -1 && control == 'left')
      character.set_motion_state = 'Stand' if character.motion_state == 'Run'
    end
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