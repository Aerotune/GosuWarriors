module Easers::QuadraticInOut
  class << self
    def value_point_10 duration, time, start_value_point_10, end_value_point_10
      change_point_10 = end_value_point_10 - start_value_point_10
      half_duration = duration/2
      half_change  = change_point_10/2
      middle_value_point_10 = start_value_point_10 + half_change
      
      in_easer  = Easers::QuadraticIn.value_point_10(half_duration, time, start_value_point_10, middle_value_point_10)
      out_easer = Easers::QuadraticOut.value_point_10(half_duration, time-half_duration, 0, half_change)
      
      in_easer + out_easer
    end
    
    def value_progress_point_10 duration, time
      half_duration = duration/2
      in_easer  = Easers::QuadraticIn.value_progress_point_10(half_duration, time)
      out_easer = Easers::QuadraticOut.value_progress_point_10(half_duration, time - half_duration)
      (in_easer + out_easer) / 2
    end
    
    def integral_point_10 duration, time, start_value_point_10, end_value_point_10
      change_point_10 = end_value_point_10 - start_value_point_10
      half_duration = duration/2
      half_change  = change_point_10/2
      middle_value_point_10 = start_value_point_10 + half_change
      
      in_easer  = Easers::QuadraticIn.integral_point_10(half_duration, time, start_value_point_10, middle_value_point_10)
      out_easer = Easers::QuadraticOut.integral_point_10(half_duration, time-half_duration, 0, half_change)
      
      in_easer + out_easer
    end
    
    def derivative_point_10 duration, time, start_value_point_10, end_value_point_10
      change_point_10 = end_value_point_10 - start_value_point_10
      half_duration = duration/2
      half_change  = change_point_10/2
      middle_value_point_10 = start_value_point_10 + half_change
      
      if time > half_duration
        return Easers::QuadraticOut.derivative_point_10(half_duration, time-half_duration, 0, half_change)
      else
        return Easers::QuadraticIn.derivative_point_10(half_duration, time, start_value_point_10, middle_value_point_10)
      end      
    end
    
  end
end