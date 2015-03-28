WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    
    set_sprite_command = WindowStates::GameSession::Commands::SetSprite.new @entity_manager, entity, {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'fps' => 60,
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
    
    set_sprite_command.do!
  end
  
  def update entity, time
    sprite = @entity_manager.get_component(entity, :Sprite)
    if sprite.done
      character = @entity_manager.get_component(entity, :Character)
      character.set_animation_state = 'run'
    end
  end
end