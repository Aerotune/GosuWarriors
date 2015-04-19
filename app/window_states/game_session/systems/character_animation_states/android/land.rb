WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    land entity, time
    WindowStates::GameSession::Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
        
    controls = @entity_manager.get_component entity, :Controls
    #drawable = @entity_manager.get_component entity, :Drawable
    
    left_or_right = controls.held.select { |control| ['left', 'right'].include? control }
    if left_or_right.last
      factor_x = left_or_right.last == 'right' ? 1 : -1
      _stats = stats(entity)
      speed           = _stats['run_speed']*factor_x*8/10
      transition_time = _stats['run_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time, 'push_beyond_ledge' => true
    else
      _stats = stats(entity)
      speed           = 0
      transition_time = _stats['stop_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time, 'push_beyond_ledge' => true
    end
  end
  
  def control_down entity, control, time
    case control
    when 'left'
      _stats = stats(entity)
      speed           = (_stats['run_speed']*-1)*8/10
      transition_time = _stats['run_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time
    when 'right'
      _stats = stats(entity)
      speed           = (_stats['run_speed']*1)*8/10
      transition_time = _stats['run_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time
    end
  end
  
  def control_up entity, control, time
    case control
    when 'left'
      _stats = stats(entity)
      speed           = 0#(_stats['run_speed']*-1)*8/10 #!!! check if the other direction control is held
      transition_time = _stats['stop_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time
    when 'right'
      _stats = stats(entity)
      speed           = 0#(_stats['run_speed']*1)*8/10 #!!! check if the other direction control is held
      transition_time = _stats['stop_transition_time']
      transition_to_speed_point_10 entity, time, speed, transition_time
    end
  end
  
  def update entity, time
    sprite    = @entity_manager.get_component entity, :Sprite
    character = @entity_manager.get_component entity, :Character
    
    if sprite.done
      character.set_animation_state = 'idle'
    end
    
    character.set_animation_state = 'fall_down' if character['stage_collisions']['path_movement']['direction_beyond_ledge']
  end
  
  def land entity, time
    character = @entity_manager.get_component entity, :Character
    hit_shape_index = character['stage_collisions']['path_movement']['hit_shape_index']
    start_point_index = character['stage_collisions']['path_movement']['start_point_index']
    start_point_distance = character['stage_collisions']['path_movement']['start_point_distance']
    
    speed_x_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_x_point_10(@entity_manager, entity, time)
    speed_y_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_y_point_10(@entity_manager, entity, time)  
    #change explicit
    @entity_manager.remove_component entity, :FreeMotionX
    @entity_manager.remove_component entity, :FreeMotionY
    
    WindowStates::GameSession::Systems::Commands::PathStartSet.do @entity_manager, entity, \
    'shape_index' => hit_shape_index,
    'start_point_index' => start_point_index,
    'start_point_distance' => start_point_distance
    
    shape = $stage['shapes'][hit_shape_index]
    
    if start_point_distance == 0
      if speed_x_point_10 < 0
        point_1_index = (start_point_index - 1) % shape['outline'].length
        point_2_index = (start_point_index    ) % shape['outline'].length
      else
        point_1_index = (start_point_index    ) % shape['outline'].length
        point_2_index = (start_point_index + 1) % shape['outline'].length
      end
    elsif start_point_distance > 0
      point_1_index = (start_point_index    ) % shape['outline'].length
      point_2_index = (start_point_index + 1) % shape['outline'].length
    elsif start_point_distance < 0
      point_1_index = (start_point_index - 1) % shape['outline'].length
      point_2_index = (start_point_index    ) % shape['outline'].length
    end
    
    point_1 = shape['outline'][point_1_index]
    point_2 = shape['outline'][point_2_index]
    
    line_length, axis_x_point_12, axis_y_point_12 = ShapeHelper::Line.line_length_and_axis_point_12 point_1, point_2
    
    start_speed_point_10 = ((axis_x_point_12 * speed_x_point_10) >> 12)*8/10 + ((axis_y_point_12 * speed_y_point_10)>>12)
    
    @entity_manager.add_component entity, WindowStates::GameSession::Components::PathMotionContinuous.new(
      'id'                   => 0,
      'start_time'           => time,
      'start_speed_point_10' => start_speed_point_10,
      'end_speed_point_10'   => 0,
      'duration'             => 60
    )
  end
end