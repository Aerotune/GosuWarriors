module IntMath
  # the unit rotation_point_12 is CCW from 0..4096
  # 4096 is 360 degrees
  # 0 is right
  # 1024 is up
  # 1536 is left
  
  require_relative 'int_math_constants'
  
  QUARTER_CIRCLE_POINT_12 = 1024
  HALF_CIRCLE_POINT_12    = 2048
  CIRCLE_POINT_12         = 4096
  
  class << self
    def distance x1, y1, x2, y2
      sqrt((x2-x1)**2 + (y2-y1)**2)
    end
    
    def sqrt n
      x = 2**(n.to_s(2).length/2 + 1)
      loop do
        y = (x + (n/x)) / 2
        return x if y >= x
        x = y 
      end
    end
    
    def sin_point_16 rotation_point_12
      SIN_TABLE_POINT_16[rotation_point_12%4096]
    end
  
    def cos_point_16 rotation_point_12
      COS_TABLE_POINT_16[rotation_point_12%4096]
    end
    
    def shortest_angle_point_12_between start_angle_point_12, dest_angle_point_12
      delta_angle_point_12 = dest_angle_point_12 - start_angle_point_12

      sin = sin_point_16(delta_angle_point_12)
      cos = cos_point_16(delta_angle_point_12)
      
      atan2_point_12(sin, cos)
    end
    
    def atan2_point_12 y, x
      if x > 0
        return atan_point_12((y << 24) / (x << 12))
      elsif x < 0
        if y < 0
          return atan_point_12((y << 24) / (x << 12)) - HALF_CIRCLE_POINT_12
        else
          return atan_point_12((y << 24) / (x << 12)) + HALF_CIRCLE_POINT_12
        end
      elsif x == 0
        if y < 0
          return -QUARTER_CIRCLE_POINT_12
        else
          return QUARTER_CIRCLE_POINT_12
        end
      end      
    end
    
    def atan_point_12 y_over_x_point_12
      factor = y_over_x_point_12 >= 0 ? 1 : -1
      index = y_over_x_point_12.abs >> 6
      
      last_index = ATAN_TABLE_POINT_12.length-1
      
      if index > last_index
        extension = index - last_index
        result = ATAN_TABLE_POINT_12.last + (extension / 400)
        result = QUARTER_CIRCLE_POINT_12 if result > QUARTER_CIRCLE_POINT_12
        result * factor
      else
        ATAN_TABLE_POINT_12[index] * factor
      end
    end
    
    def rotate_vector x, y, rotation_point_12
      sin_point_16 = self.sin_point_16(rotation_point_12)
      cos_point_16 = self.cos_point_16(rotation_point_12)
      rotated_x = -((   ((-x) * cos_point_16) - ((y) * sin_point_16)   ) >> 16)
      rotated_y = -((   ((-y) * cos_point_16) + ((x) * sin_point_16)   ) >> 16)
      return rotated_x, rotated_y
    end
    
    def rotate_vector_around_point x, y, around_x, around_y, rotation_point_12
      sin_point_16 = self.sin_point_16(rotation_point_12)
      cos_point_16 = self.cos_point_16(rotation_point_12)
      rotated_x = around_x - ((   ((around_x - x) * cos_point_16) - ((y - around_y) * sin_point_16)   ) >> 16)
      rotated_y = around_y - ((   ((around_y - y) * cos_point_16) + ((x - around_x) * sin_point_16)   ) >> 16)
      return rotated_x, rotated_y
    end
    
    def rotate_and_scale_vector_around_point x, y, around_x, around_y, rotation_point_12, factor_x_point_12, factor_y_point_12
      sin_point_16 = self.sin_point_16(rotation_point_12)
      cos_point_16 = self.cos_point_16(rotation_point_12)
      result_x = around_x - ((   (((around_x - x) * cos_point_16) - ((y - around_y) * sin_point_16)) * factor_x_point_12   ) >> 28)
      result_y = around_y - ((   (((around_y - y) * cos_point_16) + ((x - around_x) * sin_point_16)) * factor_y_point_12   ) >> 28)
      return result_x, result_y
    end
    
    def scale_and_rotate_vector_around_point x, y, around_x, around_y, rotation_point_12, factor_x_point_12, factor_y_point_12
      sin_point_16 = self.sin_point_16(rotation_point_12)
      cos_point_16 = self.cos_point_16(rotation_point_12)
      result_x = around_x - ((   (((around_x - x) * cos_point_16 * factor_x_point_12) - ((y - around_y) * sin_point_16 * factor_y_point_12))   ) >> 28)
      result_y = around_y - ((   (((around_y - y) * cos_point_16 * factor_y_point_12) + ((x - around_x) * sin_point_16 * factor_x_point_12))   ) >> 28)
      return result_x, result_y
    end
  end
end