module WindowStates::GameSession::Factories::Target
  class << self
    def build entity_manager, x, y
      entity = entity_manager.create_entity
      
      drawable  = WindowStates::GameSession::Components::Drawable.new(
        'x' => x,
        'y' => y, 
        'z_order' => ZOrder::TARGET,
        'factor_x' => 1
      )
      sprite = WindowStates::GameSession::Components::Sprite.new(
        'sprite_resource_path' => %w[level objects target],
        'fps' => :sprite_resource_fps,
        'start_time' => 0,
        'mode' => 'stop',
        'index' => 0,
        'start_index' => 0
      )
      
      entity_manager.add_component entity, drawable
      entity_manager.add_component entity, sprite
      entity_manager.add_component entity, WindowStates::GameSession::Components::HitImmunities.new('hit_ids' => [])
      
      return entity
    end
  end
end