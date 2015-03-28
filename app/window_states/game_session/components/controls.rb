class WindowStates::GameSession::Components::Controls < Component
  has_attributes %w[
    held
    pressed
    released
  ]
end