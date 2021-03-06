Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    #character.queued_animation_state = 'idle'
    Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
    #_free_motion_y = @entity_manager.get_component entity, :FreeMotionY
    #if _free_motion_y['end_speed_point_10'] == 19_500
    #  speed_y_point_10 = SystemHelpers::FreeMotion.speed_y_point_10 @entity_manager, entity, time
    #  free_motion_y entity, time, \
    #    'start_speed_point_10' => speed_y_point_10, 
    #    'end_speed_point_10' => 19_500/3,
    #    'transition_time' => 40,
    #    'easer' => 'sin_out'
    #end
    #
    #_stats = SystemHelpers::Character.stats(game_session, entity)
    #controls = @entity_manager.get_component entity, :Controls
    #left_or_right = controls.held.select { |control| ['left', 'right'].include? control }
    #case left_or_right.last
    #when 'left'
    #  float_speed entity, time, -1, _stats['run_speed']/2
    #when 'right'
    #  float_speed entity, time, 1, _stats['run_speed']/2
    #else
    #  float_speed entity, time, 0      
    #end
  end
  
  #def control_down entity, control, time
  #  _stats = SystemHelpers::Character.stats(game_session, entity)
  #  case control
  #  when 'left'
  #    float_speed entity, time, -1, _stats['run_speed']/2
  #  when 'right'
  #    float_speed entity, time, 1, _stats['run_speed']/2
  #  end
  #end
  
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
    
    if character['stage_collisions']['path_movement']['direction_beyond_ledge']
      character.set_motion_state = 'Fall'
    end
    
    if character['stage_collisions']['path_movement']['start_point_distance']
      character.set_motion_state = 'Land'
    end
    
    if sprite.done
      motion_state = character.motion_state
      motion_state = character.set_motion_state if character.set_motion_state
      
      case motion_state
      when 'Land'
        character.set_animation_state = 'land'
      else
        character.set_animation_state = 'jump_fall'
      end
    end    
  end
end