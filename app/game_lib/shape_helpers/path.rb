module ShapeHelper::Path  
  class << self
    def position points, point_index, distance_along_line
      if distance_along_line >= 0
        point_1 = points[point_index]
        point_2 = points[(point_index + 1) % points.length]
        distance = IntMath.distance *point_1, *point_2
      else
        point_1 = points[(point_index - 1) % points.length]
        point_2 = points[point_index]
        distance = IntMath.distance *point_1, *point_2
        distance_along_line = distance+distance_along_line
      end
      
      
      direction_x_point_12  = ((point_2[0] - point_1[0]) << 12) / distance
      direction_y_point_12  = ((point_2[1] - point_1[1]) << 12) / distance
      
      x = point_1[0] + ((direction_x_point_12 * distance_along_line) >> 12)
      y = point_1[1] + ((direction_y_point_12 * distance_along_line) >> 12)
      
      return x, y
    end
    
    def distance_along_line points, point_index, distance_to_point, travel_distance
      
      if travel_distance > 0
        point_1     = points[point_index]
        point_2     = points[(point_index + 1) % points.length]
        line_length = IntMath.distance(*point_1, *point_2)
        distance_along_line = travel_distance - distance_to_point
        distance_along_line = line_length if distance_along_line > line_length
        distance_along_line = 0           if distance_along_line < 0
      elsif travel_distance <= 0
        point_1     = points[(point_index - 1) % points.length]
        point_2     = points[point_index]
        line_length = IntMath.distance(*point_1, *point_2)
        distance_along_line = travel_distance.abs-distance_to_point.abs
        distance_along_line = line_length if distance_along_line > line_length
        distance_along_line = 0           if distance_along_line < 0
        distance_along_line = -distance_along_line
      #else
      #  distance_along_line = 0
      end
      
      distance_along_line
    end
  end
end