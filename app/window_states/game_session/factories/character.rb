module WindowStates::GameSession::Factories::Character
  class << self
    def build entity_manager, character_animation_states_system, character_type, control_type, set_animation_state="idle"
      entity = entity_manager.create_entity
      
      character = WindowStates::GameSession::Components::Character.new(
        'type' => character_type,
        'set_animation_state' => set_animation_state, 
        'control_type' => control_type
      )
      controls  = WindowStates::GameSession::Components::Controls.new(
        'pressed' => [],
        'released' => [],
        'held' => []
      )
      drawable  = WindowStates::GameSession::Components::Drawable.new(
        'x' => 400,
        'y' => 400, 
        'z_order' => ZOrder::CHARACTER,
        'factor_x' => 1
      )
      
      entity_manager.add_component entity, character
      entity_manager.add_component entity, controls
      entity_manager.add_component entity, drawable
            
      return entity
    end
  end
end