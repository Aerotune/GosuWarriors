class WindowStates::GameSession::Systems::CharacterAnimationState
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  #def on_set entity, time
  #  character = @entity_manager.get_component entity, :Character
  #  drawable  = @entity_manager.get_component entity, :Drawable
  #  
  #  sprite = WindowStates::GameSession::Components::Sprite.new(
  #    'sprite_resource_path' => ["characters", character.type, character.animation_state],
  #    'fps' => 27,
  #    'start_time' => time,
  #    'mode' => 'loop'
  #  )
  #  
  #  drawable.draw_component = sprite
  #end
  
  def on_unset entity, time
    
  end

  def key_down entity, key, time
    
  end

  def key_up entity, key, time
  
  end

  def update entity, time
  
  end
end