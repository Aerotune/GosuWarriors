WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    character.queued_animation_state = 'jump_down'
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
    transition_to_speed_point_10 entity, time, speed, transition_time    
  end
  
  def update entity, time
    sprite    = @entity_manager.get_component entity, :Sprite
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    speed_x_point_10, speed_y_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_point_10 @entity_manager, entity, time
    
    if sprite.index == 4 && sprite.prev_index != 4
      free_motion entity, time, \
        'start_speed_y_point_10' => -27_500, 
        'start_speed_x_point_10' => 0,
        'end_speed_y_point_10' => 36_400,
        'end_speed_x_point_10' => 0,
        'transition_time_y' => 120,
        'transition_time_x' => 10
    end
    
    if speed_y_point_10 > 0
      character.set_animation_state = 'jump_down'
    end
  end
end