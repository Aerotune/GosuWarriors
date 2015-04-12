class WindowStates::GameSession::Components::FreeMotionY < Component
  has_attributes %w[
    start_time
    start_y
    start_speed_point_10
    end_speed_point_10
    transition_time
    easer
  ]
end