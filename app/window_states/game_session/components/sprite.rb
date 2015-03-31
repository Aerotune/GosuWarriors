class WindowStates::GameSession::Components::Sprite < Component
  has_attributes %w[
    sprite_resource_path
    start_time
    current_time
    duration
    fps
    mode
    index
    start_index
    prev_index
    done
  ]
end