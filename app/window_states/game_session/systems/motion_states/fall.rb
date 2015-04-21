module WindowStates::GameSession::Systems::MotionStates::Fall
  extend WindowStates::GameSession::Systems::MotionState
  class << self
    def set entity_manager, entity, time
      stats = character_stats entity_manager, entity
      drawable       = entity_manager.get_component entity, :Drawable
      path_start     = entity_manager.get_component entity, :PathStart
      character      = entity_manager.get_component entity, :Character
            
      speed_point_10 = WindowStates::GameSession::SystemHelpers::PathMotion.speed_point_10 entity_manager, entity, time
      
      if path_start
        _surface_length, axis_x_point_12, axis_y_point_12 = WindowStates::GameSession::SystemHelpers::PathMotion.axis_point_12 entity_manager, entity, time, $stage
        factor_x = character['stage_collisions']['path_movement']['direction_beyond_ledge'] || 0
        
        
        drawable.x += 5*factor_x
        drawable.y -= 1
        drawable.prev_x = drawable.x
        drawable.prev_y = drawable.y
        set_free_motion entity_manager, entity, time, drawable.x, drawable.y-2
        start_speed_y = (axis_y_point_12*speed_point_10)>>12
        
        
        if start_speed_y < (-24_000/5)
          free_motion_y entity_manager, entity, time, \
            'start_speed_point_10' => start_speed_y*8/10, 
            'end_speed_point_10' => 19_500,
            'transition_time' => 45,
            'easer' => 'sin_in'
        else
          free_motion_y entity_manager, entity, time, \
            'start_speed_point_10' => start_speed_y, 
            'end_speed_point_10' => 19_500,
            'transition_time' => 30,
            'easer' => 'sin_in'
        end
        
        
        start_speed_x = (axis_x_point_12*speed_point_10)>>12
        start_speed_x *= -1 if axis_x_point_12 < 0 && speed_point_10 < 0
        
        if factor_x > 0
          start_speed_x = 3_072 if start_speed_x < 3_072
        elsif factor_x < 0
          start_speed_x = -3_072 if start_speed_x > -3_072
        end
      
        free_motion_x entity_manager, entity, time, \
          'start_speed_point_10' => start_speed_x*8/10, 
          'end_speed_point_10' => 0,
          'transition_time' => 5_0,
          'easer' => 'sin_in'
      
        controls = entity_manager.get_component entity, :Controls
        left_or_right = controls.held.select { |control| ['left', 'right'].include? control }
        case left_or_right.last
        when 'left'
          float_speed entity_manager, entity, time, -1
        when 'right'
          float_speed entity_manager, entity, time, 1
        end
        
      else
        warn "No path start before falling"
        puts "path_start: #{path_start}"
        puts "speed_point_10: #{speed_point_10}"
        
        
        #set_free_motion entity_manager, entity, time, drawable.x, drawable.y-2
        #free_motion_y entity_manager, entity, time, \
        #  'start_speed_point_10' => 0, 
        #  'end_speed_point_10' => 19_500,
        #  'transition_time' => 40,
        #  'easer' => 'sin_in'
        #
        #free_motion_x entity_manager, entity, time, \
        #  'start_speed_point_10' => 0, 
        #  'end_speed_point_10' => 0,
        #  'transition_time' => 5_0,
        #  'easer' => 'sin_in'
        #
        #controls = entity_manager.get_component entity, :Controls
        #left_or_right = controls.held.select { |control| ['left', 'right'].include? control }
        #case left_or_right.last
        #when 'left'
        #  float_speed entity_manager, entity, time, -1
        #when 'right'
        #  float_speed entity_manager, entity, time, 1
        #end
        
      end
    end
  end
end