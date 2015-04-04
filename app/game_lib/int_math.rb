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
      Gosu.distance(x1, y1, x2, y2).round
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
      
      if index > ATAN_TABLE_POINT_12.length
        extension = index - ATAN_TABLE_POINT_12.length
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
    
    def position_on_path points, start_point_index, delta_distance
      distance_traveled = 0
      index = start_point_index
      next_index = (index+1)%points.length
      distance_between_points = IntMath.distance(*points[index], *points[(index+1)%points.length])
      
      loop do
        point1 = points[index]
        point2 = points[next_index]
        distance_x = point2[0] - point1[0]
        distance_y = point2[1] - point1[1]
        distance_between_points = IntMath.distance(*point1, *point2)
        if distance_traveled + distance_between_points < delta_distance
          distance_traveled += distance_between_points
          index = next_index
          next_index = (index+1)%points.length
        else
          break
        end
      end
      
      point1 = points[index]
      point2 = points[next_index]
      distance_between_points = IntMath.distance(*point1, *point2)
      direction_x_point_12  = ((point2[0] - point1[0]) << 12) / distance_between_points
      direction_y_point_12  = ((point2[1] - point1[1]) << 12) / distance_between_points
      
      distance_from_point = delta_distance-distance_traveled
      result_x = point1[0] + ((direction_x_point_12 * distance_from_point)>>12)
      result_y = point1[1] + ((direction_y_point_12 * distance_from_point)>>12)
      return [result_x, result_y]
    end
    
    def nearest_point_on_surface points, x, y
      min_distance = 1.0/0.0
      nearest_index = nil
      nearest_x = nil
      nearest_y = nil
      #min_delta_angle = nil
      
      
      return 0, *points.first if points.length == 1
        
      points.each_with_index do |next_point, index|
        point                 = points[index-1]
        distance              = self.distance(*point, *next_point)
        direction_x_point_12  = ((next_point[0] - point[0]) << 12) / distance
        direction_y_point_12  = ((next_point[1] - point[1]) << 12) / distance
        normal_x_point_12     = -direction_y_point_12
        normal_y_point_12     =  direction_x_point_12
                
        surface_distance_point_12 = normal_x_point_12*point[0] + normal_y_point_12*point[1]
        point_distance_point_12   = normal_x_point_12*x        + normal_y_point_12*y
        distance_point_12         = surface_distance_point_12 - point_distance_point_12
        
        surface_x = x + ((distance_point_12 * normal_x_point_12) >> 24)
        surface_y = y + ((distance_point_12 * normal_y_point_12) >> 24)
        surface_angle = self.atan2_point_12 surface_y, surface_x
        
        #delta_angle   = self.shortest_angle_point_12_between point_angle, surface_angle
        
        x_points = [point[0],next_point[0]]
        y_points = [point[1],next_point[1]]
        
        if surface_x >= x_points.min && surface_x <= x_points.max && surface_y >= y_points.min && surface_y <= y_points.max
          distance_to_surface = (distance_point_12 >> 12).abs
          if distance_to_surface < min_distance
            min_distance  = distance_to_surface
            nearest_index = index
            nearest_x     = surface_x
            nearest_y     = surface_y
          end
        end
      
        distance_to_point = self.distance(x, y, *point)
        
        if distance_to_point < min_distance
          min_distance  = distance_to_point
          nearest_index = index
          nearest_x     = point[0]
          nearest_y     = point[1]
        end        
      end
      
      if points.length >= 3
        point      = points[nearest_index]
        prev_point = points[nearest_index-1]
        next_point = points[(nearest_index+1)%points.length]
        
        angle = self.atan2_point_12 y-point[1], x-point[0]
        #prev_angle = self.atan2_point_12 y-prev_point[1], x-prev_point[0]
        prev_surface_angle = self.atan2_point_12 point[1]-prev_point[1], point[0]-prev_point[0]
        next_surface_angle = self.atan2_point_12 next_point[1]-point[1], next_point[0]-point[0]
        
        #p self.shortest_angle_point_12_between(prev_surface_angle, angle)
        #p self.shortest_angle_point_12_between(next_surface_angle, angle)
        if self.shortest_angle_point_12_between(prev_surface_angle, angle) > self.shortest_angle_point_12_between(next_surface_angle, angle)
          #nearest_index -= 1
          #p 'hmm'      
          #point                 = points[nearest_index]
          #next_point            = points[nearest_index+1]
          #distance              = self.distance(*point, *next_point)
          #direction_x_point_12  = ((next_point[0] - point[0]) << 12) / distance
          #direction_y_point_12  = ((next_point[1] - point[1]) << 12) / distance
          #normal_x_point_12     = -direction_y_point_12
          #normal_y_point_12     =  direction_x_point_12
          #      
          #surface_distance_point_12 = normal_x_point_12*point[0] + normal_y_point_12*point[1]
          #point_distance_point_12   = normal_x_point_12*x        + normal_y_point_12*y
          #distance_point_12         = surface_distance_point_12 - point_distance_point_12
          #
          #surface_x = x + ((distance_point_12 * normal_x_point_12) >> 24)
          #surface_y = y + ((distance_point_12 * normal_y_point_12) >> 24)
          #
          #nearest_x
        end
        
      
        
      end
      
      return nearest_index, nearest_x, nearest_y
    end
  end
end