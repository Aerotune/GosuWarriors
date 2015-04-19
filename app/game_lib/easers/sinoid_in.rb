module Easers::SinoidIn
  class << self
    def value_point_10 duration, time, start_value_point_10, end_value_point_10
      change_point_10 = end_value_point_10 - start_value_point_10
      start_value_point_10 + ((value_progress_point_10(duration, time) * change_point_10) >> 10)
    end
    
    def value_progress_point_10 duration, time
      if time >= duration
        1 << 10
      elsif time <= 0
        0
      else
        radians_point_10 = (time * IntMath::HALF_PI_POINT_10) / duration
        (1 << 10) - IntMath.cos_point_10(radians_point_10)
      end
    end
    
    def integral_point_10 duration, time, start_value_point_10, end_value_point_10
      if time <= 0
        0
      else
        change_point_10 = end_value_point_10 - start_value_point_10
      
        if time >= duration
          sin_point_10 = IntMath.sin_point_10(IntMath::HALF_PI_POINT_10)
          integral_of_duration_point_10 = change_point_10 * (duration - (2*duration*sin_point_10) / IntMath::PI_POINT_10) + start_value_point_10 * duration
          integral_of_duration_point_10 + (time - duration) * end_value_point_10
        else
          sin_point_10 = IntMath.sin_point_10(time * IntMath::HALF_PI_POINT_10 / duration)
          (change_point_10 * time) - ((change_point_10*duration*sin_point_10) / IntMath::HALF_PI_POINT_10) + start_value_point_10 * time
        end
      end
    end
  
    def derivative_point_20 duration, time, start_value_point_10, end_value_point_10
      if time >= duration
        0
      elsif time < 0
        0
      else
        sin_point_10 = IntMath.sin_point_10(time * IntMath::HALF_PI_POINT_10 / duration)
        change_point_10 = end_value_point_10 - start_value_point_10
        ((((IntMath::HALF_PI_POINT_10 * change_point_10)>>10) * sin_point_10)>>10) / duration
      end
    end
    
  end # << self
end # module