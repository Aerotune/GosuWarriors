WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
        
    WindowStates::GameSession::Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'start_time' => time,
      'mode' => 'loop',
      'index' => 0,
      'start_index' => 0
    }    
    
    character.set_motion_state = "Run"
    #_stats = stats(entity)
    #speed           = _stats['run_speed']*drawable.factor_x
    #transition_time = _stats['run_transition_time']
    #transition_to_speed_point_10 entity, time, speed, transition_time, 'push_beyond_ledge' => true 
  end
  
  def control_down entity, control, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    case control
    when 'right'
      if drawable.factor_x < 0
        character.set_animation_state = 'slide_to_idle'
      end
    when 'left'
      if drawable.factor_x > 0
        character.set_animation_state = 'slide_to_idle'
      end
    when 'attack'
      character.set_animation_state = 'dash_attack'
    when 'jump'
      character.set_animation_state = 'jump_from_ground'
    end
  end
  
  def control_up entity, control, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    case control
    when 'right'
      if drawable.factor_x > 0
        character.set_animation_state = 'slide_to_idle'
      end
    when 'left'
      if drawable.factor_x < 0
        character.set_animation_state = 'slide_to_idle'
      end
    end
  end
  
  def update entity, time
    character = @entity_manager.get_component entity, :Character
    controls  = @entity_manager.get_component entity, :Controls
    drawable  = @entity_manager.get_component entity, :Drawable
    
    if drawable.factor_x > 0
      unless controls.held.include? 'right'
        character.set_animation_state = 'slide_to_idle'
      end
    else
      unless controls.held.include? 'left'
        character.set_animation_state = 'slide_to_idle'
      end
    end
    
    character.set_animation_state = 'fall_down' if character['stage_collisions']['path_movement']['direction_beyond_ledge']
  end
end