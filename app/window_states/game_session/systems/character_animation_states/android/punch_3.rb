Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    character.queued_animation_state = 'idle'
    Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
    
    character.set_motion_state = 'Stand' unless character.motion_state == 'Stand'
    motion_state = Systems::MotionStates.const_get character.motion_state
    motion_state.tween game_session, entity, time+10,
    'distance' => (-70<<10)*drawable.factor_x,
    'duration' => 70
  end
  
  def update entity, time
    sprite = @entity_manager.get_component(entity, :Sprite)
    character = @entity_manager.get_component(entity, :Character)
    
    if sprite.done
      character.set_animation_state = 'idle'
    end
  end
end