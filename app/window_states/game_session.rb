class WindowStates::GameSession < WindowState
  def initialize character_name
    @entity_manager                    = EntityManager.new WindowStates::GameSession::Components
    @graphics_system                   = WindowStates::GameSession::Systems::Graphics.new                 @entity_manager
    @character_animation_states_system = WindowStates::GameSession::Systems::CharacterAnimationStates.new @entity_manager
    @controls_system                   = WindowStates::GameSession::Systems::Controls.new                 @entity_manager
    @path_motion_system                = WindowStates::GameSession::Systems::PathMotion.new               @entity_manager
    @hits_system                       = WindowStates::GameSession::Systems::Hits.new                     @entity_manager
    player_entity = WindowStates::GameSession::Factories::Character.build @entity_manager, @character_animation_states_system, character_name, 'player'
    WindowStates::GameSession::Factories::Target.build @entity_manager, 150, 350
    WindowStates::GameSession::Factories::Target.build @entity_manager, $window.width-150, 350
    WindowStates::GameSession::Factories::Target.build @entity_manager, $window.width-305, 350
    
    @session_timer = SessionTimer.new
    @session_timer.start
  end
  
  def key_down key
    @controls_system.key_down key

    case key
    when 'escape'
      $window.set_state WindowStates::CharacterSelect.new
    end
  end
  
  def key_up key
    @controls_system.key_up key
  end
  
  def update
    times = []
    
    @session_timer.update_frame do |time, direction|
      case direction
      when 1
        times << time
      when -1 
        raise "Reversing time not supported yet."
      end
    end
    
    times.each do |time|
      @time = time
      updates_every_frame
    end
    
    updates_latest_frame
  end
  
  def updates_latest_frame
    @controls_system                    .update
    @path_motion_system                 .update @time    
    @graphics_system                    .update @time
    @hits_system                        .update @time
    @character_animation_states_system  .update @time
    ## Make an on enter frame event for this:
    
    
  end
  
  def updates_every_frame
    
  end
  
  def draw
    $window.fill 0xFF222222
    @graphics_system.draw
  end
end