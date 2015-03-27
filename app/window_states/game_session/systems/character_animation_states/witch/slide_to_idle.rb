WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    sprite = WindowStates::GameSession::Components::Sprite.new(
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'fps' => 70,
      'start_time' => time,
      'mode' => 'forward'
    )
    
    drawable.draw_component = sprite
  end
  
  def key_down entity, key, time
       
  end
  
  def key_up entity, key, time
    #character = @entity_manager.get_component entity, :Character
    #drawable  = @entity_manager.get_component entity, :Drawable
    #
    #case key
    #when 'right'
    #  character.animation_state = 'idle'
    #  drawable.factor_x = 1
    #when 'left'
    #  character.animation_state = 'idle'
    #  drawable.factor_x = -1
    #end 
  end
  
  def update entity, time
    sprite = @entity_manager.get_component(entity, :Drawable).draw_component
    if sprite.done
      character = @entity_manager.get_component(entity, :Character)
      character.set_animation_state = 'idle'
    end
  end
end