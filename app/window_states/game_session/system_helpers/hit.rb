module WindowStates::GameSession::SystemHelpers::Hit
  class << self
    def hit_id entity_manager, entity, shape
      sprite = entity_manager.get_component entity, :Sprite
      sprite_resource = Resources::Sprites[sprite.sprite_resource_path]
      shapes = sprite_resource['frames'][sprite.index]['shapes']
      "#{entity}_#{sprite.sprite_resource_path.join('/')}_shape_#{shapes.index(shape)}"
    end
  end
end