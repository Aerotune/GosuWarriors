module SystemHelpers::Sprite
  class << self
    def sprite_resource entity_manager, entity
      sprite = entity_manager.get_component(entity, :Sprite)
      
      if sprite
        return Resources::Sprites[sprite.sprite_resource_path]
      else
        return nil
      end
    end
    
    def current_frame entity_manager, entity
      sprite          = entity_manager.get_component entity, :Sprite
      sprite_resource = Resources::Sprites[sprite.sprite_resource_path]
      frame           = sprite_resource['frames'][sprite.index]
    end
  end
end