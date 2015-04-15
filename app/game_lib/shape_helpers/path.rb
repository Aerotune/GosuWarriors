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
    
    def distance_along_line points, point_index, distance_to_point, travel_distance, &condition
      distance_along_line = 0
      
      if travel_distance > 0
        point_1     = points[point_index]
        point_2     = points[(point_index + 1) % points.length]
        if condition.nil? || condition.call(point_1, point_2)
          line_length = IntMath.distance(*point_1, *point_2)
          distance_along_line = travel_distance - distance_to_point
          distance_along_line = line_length if distance_along_line > line_length
          distance_along_line = 0           if distance_along_line < 0
        end
      elsif travel_distance < 0
        point_1     = points[(point_index - 1) % points.length]
        point_2     = points[point_index]
        if condition.nil? || condition.call(point_1, point_2)
          line_length = IntMath.distance(*point_1, *point_2)
          distance_along_line = travel_distance.abs-distance_to_point.abs
          distance_along_line = line_length if distance_along_line > line_length
          distance_along_line = 0           if distance_along_line < 0
          distance_along_line = -distance_along_line
        end
      end
      
      distance_along_line
    end
    
    def point_index_and_distance_to_point points, start_point_index, travel_distance, &condition
      point_index         = start_point_index % points.length
      distance_to_point = 0

      if travel_distance > 0
        point_0 = points[point_index]
        point_1 = points[(point_index+1)%points.length]
        
      	if condition.nil? || condition.call(point_0, point_1)    
          loop do
            line_length = IntMath.distance point_0[0], point_0[1], point_1[0], point_1[1]
            break if distance_to_point + line_length > travel_distance
      
            point_2 = points[(point_index+2)%points.length]
      		  break unless condition.nil? || condition.call(point_1, point_2)      
      
            distance_to_point += line_length
            point_index        = (point_index + 1) % points.length
            
            point_0 = points[point_index]
            point_1 = points[(point_index+1)%points.length]
          end
    
      	end
	
      elsif travel_distance < 0
        point_0 = points[point_index]
        point_1 = points[(point_index-1)%points.length]
        
      	if condition.nil? || condition.call(point_1, point_0)
          loop do      
            line_length = IntMath.distance point_0[0], point_0[1], point_1[0], point_1[1]
            break if distance_to_point - line_length < travel_distance
      
            point_2 = points[(point_index-2)%points.length]
      		  break unless condition.nil? || condition.call(point_2, point_1)      
      
            distance_to_point -= line_length
            point_index        = (point_index - 1) % points.length
            
            point_0 = points[point_index]
            point_1 = points[(point_index-1)%points.length]
          end
      	end
	
      end

      return point_index, distance_to_point
    end
  end
end