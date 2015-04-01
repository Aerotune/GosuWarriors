WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    character.queued_animation_state = 'idle'
    set_sprite_command = WindowStates::GameSession::Commands::SetSprite.new @entity_manager, entity, {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'fps' => :sprite_resource_fps,
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
    
    set_sprite_command.do!
    
    _stats = stats(entity)
    speed           = 0
    transition_time = _stats['stop_transition_time']
    transition_to_speed_point_10 entity, time, speed, transition_time
    tween entity, time+18, (-70<<10)*drawable.factor_x, 70
  end
  
  def update entity, time
    sprite = @entity_manager.get_component(entity, :Sprite)
    character = @entity_manager.get_component(entity, :Character)
    
    if sprite.done
      character.set_animation_state = 'idle'
    end
  end
end