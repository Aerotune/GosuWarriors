module WindowStates::GameSession::SystemHelpers::FreeMotion
  class << self
    #def position entity_manager, entity, time
    #  free_motion = entity_manager.get_component entity, :FreeMotion
    #  drawable    = entity_manager.get_component entity, :Drawable
    #  
    #  current_time = time - free_motion['start_time']
    #  
    #  dx_point_10 = QuadraticOutEaser.integral_point_10 free_motion['transition_time_x'], current_time, free_motion['start_speed_x_point_10'], free_motion['end_speed_x_point_10']
    #  dy_point_10 = QuadraticOutEaser.integral_point_10 free_motion['transition_time_y'], current_time, free_motion['start_speed_y_point_10'], free_motion['end_speed_y_point_10']
    #  
    #  x = free_motion['start_x'] + (dx_point_10 >> 10)
    #  y = free_motion['start_y'] + (dy_point_10 >> 10)
    #  
    #  return x, y
    #end
    
    def x entity_manager, entity, time
      free_motion_x = entity_manager.get_component entity, :FreeMotionX
      current_time = time - free_motion_x['start_time']
      dx_point_10 = QuadraticOutEaser.integral_point_10 free_motion_x['transition_time'], current_time, free_motion_x['start_speed_point_10'], free_motion_x['end_speed_point_10']
      free_motion_x['start_x'] + (dx_point_10 >> 10)
    end
    
    def y entity_manager, entity, time
      free_motion_y = entity_manager.get_component entity, :FreeMotionY
      current_time = time - free_motion_y['start_time']
      dy_point_10 = QuadraticOutEaser.integral_point_10 free_motion_y['transition_time'], current_time, free_motion_y['start_speed_point_10'], free_motion_y['end_speed_point_10']
      free_motion_y['start_y'] + (dy_point_10 >> 10)
    end
    
    def speed_x_point_10 entity_manager, entity, time
      free_motion_x = entity_manager.get_component entity, :FreeMotionX
      
      return 0 unless free_motion_x
      
      current_time = time - free_motion_x['start_time']
      
      QuadraticOutEaser.value_point_10 free_motion_x['transition_time'], current_time, free_motion_x['start_speed_point_10'], free_motion_x['end_speed_point_10']
    end
    
    def speed_y_point_10 entity_manager, entity, time
      free_motion_y = entity_manager.get_component entity, :FreeMotionY
      
      return 0 unless free_motion_y
      
      current_time = time - free_motion_y['start_time']
      
      QuadraticOutEaser.value_point_10 free_motion_y['transition_time'], current_time, free_motion_y['start_speed_point_10'], free_motion_y['end_speed_point_10']
    end
  end
end