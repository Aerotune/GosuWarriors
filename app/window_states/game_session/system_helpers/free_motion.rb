module WindowStates::GameSession::SystemHelpers::FreeMotion
  class << self
    def position entity_manager, entity, time
      free_motion = entity_manager.get_component entity, :FreeMotion
      drawable    = entity_manager.get_component entity, :Drawable
      
      current_time = time - free_motion['start_time']
      
      dx_point_10 = QuadraticOutEaser.integral_point_10 free_motion['transition_time_x'], current_time, free_motion['start_speed_x_point_10'], free_motion['end_speed_x_point_10']
      dy_point_10 = QuadraticOutEaser.integral_point_10 free_motion['transition_time_y'], current_time, free_motion['start_speed_y_point_10'], free_motion['end_speed_y_point_10']
      
      x = free_motion['start_x'] + (dx_point_10 >> 10)
      y = free_motion['start_y'] + (dy_point_10 >> 10)
      
      return x, y
    end
    
    def speed_point_10 entity_manager, entity, time
      free_motion = entity_manager.get_component entity, :FreeMotion
      drawable    = entity_manager.get_component entity, :Drawable
      
      return 0, 0 unless free_motion
      
      current_time = time - free_motion['start_time']
      
      speed_x_point_10 = QuadraticOutEaser.value_point_10 free_motion['transition_time_x'], current_time, free_motion['start_speed_x_point_10'], free_motion['end_speed_x_point_10']
      speed_y_point_10 = QuadraticOutEaser.value_point_10 free_motion['transition_time_y'], current_time, free_motion['start_speed_y_point_10'], free_motion['end_speed_y_point_10']
      
      return speed_x_point_10, speed_y_point_10
    end
  end
end