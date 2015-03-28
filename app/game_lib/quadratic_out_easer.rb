module QuadraticOutEaser
  class << self
    def value_point_10 duration, time, start_value_point_10, end_value_point_10
      change_point_10 = end_value_point_10 - start_value_point_10
      start_value_point_10 + ((value_progress_point_10(duration, time) * change_point_10) >> 10)
    end
    
    def value_progress_point_10 duration, time
      if time >= duration
        (1 << 10)
      elsif time <= 0
        0
      else
        progress = ((time << 10) / duration) - (1 << 10)
        progress = (1 << 10) - ((progress * progress) >> 10)
        progress
      end
    end
    
    def integral_point_10 duration, time, start_value_point_10, end_value_point_10
      if time <= 0
        0
      else
        change_point_10 = end_value_point_10 - start_value_point_10
        
        if time >= duration
          integral_of_duration_point_10 = (change_point_10 * ((duration << 10) - (((duration**3) << 10) / (3*duration**2))) >> 10) + start_value_point_10 * duration
          integral_of_duration_point_10 + (time - duration) * end_value_point_10
        else
          (change_point_10 * (((time**2 << 10) / duration) - ((time**3 << 10) / (3*duration**2))) >> 10) +
          start_value_point_10 * time
        end
      end
    end
    
    def derivative_point_20 duration, time, start_value_point_10, end_value_point_10
      if time >= duration
        0
      elsif time < 0
        0
      else
        change_point_10 = end_value_point_10 - start_value_point_10
        ((-2 * change_point_10 * ((time << 10) / duration - (1 << 10))) / duration)
      end
    end
  end
end