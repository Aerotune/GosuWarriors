module ShapeHelper::Point
  class << self
    def hits_point? points, x, y
      points.each_with_index do |point, index|
        next_point = points[(index+1)%points.length]
        
        dx = next_point[0] - point[0]
        dy = next_point[1] - point[1]
        
        normal_x = -dy
        normal_y =  dx
        
        point_dot_product = x * normal_x + y * normal_y
        
        min, max = ShapeHelper.project points, normal_x, normal_y
        
        return false if point_dot_product > max || point_dot_product < min
      end
      
      true
    end
    
    def point_index_and_distance_along_line points, x, y, &condition
      result_distance = 1.0/0.0
      result_index = nil
      result_axis_distance = nil
  
      return 0, 0 if points.length <= 1
    
      points.each_with_index do |point_1, index|
        next_index = (index+1)%points.length
        point_2 = points[next_index]
        
        next if condition && !condition.call(point_1, point_2)
    
        line_length, axis_x_point_12, axis_y_point_12 = ShapeHelper::Line.line_length_and_axis_point_12 point_1, point_2
    
        dx = x - point_1[0]
        dy = y - point_1[1]
    
        axis_distance = ShapeHelper.distance_along_axis(dx, dy, axis_x_point_12, axis_y_point_12) >> 12
    
        if axis_distance > 0 && axis_distance < line_length
          # distance along normal axis
          normal_x_point_12   = -axis_y_point_12
          normal_y_point_12   =  axis_x_point_12
          distance_to_surface = (ShapeHelper.distance_along_axis(dx, dy, normal_x_point_12, normal_y_point_12)).abs >> 12
          if distance_to_surface < result_distance
            result_distance      = distance_to_surface
            result_index         = index
            result_axis_distance = axis_distance
          end
        else
          distance_to_point = IntMath.distance x, y, *point_1
          if distance_to_point < result_distance
            result_distance      = distance_to_point
            result_index         = next_index
            result_axis_distance = 0
          end
        end   
      end
  
      return result_index, result_axis_distance
    end
  end
end