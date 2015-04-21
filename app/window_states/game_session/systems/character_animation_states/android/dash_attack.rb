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
    transition_to_speed_point_10 entity, time, speed, transition_time, 'push_beyond_ledge' => true 
    tween entity, time+10, (120<<10)*drawable.factor_x, 30
  end

  def update entity, time
    sprite = @entity_manager.get_component entity, :Sprite
    character = @entity_manager.get_component entity, :Character
    
    if sprite.done
      case character.motion_state
      when 'Fall'
        character.set_animation_state = 'fall_down'
      else
        character.set_animation_state = 'idle'
      end
      #character.set_animation_state = 'idle'
    end
    
    character.set_motion_state = 'Fall' if character['stage_collisions']['path_movement']['direction_beyond_ledge']
    #character.set_animation_state = 'fall_down' if character['stage_collisions']['path_movement']['direction_beyond_ledge']
  end
end