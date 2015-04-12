module Easers::QuadraticIn
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
        progress = (time << 10) / duration
        progress = (progress*progress) >> 10
        progress
      end
    end
    
    def integral_point_10 duration, time, start_value_point_10, end_value_point_10
      if time <= 0
        0
      else
        change_point_10 = end_value_point_10 - start_value_point_10
      
        if time >= duration
          integral_of_duration_point_10 = (change_point_10 * (duration*duration*duration)) / (3 * duration * duration) + (start_value_point_10 * duration)
          integral_of_duration_point_10 + (time - duration) * end_value_point_10
        else
          ((change_point_10 * (time*time*time)) / (3 * duration * duration)) + (start_value_point_10 * time)
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
        (2 * change_point_10 * time) / (duration * duration)
      end
    end
    
  end # << self
end # module