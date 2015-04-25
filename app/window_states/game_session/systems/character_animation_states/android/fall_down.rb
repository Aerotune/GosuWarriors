Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    
    character.queued_animation_state = 'idle'
    Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, 'jump_fall'],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
    
    character.set_motion_state = 'Fall'
  end
  
  def control_down entity, control, time
    case control
    when 'attack'
      character = @entity_manager.get_component entity, :Character
      controls = @entity_manager.get_component entity, :Controls
      if controls.held.include? 'up'
        character.set_animation_state = 'air_kick'
      else
        character.set_animation_state = 'air_spin'
      end
    when 'jump'
      _free_motion_y = @entity_manager.get_component(entity, :FreeMotionY)
      character = @entity_manager.get_component entity, :Character
      if character['cooldown']['jump_in_air'] == false
        character.set_animation_state = 'jump_in_air'
      end
    end
  end
  
  def update entity, time
    sprite    = @entity_manager.get_component entity, :Sprite
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    if character['stage_collisions']['path_movement']['start_point_distance']
      character.set_animation_state = 'land'
    end
  end
end