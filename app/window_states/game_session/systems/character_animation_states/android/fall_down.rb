WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    character.queued_animation_state = 'idle'
    WindowStates::GameSession::Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, 'jump_fall'],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
        
    _stats = stats(entity)
    
    path_start = @entity_manager.get_component entity, :PathStart
    speed_point_10 = WindowStates::GameSession::SystemHelpers::PathMotion.speed_point_10 @entity_manager, entity, time
    
    if path_start
      _surface_length, axis_x_point_12, axis_y_point_12 = WindowStates::GameSession::SystemHelpers::PathMotion.axis_point_12 @entity_manager, entity, time, $stage
      factor_x = speed_point_10 < 0 ? -1 : 1
    
      drawable.x += 7*factor_x
      drawable.y -= 1
      set_free_motion entity, time, drawable.x, drawable.y
      start_speed_y = (axis_y_point_12*speed_point_10)>>12
      
      
      if start_speed_y < (-24_000/5)
        free_motion_y entity, time, \
          'start_speed_point_10' => start_speed_y*8/10, 
          'end_speed_point_10' => 19_500,
          'transition_time' => 45,
          'easer' => 'sin_in'
      else
        free_motion_y entity, time, \
          'start_speed_point_10' => start_speed_y, 
          'end_speed_point_10' => 19_500,
          'transition_time' => 30,
          'easer' => 'sin_in'
      end
      
      
      start_speed_x = (axis_x_point_12*speed_point_10)>>12
      start_speed_x *= -1 if axis_x_point_12 < 0 && speed_point_10 < 0
      
      if start_speed_x > 0
        start_speed_x = 3_072 if start_speed_x < 3_072
      else
        start_speed_x = -3_072 if start_speed_x > -3_072
      end
    
      free_motion_x entity, time, \
        'start_speed_point_10' => start_speed_x*8/10, 
        'end_speed_point_10' => 0,
        'transition_time' => 5_0,
        'easer' => 'sin_in'
    
      controls = @entity_manager.get_component entity, :Controls
      left_or_right = controls.held.select { |control| ['left', 'right'].include? control }
      case left_or_right.last
      when 'left'
        float_speed entity, time, -1
      when 'right'
        float_speed entity, time, 1
      end
      
    else
      puts "WHOA"
      puts "path_start: #{path_start}"
      puts "speed_point_10: #{speed_point_10}"
      
      
      set_free_motion entity, time, drawable.x, drawable.y
      free_motion_y entity, time, \
        'start_speed_point_10' => 0, 
        'end_speed_point_10' => 19_500,
        'transition_time' => 40,
        'easer' => 'sin_in'
    
      free_motion_x entity, time, \
        'start_speed_point_10' => 0, 
        'end_speed_point_10' => 0,
        'transition_time' => 5_0,
        'easer' => 'sin_in'
    
      controls = @entity_manager.get_component entity, :Controls
      left_or_right = controls.held.select { |control| ['left', 'right'].include? control }
      case left_or_right.last
      when 'left'
        float_speed entity, time, -1
      when 'right'
        float_speed entity, time, 1
      end
      
    end
    
  end
  
  def control_down entity, control, time
    case control
    when 'left'
      float_speed entity, time, -1
    when 'right'
      float_speed entity, time, 1
    when 'attack'
      character = @entity_manager.get_component entity, :Character
      controls = @entity_manager.get_component entity, :Controls
      if controls.held.include? 'up'
        character.set_animation_state = 'air_kick'
      else
        character.set_animation_state = 'air_spin'
      end
    when 'jump'
      _free_motion_y = @entity_manager.get_component(entity, :FreeMotionY)
      character = @entity_manager.get_component entity, :Character
      if character['cooldown']['jump_in_air'] == false
        character.set_animation_state = 'jump_in_air' #if _free_motion_y # !!! jump_in_air.rb:87 crashed because of no FreeMotionY
      end
    end
  end
  
  def control_up entity, control, time
    controls = @entity_manager.get_component entity, :Controls
    case control
    when 'right'
      if controls.held.detect { |control| control == 'left' }
        float_speed entity, time, -1
      else
        float_speed entity, time, 0
      end
    when 'left'
      if controls.held.detect { |control| control == 'right' }
        float_speed entity, time, 1
      else
        float_speed entity, time, 0
      end
    end
  end
  
  def update entity, time
    sprite    = @entity_manager.get_component entity, :Sprite
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
  end
  
  def float_speed entity, time, factor_x
    speed_x_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_x_point_10 @entity_manager, entity, time
    _stats = stats(entity)
    free_motion_x entity, time, \
      'start_speed_point_10' => speed_x_point_10,
      'end_speed_point_10' => _stats['run_speed']*factor_x,
      'transition_time' => 5_0
  end
end