class WindowStates::GameSession::Components::PathMotionTween < Component
  has_attributes %w[
    distance
    duration
    start_time
    push_beyond_ledge
  ]
end
