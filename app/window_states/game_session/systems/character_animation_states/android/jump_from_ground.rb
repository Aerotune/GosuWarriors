WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    character.queued_animation_state = nil
    WindowStates::GameSession::Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
    _stats = stats(entity)
    speed           = 0
    transition_time = _stats['stop_transition_time']*2
    transition_to_speed_point_10 entity, time, speed, transition_time    
  end
  
  
  ANDROID_JUMP_SPEED_POINT_10 = -24_000
  ANDROID_END_SPEED_POINT_10  = 0#29_400
  ANDROID_TRANSITION_TIME_Y   = 31
  
  ANDROID_JUMP_IN_AIR_SPEED_POINT_10 = ANDROID_JUMP_SPEED_POINT_10 * 8 / 10
  ANDROID_JUMP_IN_AIR_TRANSITION_TIME_Y = ANDROID_TRANSITION_TIME_Y * 12 / 10
  
  def control_down entity, control, time
    character = @entity_manager.get_component entity, :Character
    controls = @entity_manager.get_component entity, :Controls
    
    case control
    #when 'left'
    #  float_speed entity, time, -1 if character.motion_state == 'Jump'
    #when 'right'
    #  float_speed entity, time, 1 if character.motion_state == 'Jump'
    when 'attack'
      if character.motion_state == 'Jump'
        if controls.held.include? 'up'
          character.set_animation_state = 'air_kick'
        else
          character.set_animation_state = 'air_spin'
        end
      else
        if controls.held.include? 'up'
          character.queued_animation_state = 'air_kick'
        else
          character.queued_animation_state = 'air_spin'
        end
      end
    when 'jump'
      _free_motion_y = @entity_manager.get_component(entity, :FreeMotionY)
      character = @entity_manager.get_component entity, :Character
      if character['cooldown']['jump_in_air'] == false
        character.set_animation_state = 'jump_in_air' #if _free_motion_y # !!! jump_in_air.rb:87 crashed because of no FreeMotionY
      end
    end
  end
  
  #def control_up entity, control, time
  #  sprite = @entity_manager.get_component entity, :Sprite
  #  return unless sprite.index > 4
  #  
  #  controls = @entity_manager.get_component entity, :Controls
  #  case control
  #  when 'right'
  #    if controls.held.detect { |control| control == 'left' }
  #      #float_speed entity, time, -1
  #    else
  #      #float_speed entity, time, 0
  #    end
  #  when 'left'
  #    if controls.held.detect { |control| control == 'right' }
  #      #float_speed entity, time, 1
  #    else
  #      #float_speed entity, time, 0
  #    end
  #  when 'jump'
  #    #fall entity, time
  #  end
  #end
  
  #def fall entity, time
  #  _free_motion_y = @entity_manager.get_component(entity, :FreeMotionY)
  #  
  #  if _free_motion_y && _free_motion_y['start_speed_point_10'] == ANDROID_JUMP_SPEED_POINT_10
  #    speed_y_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_y_point_10 @entity_manager, entity, time
  #    progress_point_10 = ((time - _free_motion_y['start_time'])<<10) / _free_motion_y['transition_time'] 
  #    remaining_transition_time = (((1<<10) - progress_point_10) * _free_motion_y['transition_time']) >> 10
  #    free_motion_y entity, time, \
  #      'start_speed_point_10' => speed_y_point_10, 
  #      'end_speed_point_10' => ANDROID_END_SPEED_POINT_10,
  #      'transition_time' => remaining_transition_time / 2,
  #      'easer' => 'sin_out'
  #  end
  #end
  
  #def float_speed entity, time, factor_x
  #  speed_x_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_x_point_10 @entity_manager, entity, time
  #  _stats = stats(entity)
  #  free_motion_x entity, time, \
  #    'start_speed_point_10' => speed_x_point_10,
  #    'end_speed_point_10' => _stats['run_speed']*factor_x,
  #    'transition_time' => 5_0
  #end
  
  def update entity, time
    sprite    = @entity_manager.get_component entity, :Sprite
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    controls  = @entity_manager.get_component entity, :Controls
    
    #speed_x_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_x_point_10 @entity_manager, entity, time
    speed_y_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_y_point_10 @entity_manager, entity, time
    
    
    if character.motion_state == "Fall"
      character.set_animation_state = 'jump_fall'
      character.set_motion_state = "Fall"
    end
    
    if sprite.index == 4 && sprite.prev_index != 4
      character.set_animation_state = character.queued_animation_state if character.queued_animation_state
      character.set_motion_state = "Jump"
    end
    
    if character.motion_state == "Jump"
      if character['stage_collisions']['path_movement']['start_point_distance']
        character.set_animation_state = 'land'
      end
    end
    
  end
end