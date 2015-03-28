class WindowStates::GameSession < WindowState
  def initialize
    @entity_manager                    = EntityManager.new WindowStates::GameSession::Components
    @graphics_system                   = WindowStates::GameSession::Systems::Graphics.new                 @entity_manager
    @character_animation_states_system = WindowStates::GameSession::Systems::CharacterAnimationStates.new @entity_manager
    @controls_system                   = WindowStates::GameSession::Systems::Controls.new                 @entity_manager
    @path_motion_system                = WindowStates::GameSession::Systems::PathMotion.new               @entity_manager
    
    player_entity = WindowStates::GameSession::Factories::Character.build @entity_manager, @character_animation_states_system, 'android', 'player'
    
    @session_timer = SessionTimer.new
    @session_timer.start
  end
  
  def key_down key
    @controls_system.key_down key

    case key
    when 'escape'
      $window.set_state :main_menu
    end
  end
  
  def key_up key
    @controls_system.key_up key
  end
  
  def update
    @session_timer.update_frame do |time, direction|
      case direction
      when 1
        @time = time
        #@time_factor = 1
        updates_every_frame
      when -1
        @time = time
        #@time_factor = -1
        raise "Reversing time not supported yet."
      end
    end
    
    updates_latest_frame
  end
  
  def updates_latest_frame
    @controls_system                    .update
    @path_motion_system                 .update @time
    @character_animation_states_system  .update @time
    @graphics_system                    .update @time
  end
  
  def updates_every_frame
    
  end
  
  def draw
    $window.fill 0xFF222222
    @graphics_system.draw
  end
end