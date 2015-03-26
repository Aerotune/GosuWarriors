class WindowStates::GameSession < WindowState
  def initialize
    @entity_manager = EntityManager.new
    
    player_entity = @entity_manager.create_entity
    sprite = Components::Sprite.new(
      'sprite_resource_path' => %w[characters witch run],
      'fps' => 27,
      'start_time' => 0
    )
    @drawable = Components::Drawable.new(
      'draw_component' => sprite,
      'x' => 400,
      'y' => 400, 
      'z_order' => ZOrder::CHARACTER,
      'factor_x' => -1
    )
    
    @entity_manager.add_component player_entity, @drawable
    
    @graphics_system = Systems::Graphics.new @entity_manager
    @session_timer = SessionTimer.new
    @session_timer.start
  end
  
  def key_down key
    case key
    when 'escape'
      $window.set_state :main_menu
    end
  end
  
  def update
    @session_timer.update_frame do |time, direction|
      case direction
      when 1
        @graphics_system.update time
        @drawable.x = (time * 1) % $window.width
      when -1
        
      end
    end
  end
  
  def draw
    $window.fill 0xFF222222
    @graphics_system.draw
  end
end