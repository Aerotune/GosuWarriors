WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
        
    WindowStates::GameSession::Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
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
    
    _stats = stats(entity)
    speed           = 0
    transition_time = _stats['stop_transition_time']
    transition_to_speed_point_10 entity, time, speed, transition_time
  end
  
  def control_down entity, control, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    case control
    when 'right'
      character.set_animation_state = 'idle_to_run'
      drawable.factor_x = 1
    when 'left'
      character.set_animation_state = 'idle_to_run'
      drawable.factor_x = -1
    when 'attack'
      character.set_animation_state = 'punch_1'
    when 'jump'
      character.set_animation_state = 'jump_up'
    end    
  end
end