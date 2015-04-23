class WindowStates::GameSession < WindowState
  attr_reader :stage, :entity_manager
  
  def initialize character_name
    $window.scoreboard['targets'] = 0
    $window.scoreboard['time']    = 0 
    @stage                             = Resources::Stages['test_level']
    @entity_manager                    = EntityManager.new WindowStates::GameSession::Components
    @graphics_system                   = WindowStates::GameSession::Systems::Graphics.new                 self
    @character_animation_states_system = WindowStates::GameSession::Systems::CharacterAnimationStates.new self
    @controls_system                   = WindowStates::GameSession::Systems::Controls.new                 self
    @path_motion_system                = WindowStates::GameSession::Systems::PathMotion.new               self
    @free_motion_system                = WindowStates::GameSession::Systems::FreeMotion.new               self
    @hits_system                       = WindowStates::GameSession::Systems::Hits.new                     self
    @character_stage_collision_system  = WindowStates::GameSession::Systems::CharacterStageCollisionSystem.new self
    player_entity = WindowStates::GameSession::Factories::Character.build self, @character_animation_states_system, character_name, 'player'
    WindowStates::GameSession::Factories::Target.build self, 150, 370
    WindowStates::GameSession::Factories::Target.build self, 1280+100, 320
    WindowStates::GameSession::Factories::Target.build self, 1280-305, 370
    
    @font = Resources::Fonts[:Arial24]
    
    @session_timer = SessionTimer.new
    @session_timer.start
    
    
    #@current_shape = @stage['shapes'][0]
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
    
    $window.scoreboard['time'] = @time if $window.scoreboard['targets'] < 3
    
    updates_latest_frame
  end
  
  def updates_latest_frame
    
    
    ## Make an on enter frame event for this:
    
    
  end
  
  def updates_every_frame
    @graphics_system                    .update_each_frame @time
    @free_motion_system                 .update @time
    @character_stage_collision_system   .update @time
    @character_animation_states_system  .update @time
    @path_motion_system                 .update @time    
    @graphics_system                    .update @time
    @hits_system                        .update @time
    @controls_system.update
  end
  
  def draw
    $window.fill 0xFF222222
    zoom = 1.0
    $window.scale zoom, zoom, $window.width/2, $window.height/2 do
      $window.translate -$drawable.x+$window.width/2, -$drawable.y+$window.height*2/3 do
        @stage['shapes'].each do |shape|
          ShapeHelper::WalkRender.draw_non_walkable shape, 0xFFFF0000
          ShapeHelper::WalkRender.draw_walkable shape, 0xFF00FF00
        end
        @graphics_system.draw
      end
    end
    time = Time.at($window.scoreboard['time']/60.0).strftime("%M:%S:%L")
    @font.draw_rel time, $window.width-24, 24, Z, 1.0, 0.0
  end
end