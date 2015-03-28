class WindowStates::GameSession::Components::PathMotionContinuous < Component
  has_attributes %w[
    distance
    start_time
    start_speed_point_10
    end_speed_point_10
    duration
  ]
end