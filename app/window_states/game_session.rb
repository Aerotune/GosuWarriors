class WindowStates::GameSession < WindowState
  def initialize
    @entity_manager  = EntityManager.new WindowStates::GameSession::Components
    @graphics_system = WindowStates::GameSession::Systems::Graphics.new @entity_manager
    @character_animation_states_system = WindowStates::GameSession::Systems::CharacterAnimationStates.new @entity_manager
    @controls_system = WindowStates::GameSession::Systems::Controls.new @entity_manager
    player_entity = WindowStates::GameSession::Factories::Character.build @entity_manager, @character_animation_states_system, 'sheriff', 'player'
    
    @session_timer = SessionTimer.new
    @session_timer.start
  end
  
  def key_down key
    @controls_system.key_down key
    #@character_animation_states_system.key_down key, @session_timer.frame
    case key
    when 'escape'
      $window.set_state :main_menu
    end
  end
  
  def key_up key
    @controls_system.key_up key
    #@character_animation_states_system.key_up key, @session_timer.frame
  end
  
  def update
    @session_timer.update_frame do |time, direction|
      case direction
      when 1
        @controls_system.update
        @character_animation_states_system.update time
        @graphics_system.update time
      when -1
        raise "Reversing time not supported yet."
      end
    end
  end
  
  def draw
    $window.fill 0xFF222222
    @graphics_system.draw
  end
end