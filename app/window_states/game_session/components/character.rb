class WindowStates::GameSession::Components::Character < Component
  has_attributes %w[
    type
    control_type
    animation_state
    motion_state
    set_animation_state
    set_motion_state
    queued_animation_state
    stage_collisions
    cooldown
  ]
end