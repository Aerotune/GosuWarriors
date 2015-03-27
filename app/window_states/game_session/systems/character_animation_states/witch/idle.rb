WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    sprite = WindowStates::GameSession::Components::Sprite.new(
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'fps' => 30,
      'start_time' => time,
      'mode' => 'loop'
    )
    
    drawable.draw_component = sprite
  end
  
  def key_down entity, key, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    case key
    when 'right'
      character.set_animation_state = 'idle_to_run'
      drawable.factor_x = 1
    when 'left'
      character.set_animation_state = 'idle_to_run'
      drawable.factor_x = -1
    end    
  end
  
  def key_up entity, key, time
    
  end
  
  def update entity, time
    
  end
end