class WindowStates::GameSession::Components::Character < Component
  attr_reader :type
  attr_accessor :control_type, :animation_state, :set_animation_state
  
  def initialize type, set_animation_state, control_type
    @type                = type
    @set_animation_state = set_animation_state
    @control_type        = control_type
  end
end