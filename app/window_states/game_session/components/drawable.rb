class WindowStates::GameSession::Components::Drawable < Component
  has_attributes %w[
    x
    y
    z_order
    factor_x
    prev_x
    prev_y
  ]
end