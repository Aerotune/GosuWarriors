module ShapeHelper::Walking
  MAX_WALKABLE_DEGREES = 42
  
  class << self
    def walkable? point1, point2, max_walkable_degrees=MAX_WALKABLE_DEGREES
      max_walkable_angle    = IntMath::CIRCLE_POINT_12 * max_walkable_degrees / 360 
      walkable              = -max_walkable_angle .. max_walkable_angle
      
      dx = point2[0] - point1[0]
      dy = point2[1] - point1[1]
      
      angle = IntMath.atan2_point_12 dy, dx
      walkable === angle
    end
    
    def walkable_position points, start_point_index, walk_distance, max_walkable_degrees=MAX_WALKABLE_DEGREES
      distance_walked = 0
      
      if walk_distance < 0
        enum = points.to_enum.with_index.reverse_each
      else
        enum = points.to_enum.with_index
      end
      
      enum.each_with_index do |point, index|
        
      end
    end
  end
end