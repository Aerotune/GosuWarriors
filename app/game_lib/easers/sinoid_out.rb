module Easers::SinoidOut
#module SinoidOut
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
        radians_point_10 = time * IntMath::HALF_PI_POINT_10 / duration
        IntMath.sin_point_10(radians_point_10)
      end
    end
    
    def integral_point_10 duration, time, start_value_point_10, end_value_point_10
      if time <= 0
        0
      elsif time > duration
        change_point_10 = end_value_point_10 - start_value_point_10
        cos_point_10 = IntMath.cos_point_10(IntMath::HALF_PI_POINT_10)
        integral_of_duration = start_value_point_10 * duration - ((change_point_10 * cos_point_10) / IntMath::HALF_PI_POINT_10 * duration) + (change_point_10 * (1<<10) * duration / IntMath::HALF_PI_POINT_10)
        integral_of_duration + end_value_point_10 * time
      else
        change_point_10 = end_value_point_10 - start_value_point_10
        cos_point_10 = IntMath.cos_point_10(time * IntMath::HALF_PI_POINT_10 / duration)
        start_value_point_10 * time - ((change_point_10 * cos_point_10) / IntMath::HALF_PI_POINT_10 * duration) + (change_point_10 * (1<<10) * duration / IntMath::HALF_PI_POINT_10)
      end
    end
  
    def derivative_point_20 duration, time, start_value_point_10, end_value_point_10
      if time >= duration
        0
      elsif time < 0
        0
      else
        change_point_10 = end_value_point_10 - start_value_point_10
        cos_point_10 = IntMath.cos_point_10(time * IntMath::HALF_PI_POINT_10 / duration)
        ((((IntMath::HALF_PI_POINT_10 * change_point_10)>>10) * cos_point_10)>>10) / duration
      end
    end
    
  end # << self
end # module

#require_relative '../math/int_math'
#
#duration = 8
#
#(0..8).each do |time|
#  start_value_point_10 = 0#10_000
#  end_value_point_10 = 10000
#  puts "-----\ntime:#{time}"
#  p (SinoidOut.integral_point_10(duration, time, start_value_point_10, end_value_point_10) + SinoidOut.integral_point_10(duration, time+1, start_value_point_10, end_value_point_10))/2
#  
#  sum = 0
#  (0..time).each do |t|
#    sum += SinoidOut.value_point_10(duration, t, start_value_point_10, end_value_point_10)
#  end
#  p sum
#  #p d
#  
#end


#sum = 0
#3000.times do |i|
#  sum += SinoidIn.value_point_10(100, i, 100, 200)
#end
#p sum
#p SinoidIn.integral_point_10(100, 3000, 100, 200)
#puts "----"
#puts (SinoidIn.value_point_10(30, 20, 100, 12000) - SinoidIn.value_point_10(30, 18, 100, 12000))/3
#puts SinoidIn.derivative_point_20(30, 20, 100, 12000) >> 10