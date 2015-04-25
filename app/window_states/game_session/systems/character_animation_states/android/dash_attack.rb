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
    
    #motion_state = Systems::MotionStates.const_get character.motion_state
    #motion_state.tween game_session, entity, time+10,
    #'distance' => (150<<10)*drawable.factor_x,
    #'duration' => 25
  end

  def update entity, time
    sprite = @entity_manager.get_component entity, :Sprite
    character = @entity_manager.get_component entity, :Character
    
    
    character.set_motion_state = "Stand" if sprite.index == 5 && sprite.prev_index != sprite.index
    character.set_motion_state = 'Fall'  if character['stage_collisions']['path_movement']['direction_beyond_ledge']
    character.set_motion_state = 'Land'  if character['stage_collisions']['path_movement']['start_point_distance']
    
    if sprite.done
      motion_state = character.motion_state
      motion_state = character.set_motion_state if character.set_motion_state
      case motion_state
      when 'Fall'
        character.set_animation_state = 'fall_down'
      else
        character.set_animation_state = 'idle'
      end
    end    
  end
end