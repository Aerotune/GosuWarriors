WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
        
    set_sprite_command = WindowStates::GameSession::Commands::SetSprite.new @entity_manager, entity, {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'fps' => 31,
      'start_time' => time,
      'mode' => 'loop',
      'index' => 0
    }
    
    set_sprite_command.do!
  end
  
  def key_down entity, key, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    case key
    when 'right'
      if drawable.factor_x < 0
        character.set_animation_state = 'slide_to_idle'
      end
    when 'left'
      if drawable.factor_x > 0
        character.set_animation_state = 'slide_to_idle'
      end
    end
  end
  
  def key_up entity, key, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    case key
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
    
  end
end