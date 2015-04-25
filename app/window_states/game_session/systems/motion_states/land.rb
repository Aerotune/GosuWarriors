module Systems::MotionStates::Land
  extend Systems::MotionState
  
  class << self
    def control_down game_session, entity, control, time
      entity_manager = game_session.entity_manager
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
  
    def control_up game_session, entity, control, time
      entity_manager = game_session.entity_manager
      controls = entity_manager.get_component entity, :Controls
      case control
      when 'left'
        if controls.held.include? 'right'
          control_down game_session, entity, 'right', time
        else
          stats = character_stats entity_manager, entity
          transition_to_speed_point_10 entity_manager, entity, time,
            'speed_point_10'    => 0,
            'duration'          => stats['stop_transition_time'],
            'push_beyond_ledge' => true
        end
      when 'right'
        if controls.held.include? 'left'
          control_down game_session, entity, 'left', time
        else
          stats = character_stats entity_manager, entity
          transition_to_speed_point_10 entity_manager, entity, time,
            'speed_point_10'    => 0,
            'duration'          => stats['stop_transition_time'],
            'push_beyond_ledge' => true
        end
      end
    end
    
    def set game_session, entity, time
      #change explicit
      stage          = game_session.stage
      entity_manager = game_session.entity_manager
      stats     = character_stats entity_manager, entity
      character = entity_manager.get_component entity, :Character
      controls  = entity_manager.get_component entity, :Controls
      hit_shape_index      = character['stage_collisions']['path_movement']['hit_shape_index']
      start_point_index    = character['stage_collisions']['path_movement']['start_point_index']
      start_point_distance = character['stage_collisions']['path_movement']['start_point_distance']
      character['stage_collisions']['path_movement'].clear
    
      speed_x_point_10 = SystemHelpers::FreeMotion.speed_x_point_10 entity_manager, entity, time
      speed_y_point_10 = SystemHelpers::FreeMotion.speed_y_point_10 entity_manager, entity, time
      #change explicit
      entity_manager.remove_component entity, :FreeMotionX
      entity_manager.remove_component entity, :FreeMotionY
    
      Systems::Commands::PathStartSet.do entity_manager, entity, \
      'shape_index'          => hit_shape_index,
      'start_point_index'    => start_point_index,
      'start_point_distance' => start_point_distance
    
      shape = stage['shapes'][hit_shape_index]
    
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
      left_or_right = controls.held.select { |control| ['left', 'right'].include? control }
      if left_or_right.last
        control_down game_session, entity, left_or_right.last, time
      else
        transition_to_speed_point_10 entity_manager, entity, time,
          'speed_point_10'    => 0,
          'duration'          => stats['stop_transition_time'],
          'push_beyond_ledge' => true
      end
    end
  end
end