Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    character['cooldown']['jump_in_air'] = false
    
    Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'start_time' => time,
      'mode' => 'loop',
      'index' => 0,
      'start_index' => 0
    }
        
    controls = @entity_manager.get_component entity, :Controls
    controls.held.each do |control|
      control_down entity, control, time
    end
    
    character.set_motion_state = 'Stand'
  end
  
  def control_down entity, control, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    controls  = @entity_manager.get_component entity, :Controls
    case control
    when 'right'
      character.set_animation_state = 'idle_to_run'
      drawable.factor_x = 1
    when 'left'
      character.set_animation_state = 'idle_to_run'
      drawable.factor_x = -1
    when 'attack'
      case drawable.factor_x
      when 1
        if controls.held.include?('right')
          character.set_animation_state = 'dash_attack'
        else
          character.set_animation_state = 'punch_1'
        end
      when -1
        if controls.held.include?('left')
          character.set_animation_state = 'dash_attack'
        else
          character.set_animation_state = 'punch_1'
        end
      end
      
      
    when 'jump'
      character.set_animation_state = 'jump_from_ground'
    end    
  end
  
  def update entity, time
    character = @entity_manager.get_component entity, :Character
    character.set_animation_state = 'fall_down' if character['stage_collisions']['path_movement']['direction_beyond_ledge']
  end
end