module IntMath
  require_relative 'int_math_constants'
  
  HALF_PI_POINT_10 = 1608
  PI_POINT_10 = 3217
  TAU_POINT_10 = 6434
  
  class << self
    def distance x1, y1, x2, y2
      sqrt((x2-x1)**2 + (y2-y1)**2)
    end
    
    def sqrt n
      if n == 0
        return 0
      elsif n < 0
        raise Math::DomainError, "Numerical argument is out of domain. Can't take square root of negative number."
      end
      x = 2**(n.to_s(2).length/2 + 1)
      loop do
        y = (x + (n/x)) / 2
        return x if y >= x
        x = y 
      end
    end
    
    def sin_point_10 radians_point_10
      n = ((radians_point_10 % TAU_POINT_10) * 256)
      progress = n % TAU_POINT_10
      index1   = n / TAU_POINT_10
      index2   = (index1 + 1) % 256
      sin1_point_10 = SIN_TABLE_POINT_10[index1]
      sin2_point_10 = SIN_TABLE_POINT_10[index2]
      
      ((sin1_point_10) * (TAU_POINT_10-progress) + PI_POINT_10) / TAU_POINT_10 + ((sin2_point_10 * progress) + PI_POINT_10) / TAU_POINT_10
    end
  
    def cos_point_10 radians_point_10
      n = ((radians_point_10 % TAU_POINT_10) * 256)
      progress = n % TAU_POINT_10
      index1   = n / TAU_POINT_10
      index2   = (index1 + 1) % 256
      cos1_point_10 = COS_TABLE_POINT_10[index1]
      cos2_point_10 = COS_TABLE_POINT_10[index2]
      
      ((cos1_point_10) * (TAU_POINT_10-progress) + PI_POINT_10) / TAU_POINT_10 + ((cos2_point_10 * progress) + PI_POINT_10) / TAU_POINT_10
    end
    
    def shortest_angle_between_point_10 radians_1_point_10, radians_2_point_10
      delta_radians_point_10 = radians_2_point_10 - radians_1_point_10

      sin = sin_point_10(delta_radians_point_10)
      cos = cos_point_10(delta_radians_point_10)
      
      atan2_point_10(sin, cos)
    end
    
    def atan2_point_10 y, x
      if x > 0
        return atan_point_10((y << 20) / (x << 10))
      elsif x < 0
        if y < 0
          return atan_point_10((y << 20) / (x << 10)) - PI_POINT_10
        else
          return atan_point_10((y << 20) / (x << 10)) + PI_POINT_10
        end
      elsif x == 0
        if y < 0
          return -HALF_PI_POINT_10
        else
          return HALF_PI_POINT_10
        end
      end      
    end
    
    def atan_point_10 y_over_x_point_10      
      factor     = y_over_x_point_10 >= 0 ? 1 : -1
      n          = y_over_x_point_10.abs * 8
      progress   = n % TAU_POINT_10
      index1     = n / TAU_POINT_10
      index2     = index1 + 1
      last_index = ATAN_TABLE_POINT_10.length-1
      
      if index2 > last_index
        extension = index1 - last_index
        result = ATAN_TABLE_POINT_10.last + 1 + (extension >> 6)
        result = PI_POINT_10/2 if result > PI_POINT_10/2
      else
        atan1_point_10 = ATAN_TABLE_POINT_10[index1]
        atan2_point_10 = ATAN_TABLE_POINT_10[index2]
        
        result = ((atan1_point_10) * (TAU_POINT_10 - progress) + PI_POINT_10) / TAU_POINT_10 + ((atan2_point_10 * progress) + PI_POINT_10) / TAU_POINT_10
      end
      
      result * factor
    end
    
    def ln_cosh_point_10 x_point_10
      progress = x_point_10 % (1<<10)
      index1 = (x_point_10 * 64) >> 10
      index2 = index1 + 1
      last_index = LN_COSH_TABLE_POINT_10.length-1
      
      if index2 > last_index
        extension = index1 - last_index
        result = LN_COSH_TABLE_POINT_10.last + extension * 16 + ((progress * 16)>>10)
      else
        ln_cosh1 = LN_COSH_TABLE_POINT_10[index1]
        ln_cosh2 = LN_COSH_TABLE_POINT_10[index2]
        result = (((ln_cosh1) * ((1<<10) - progress) + (1<<9)) >> 10) + (((ln_cosh2 * progress) + (1<<9)) >> 10)
      end
      
      result
    end
    
    def rotate_vector x, y, radians_point_10
      sin_point_10 = self.sin_point_10(radians_point_10)
      cos_point_10 = self.cos_point_10(radians_point_10)
      rotated_x = -((   ((-x) * cos_point_10) - ((y) * sin_point_10)   ) >> 10)
      rotated_y = -((   ((-y) * cos_point_10) + ((x) * sin_point_10)   ) >> 10)
      return rotated_x, rotated_y
    end
    
    def rotate_vector_around_point x, y, around_x, around_y, radians_point_10
      sin_point_10 = self.sin_point_10(radians_point_10)
      cos_point_10 = self.cos_point_10(radians_point_10)
      rotated_x = around_x - ((   ((around_x - x) * cos_point_10) - ((y - around_y) * sin_point_10)   ) >> 10)
      rotated_y = around_y - ((   ((around_y - y) * cos_point_10) + ((x - around_x) * sin_point_10)   ) >> 10)
      return rotated_x, rotated_y
    end
    
    def rotate_and_scale_vector_around_point x, y, around_x, around_y, radians_point_10, factor_x_point_10, factor_y_point_10
      sin_point_10 = self.sin_point_10(radians_point_10)
      cos_point_10 = self.cos_point_10(radians_point_10)
      result_x = around_x - ((   (((around_x - x) * cos_point_10) - ((y - around_y) * sin_point_10)) * factor_x_point_10   ) >> 20)
      result_y = around_y - ((   (((around_y - y) * cos_point_10) + ((x - around_x) * sin_point_10)) * factor_y_point_10   ) >> 20)
      return result_x, result_y
    end
    
    def scale_and_rotate_vector_around_point x, y, around_x, around_y, radians_point_10, factor_x_point_10, factor_y_point_10
      sin_point_10 = self.sin_point_10(radians_point_10)
      cos_point_10 = self.cos_point_10(radians_point_10)
      result_x = around_x - ((   (((around_x - x) * cos_point_10 * factor_x_point_10) - ((y - around_y) * sin_point_10 * factor_y_point_10))   ) >> 20)
      result_y = around_y - ((   (((around_y - y) * cos_point_10 * factor_y_point_10) + ((x - around_x) * sin_point_10 * factor_x_point_10))   ) >> 20)
      return result_x, result_y
    end
  end
end