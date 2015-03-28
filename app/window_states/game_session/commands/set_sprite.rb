class WindowStates::GameSession::Commands::SetSprite < Command
  def initialize entity_manager, entity, next_sprite_hash
    super()
    @entity_manager   = entity_manager
    @entity           = entity
    @next_sprite_hash = next_sprite_hash
  end
  
  def do_action
    prev_sprite = @entity_manager.get_component(@entity, :Sprite)
    
    if prev_sprite
      @prev_sprite_hash ||= prev_sprite.to_hash 
      @entity_manager.remove_component @entity, :Sprite
    end
    
    next_sprite = WindowStates::GameSession::Components::Sprite.new @next_sprite_hash
    @entity_manager.add_component @entity, next_sprite
  end
  
  def undo_action
    @entity_manager.remove_component @entity, :Sprite
    
    if @prev_sprite_hash
      prev_sprite = WindowStates::GameSession::Components::Sprite.new @prev_sprite_hash
      @entity_manager.add_component @entity, prev_sprite
    end
  end
end