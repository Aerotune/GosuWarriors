module WindowStates::GameSession::Factories::Character
  class << self
    def build entity_manager, character_animation_states_system, character_type, control_type, set_animation_state="idle"
      entity = entity_manager.create_entity
      
      character = WindowStates::GameSession::Components::Character.new \
        'type' => character_type,
        'set_animation_state' => set_animation_state, 
        'control_type' => control_type,
        'cooldown' => {
          'jump_in_air' => false
        },
        'stage_collisions' => {
          'wall_facing_right_x' => nil,
          'wall_facing_left_x'  => nil,
          'ceiling_y'           => nil,
          'path_movement' => {
            'direction_beyond_ledge' => nil
          }
        }
      
      controls  = WindowStates::GameSession::Components::Controls.new \
        'pressed' => [],
        'released' => [],
        'held' => []
      
      drawable  = WindowStates::GameSession::Components::Drawable.new \
        'x' => 0,
        'y' => 0, 
        'z_order' => ZOrder::CHARACTER,
        'factor_x' => 1
        
      $drawable = drawable
      WindowStates::GameSession::Systems::Commands::PathStartSpawn.do entity_manager, entity, 'stage' => 'test_level'
            
      entity_manager.add_component entity, character
      entity_manager.add_component entity, controls
      entity_manager.add_component entity, drawable
      entity_manager.add_component entity, WindowStates::GameSession::Components::HitImmunities.new('hit_ids' => [])
            
      return entity
    end
  end
end