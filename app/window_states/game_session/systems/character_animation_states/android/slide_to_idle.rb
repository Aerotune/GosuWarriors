Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    
    Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
    
    character.queued_animation_state = 'idle'
    character.set_motion_state = 'Stand' unless character.motion_state == 'Stand'
  end
  
  def control_down entity, control, time
    character = @entity_manager.get_component entity, :Character
    sprite    = @entity_manager.get_component entity, :Sprite
    
    case control
    when 'attack'
      character.queued_animation_state = 'punch_1'
    when 'jump'
      character.set_animation_state = 'jump_from_ground'
    end
  end
  
  def update entity, time
    sprite    = @entity_manager.get_component entity, :Sprite
    character = @entity_manager.get_component entity, :Character
    
    if character.queued_animation_state == 'idle' && ((5..6) === sprite.index)
      controls  = @entity_manager.get_component entity, :Controls
      drawable  = @entity_manager.get_component entity, :Drawable
      
      left_or_right = controls.held.select { |control| ['left', 'right'].include? control }
      if (drawable.factor_x > 0 && left_or_right.last == 'right') || (drawable.factor_x < 0 && left_or_right.last == 'left')
        #change explicit
        Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
          'sprite_resource_path' => ["characters", character.type, character.animation_state],
          'start_time' => time,
          'mode' => 'backward',
          'index' => sprite.index,
          'start_index' => sprite.index
        }
    
        character.queued_animation_state = 'run'
        character.set_motion_state = 'Run'
      end
    end
    
    character.set_animation_state = character.queued_animation_state if sprite.done
    character.set_animation_state = 'fall_down' if character['stage_collisions']['path_movement']['direction_beyond_ledge']
  end
end