class WindowStates::GameSession::Components::Character < Component
  has_attributes %w[
    type
    control_type
    animation_state
    set_animation_state
  ]
end