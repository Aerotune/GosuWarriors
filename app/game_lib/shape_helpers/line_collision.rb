module ShapeHelper::LineCollision
  class << self
    def point_index_and_distance_along_line points, line, &condition
      intersections = []
      
      points.each_with_index do |point_1, index|
        point_2 = points[(index + 1) % points.length]
        next if condition && !condition.call(point_1, point_2)
        status, x, y = line_intersection [point_1, point_2], line
        intersections << [x, y, index] if status == :intersection
      end
      
      line_point_x, line_point_y = *line[0]
      
      intersections.sort_by! do |intersection|
        IntMath.distance(intersection[0], intersection[1], line_point_x, line_point_y)
      end
      
      intersection = intersections.first
      
      if intersection
        x, y, point_index = *intersection
        distance_to_point = IntMath.distance x, y, *points[point_index]
        return point_index, distance_to_point
      else
        return nil, nil
      end
    end
    
    # Line in the format:
    # [[x1, y1], [x2, y2]]
    def line_intersection line_1, line_2
      line_1_dx = line_1[1][0] - line_1[0][0]
      line_1_dy = line_1[1][1] - line_1[0][1]
      line_2_dx = line_2[1][0] - line_2[0][0]
      line_2_dy = line_2[1][1] - line_2[0][1]
      
      det = (line_2_dx * line_1_dy) - (line_1_dx * line_2_dy)
  
      # lines are parallel
      return :parralel, nil, nil if det == 0
        
      progress_1_point_12 = (-(-(line_1[0][0] - line_2[0][0]) * line_2_dy + (line_1[0][1] - line_2[0][1]) * line_2_dx) << 12) / det
      progress_2_point_12 = ( ( (line_1[0][0] - line_2[0][0]) * line_1_dy - (line_1[0][1] - line_2[0][1]) * line_1_dx) << 12) / det
  
      if progress_1_point_12 > 0 && progress_1_point_12 <= (1<<12)
        if progress_2_point_12 > 0 && progress_2_point_12 <= (1<<12)
          x = line_1[0][0] + ((line_1_dx * progress_1_point_12)>>12)
          y = line_1[0][1] + ((line_1_dy * progress_1_point_12)>>12)
      
          return :intersection, x, y
        end
      end
  
      return :no_intersection, nil, nil
    end
  end
end