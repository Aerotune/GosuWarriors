class WindowStates::GameSession::Components::FreeMotionX < Component
  has_attributes %w[
    start_time
    start_x
    start_speed_point_10
    end_speed_point_10
    transition_time
  ]
end