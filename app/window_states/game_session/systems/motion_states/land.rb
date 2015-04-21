module WindowStates::GameSession::Systems::MotionStates::Land
  extend WindowStates::GameSession::Systems::MotionState
  
  class << self
    def control_down entity_manager, entity, control, time
      case control
      when 'left'
        stats = character_stats entity_manager, entity
        transition_to_speed_point_10 entity_manager, entity, time,
          'speed_point_10'    => (stats['run_speed']*-1)*8/10,
          'duration'          => stats['run_transition_time'],
          'push_beyond_ledge' => true
      when 'right'
        stats = character_stats entity_manager, entity
        transition_to_speed_point_10 entity_manager, entity, time,
          'speed_point_10'    => (stats['run_speed']*1)*8/10,
          'duration'          => stats['run_transition_time'],
          'push_beyond_ledge' => true
      end
    end
  
    def control_up entity_manager, entity, control, time
      case control
      when 'left'
        #!!! check if right is down
        stats = character_stats entity_manager, entity
        transition_to_speed_point_10 entity_manager, entity, time,
          'speed_point_10'    => 0,
          'duration'          => stats['stop_transition_time'],
          'push_beyond_ledge' => true
      when 'right'
        #!!! check if left is down
        stats = character_stats entity_manager, entity
        transition_to_speed_point_10 entity_manager, entity, time,
          'speed_point_10'    => 0,
          'duration'          => stats['stop_transition_time'],
          'push_beyond_ledge' => true
      end
    end
    
    def set entity_manager, entity, time
      #change explicit
      stats     = character_stats entity_manager, entity
      character = entity_manager.get_component entity, :Character
      controls  = entity_manager.get_component entity, :Controls
      hit_shape_index      = character['stage_collisions']['path_movement']['hit_shape_index']
      start_point_index    = character['stage_collisions']['path_movement']['start_point_index']
      start_point_distance = character['stage_collisions']['path_movement']['start_point_distance']
    
      speed_x_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_x_point_10 entity_manager, entity, time
      speed_y_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_y_point_10 entity_manager, entity, time
      #change explicit
      entity_manager.remove_component entity, :FreeMotionX
      entity_manager.remove_component entity, :FreeMotionY
    
      WindowStates::GameSession::Systems::Commands::PathStartSet.do entity_manager, entity, \
      'shape_index'          => hit_shape_index,
      'start_point_index'    => start_point_index,
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
    
      #change explicit
      entity_manager.add_component entity, WindowStates::GameSession::Components::PathMotionContinuous.new(
        'id'                   => 0,
        'start_time'           => time,
        'start_speed_point_10' => start_speed_point_10,
        'end_speed_point_10'   => 0,
        'duration'             => 60
      )
      
      #change explicit
      ## Move if direction key held
      
      left_or_right = controls.held.select { |control| ['left', 'right'].include? control }
      if left_or_right.last
        factor_x = left_or_right.last == 'right' ? 1 : -1
        transition_to_speed_point_10 entity_manager, entity, time,
          'speed_point_10'    => stats['run_speed']*factor_x*8/10,
          'duration'          => stats['run_transition_time'],
          'push_beyond_ledge' => true
      else
        transition_to_speed_point_10 entity_manager, entity, time,
          'speed_point_10'    => 0,
          'duration'          => stats['stop_transition_time'],
          'push_beyond_ledge' => true
      end
    end
  end
end