class WindowStates::GameSession::Components::FreeMotion < Component
  has_attributes %w[
    start_time
    start_x
    start_y
    start_speed_x_point_10
    start_speed_y_point_10
    end_speed_x_point_10
    end_speed_y_point_10
    transition_time_x
    transition_time_y
  ]
end