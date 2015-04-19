module ShapeHelper::Walk
  MAX_WALKABLE_DEGREES = 42
  
  class << self
    def walkable? point1, point2, max_walkable_degrees=MAX_WALKABLE_DEGREES
      max_walkable_angle    = IntMath::TAU_POINT_10 * max_walkable_degrees / 360 
      walkable              = -max_walkable_angle .. max_walkable_angle
      
      dx = point2[0] - point1[0]
      dy = point2[1] - point1[1]
      
      angle = IntMath.atan2_point_10 dy, dx
      walkable === angle
    end
    
    #def position points, start_point_index, walk_distance, max_walkable_degrees=MAX_WALKABLE_DEGREES
    #  point_index, distance_along_line, distance_to_point = point_index_and_distance_along_line points, start_point_index, walk_distance, max_walkable_degrees
    #  #p [distance_along_line+distance_to_point, walk_distance]
    #  ShapeHelper::Path.position(points, point_index, distance_along_line)
    #end
    
    
    def point_index_and_distance_along_line points, start_point_index, walk_distance, max_walkable_degrees=MAX_WALKABLE_DEGREES
      #point_index, distance_to_point = point_index points, start_point_index, walk_distance, max_walkable_degrees
      point_index, distance_to_point = ShapeHelper::Path.point_index_and_distance_to_point points, start_point_index, walk_distance do |point_1, point_2|
        walkable? point_1, point_2, max_walkable_degrees
      end
      
      #p [point_index, distance_to_point, walk_distance]
      
      distance_along_line = ShapeHelper::Path.distance_along_line points, point_index, distance_to_point, walk_distance do |point_1, point_2|
        walkable? point_1, point_2, max_walkable_degrees
      end
      
      return point_index, distance_along_line, distance_to_point
    end
        
    
    def point_index points, start_point_index, walk_distance, max_walkable_degrees
      delta_index = walk_distance < 0 ? -1 : 1
      this_index  = start_point_index
      next_index  = (this_index + delta_index) % points.length
      
      line_length = 0
      distance_to_point = 0
      
      if walk_distance > 0
        unless walkable?(points[this_index], points[next_index])
          return this_index, distance_to_point
        end
      elsif walk_distance < 0
        unless walkable?(points[next_index], points[this_index])
          distance_to_point = walk_distance
          return this_index, distance_to_point
        end
      end
      
      loop do
        point_1 = points[this_index]
        point_2 = points[next_index]
                
        line_length = IntMath.distance(*point_1, *point_2)
        break if distance_to_point + line_length > walk_distance.abs        
        
        
        point_3 = points[(next_index + delta_index) % points.length]
        if walk_distance > 0
          break unless walkable? point_2, point_3, max_walkable_degrees
        elsif walk_distance < 0
          break unless walkable? point_3, point_2, max_walkable_degrees
        else
          break
        end
        
        distance_to_point += line_length
        this_index         = next_index
        next_index         = (next_index + delta_index) % points.length
      end
      
      if walk_distance >= 0
        return this_index, distance_to_point
      else
        return this_index, -distance_to_point
      end
    end
  end
end