module ShapeLib
  class << self
    def create_shape
      {'tags' => [], 'outline' => [], 'convexes' => []}
    end
  
    def draw_convexes shape, color
      shape['convexes'].each do |convex|
        draw_points convex, color
      end
    end
  
    def draw_outline shape, color
      draw_points shape['outline'], color
    end
  
    def draw_points points, color
      points.each_with_index do |point, index|
        prev_point = points[index-1]
        draw_line prev_point, point, color
      end
    end
    
    def draw_terrain shape
      points = shape['outline']
      if points.length > 2
        _polygon_area = polygon_area points
        points = points.reverse unless cw? _polygon_area
        points.each_with_index do |next_point, index|          
          point = points[index-1]
          color = walkable?(point, next_point) ? 0xFF00FF00 : 0xFFFF0000
          draw_line point, next_point, color
        end
      end
    end
    
    def walkable? point1, point2
      max_walkable_degrees  = 42
      max_walkable_angle    = IntMath::CIRCLE_POINT_12 * max_walkable_degrees / 360 
      walkable              = -max_walkable_angle .. max_walkable_angle
      
      dx = point2[0] - point1[0]
      dy = point2[1] - point1[1]
      
      angle = IntMath.atan2_point_12 dy, dx
      walkable === angle
    end
  
    def draw_line point_1, point_2, color
      $window.draw_line point_1[0], point_1[1], color, point_2[0], point_2[1], color, Z
    end
    
    def polygon_area points
      area = 0.0
      
      points.each_with_index do |point, i|
        j = i - 1
        area += points[j][0] * points[i][1]
        area -= points[i][0] * points[j][1]
      end
      
      (area / 2.0).to_i
    end
    
    def cw? polygon_area
      polygon_area > 0
    end
    
    def ccw? polygon_area
      polygon_area < 0
    end
    
    def position_on_path points, start_point_index, delta_distance
      distance_traveled = 0
      index = start_point_index
      next_index = (index+1)%points.length
      distance_between_points = IntMath.distance(*points[index], *points[(index+1)%points.length])
      
      if delta_distance > 0
        loop do
          point1 = points[index]
          point2 = points[next_index]
          #distance_x = point2[0] - point1[0]
          #distance_y = point2[1] - point1[1]
          distance_between_points = IntMath.distance(*point1, *point2)
          if distance_traveled + distance_between_points < delta_distance
            distance_traveled += distance_between_points
            index = next_index
            next_index = (index+1)%points.length
          else
            break
          end
        end
        
      elsif delta_distance < 0
        next_index = (index - 1) % points.length
        loop do
          point1 = points[index]
          point2 = points[next_index]
          
          distance_between_points = IntMath.distance(*point1, *point2)
          if distance_traveled - distance_between_points > delta_distance
            distance_traveled -= distance_between_points
            index = next_index
            next_index = (next_index - 1) % points.length
          else
            break
          end
        end
      end
      
      point1 = points[index]
      point2 = points[next_index]
      distance_between_points = IntMath.distance(*point1, *point2)
      direction_x_point_12  = ((point2[0] - point1[0]) << 12) / distance_between_points
      direction_y_point_12  = ((point2[1] - point1[1]) << 12) / distance_between_points

      distance_from_point = (delta_distance-distance_traveled).abs
      result_x = point1[0] + ((direction_x_point_12 * distance_from_point)>>12)
      result_y = point1[1] + ((direction_y_point_12 * distance_from_point)>>12)
      return [result_x, result_y]
    end
    
    def position_on_surface points, start_point_index, delta_distance
      distance_traveled = 0
      index = start_point_index
      
      
      if delta_distance > 0
        next_index = (index + 1) % points.length
        
        loop do
          point1 = points[index]
          point2 = points[next_index]
          distance_between_points = IntMath.distance(*point1, *point2)
          
          break if distance_traveled + distance_between_points > delta_distance
          unless walkable? point2, points[(next_index+1)%points.length]
            #distance_traveled = delta_distance-distance_between_points
            delta_distance = distance_traveled+distance_between_points
            break
          end
          
          distance_traveled += distance_between_points
          index = next_index
          next_index = (index + 1) % points.length
        end
        
      elsif delta_distance < 0
        next_index = (index - 1) % points.length
        
        loop do
          point1 = points[index]
          point2 = points[next_index]
          distance_between_points = IntMath.distance(*point1, *point2)
          
          break if distance_traveled - distance_between_points < delta_distance
          unless walkable? points[(next_index-1)%points.length], point2
            #distance_traveled = delta_distance+distance_between_points
            delta_distance = distance_traveled-distance_between_points
            break
          end
          
          distance_traveled -= distance_between_points
          index = next_index
          next_index = (next_index - 1) % points.length
        end
      else
        return 0, points[index]
      end
      
      point1 = points[index]
      point2 = points[next_index]
      distance_between_points = IntMath.distance(*point1, *point2)
      direction_x_point_12  = ((point2[0] - point1[0]) << 12) / distance_between_points
      direction_y_point_12  = ((point2[1] - point1[1]) << 12) / distance_between_points

      distance_from_point = (delta_distance-distance_traveled).abs
      result_x = point1[0] + ((direction_x_point_12 * distance_from_point)>>12)
      result_y = point1[1] + ((direction_y_point_12 * distance_from_point)>>12)
      return delta_distance, [result_x, result_y]
    end
    
    def surface_point_index_and_distance points, x, y
      result_distance = 1.0/0.0
      result_index = nil
      result_axis_distance = nil
      
      return 0, 0 if points.length <= 1
        
      points.each_with_index do |point, index|
        next_point            = points[(index+1)%points.length]
        
        line_length, axis_x_point_12, axis_y_point_12 = line_length_and_axis_point_12 point, next_point
        
        dx = x - point[0]
        dy = y - point[1]
        
        axis_distance = distance_along_axis(dx, dy, axis_x_point_12, axis_y_point_12) >> 12
        
        if axis_distance > 0 && axis_distance < line_length
          # distance along normal axis
          normal_x_point_12   = -axis_y_point_12
          normal_y_point_12   =  axis_x_point_12
          distance_to_surface = distance_along_axis(dx, dy, normal_x_point_12, normal_y_point_12) >> 12
          if distance_to_surface < result_distance
            result_distance      = distance_to_surface
            result_index         = index
            result_axis_distance = axis_distance
          end
        else
          distance_to_point = IntMath.distance x, y, *point
          if distance_to_point < result_distance
            result_distance      = distance_to_point
            result_index         = index
            result_axis_distance = 0
          end
        end   
      end
      
      return result_index, result_axis_distance
    end
    
    def closest_distance_along_line_segment point, line_segment_point_1, line_segment_point_2
      line_segment_length, axis_x_point_12, axis_y_point_12 = \
      line_length_and_axis_point_12 line_segment_point_1, line_segment_point_2
      
      dx = point[0] - line_segment_point_1[0]
      dy = point[1] - line_segment_point_1[1]
      
      distance = distance_along_axis(dx, dy, axis_x_point_12, axis_y_point_12) >> 12
      distance = 0                   if distance < 0
      distance = line_segment_length if distance > line_segment_length
      distance
    end
    
    def distance_along_axis x, y, axis_x, axis_y
      x * axis_x + axis_y * y
    end
    
    def line_length_and_axis_point_12 point1, point2
      length                = IntMath.distance(*point1, *point2)
      axis_x_point_12       = ((point2[0] - point1[0]) << 12) / length
      axis_y_point_12       = ((point2[1] - point1[1]) << 12) / length
      return length, axis_x_point_12, axis_y_point_12
    end
  end # << self
end # module