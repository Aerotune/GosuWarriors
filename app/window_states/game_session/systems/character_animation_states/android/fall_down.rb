WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    
    character.queued_animation_state = 'idle'
    WindowStates::GameSession::Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
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
    when 'left'
      float_speed entity, time, -1
    when 'right'
      float_speed entity, time, 1
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
        character.set_animation_state = 'jump_in_air' #if _free_motion_y # !!! jump_in_air.rb:87 crashed because of no FreeMotionY
      end
    end
  end
  
  def control_up entity, control, time
    controls = @entity_manager.get_component entity, :Controls
    case control
    when 'right'
      if controls.held.detect { |control| control == 'left' }
        float_speed entity, time, -1
      else
        float_speed entity, time, 0
      end
    when 'left'
      if controls.held.detect { |control| control == 'right' }
        float_speed entity, time, 1
      else
        float_speed entity, time, 0
      end
    end
  end
  
  def update entity, time
    sprite    = @entity_manager.get_component entity, :Sprite
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
  end
end