WindowStates::GameSession::Systems::CharacterAnimationStates.generalize_class :idle_to_run do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    set_sprite_command = WindowStates::GameSession::Commands::SetSprite.new @entity_manager, entity, {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'fps' => 60,
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
    
    set_sprite_command.do!
    
    transition_to_speed_point_10 entity, time, 12_000*drawable.factor_x, 40
  end
  
  def update entity, time
    sprite = @entity_manager.get_component(entity, :Sprite)
    if sprite.done
      character = @entity_manager.get_component(entity, :Character)
      character.set_animation_state = 'run'
    end
  end
end