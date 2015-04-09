class WindowStates::GameSession::Components::PathStart < Component
  has_attributes %w[
    id
    shape_index
    start_point_index
    distance
    surface_only
  ]
end