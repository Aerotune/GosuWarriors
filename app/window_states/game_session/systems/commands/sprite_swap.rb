module Systems::Commands::SpriteSwap
  class << self
    def do entity_manager, entity, options
      prev_sprite = entity_manager.get_component(entity, :Sprite)
    
      if prev_sprite
        options['prev_sprite_hash'] = prev_sprite.to_hash 
        entity_manager.remove_component entity, :Sprite
      end
      
      unless options['sprite_hash']['fps']
        sprite_resource = Resources::Sprites[options['sprite_hash']['sprite_resource_path']]
        options['sprite_hash']['fps'] = sprite_resource['fps']
      end
    
      next_sprite = WindowStates::GameSession::Components::Sprite.new options['sprite_hash']
      entity_manager.add_component entity, next_sprite
    end
    
    def undo entity_manager, entity, spawn
      
    end
  end
end