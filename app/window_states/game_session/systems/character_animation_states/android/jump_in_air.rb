Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    character['cooldown']['jump_in_air'] = true
    
    character.queued_animation_state = 'jump_down'
    character.set_motion_state = 'JumpInAir'
    Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
  end
  
  JUMP_SPEED_POINT_10 = -24_000
  END_SPEED_POINT_10  = 0#29_400
  TRANSITION_TIME_Y   = 32
  
  def control_down entity, control, time
    sprite = @entity_manager.get_component entity, :Sprite
      
    case control
    when 'attack'
      character = @entity_manager.get_component entity, :Character
      controls = @entity_manager.get_component entity, :Controls
      if controls.held.include? 'up'
        character.set_animation_state = 'air_kick'
      else
        character.set_animation_state = 'air_spin'
      end
    end
  end
  
  def update entity, time
    sprite    = @entity_manager.get_component entity, :Sprite
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    controls  = @entity_manager.get_component entity, :Controls
    
    #speed_x_point_10 = SystemHelpers::FreeMotion.speed_x_point_10 @entity_manager, entity, time
    speed_y_point_10 = SystemHelpers::FreeMotion.speed_y_point_10 @entity_manager, entity, time
    
    
    
    #if sprite.index == 4 && sprite.prev_index != 4
    #  
    #end
    
    _free_motion_y = @entity_manager.get_component(entity, :FreeMotionY)
    if _free_motion_y
      _free_motion_y_time = time - _free_motion_y['start_time']
      time_left = _free_motion_y['transition_time'] - _free_motion_y_time
      if time_left <= _free_motion_y['transition_time']/6
        character.set_animation_state = 'jump_fall'
      end
    end
    
    if character['stage_collisions']['path_movement']['start_point_distance']
      character.set_animation_state = 'land'
    end
  end
end