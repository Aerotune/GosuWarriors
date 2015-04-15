WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    
    WindowStates::GameSession::Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, 'slide_to_idle'],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
        
  end
  
  def control_down entity, control, time
    character = @entity_manager.get_component entity, :Character
    
    #case control
    #when 'attack'
    #  character.queued_animation_state = 'punch_1'
    #when 'jump'
    #  character.set_animation_state = 'jump_from_ground'
    #end
  end
  
  def update entity, time
    sprite    = @entity_manager.get_component entity, :Sprite
    character = @entity_manager.get_component entity, :Character
    
    
  end
end