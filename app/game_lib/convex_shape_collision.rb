module ConvexShapeCollision
  class << self
    
    def overlap? points_1, points_2
      points_1.each_with_index do |point, index|
        next_point = points_1[(index+1)%points_1.length]
        length, axis_x_point_12, axis_y_point_12 = ShapeLib.line_length_and_axis_point_12 point, next_point
        normal_x_point_12 = -axis_y_point_12
        normal_y_point_12 =  axis_x_point_12
        
        points_1_min, points_1_max = *project(points_1, normal_x_point_12, normal_y_point_12)
        points_2_min, points_2_max = *project(points_2, normal_x_point_12, normal_y_point_12)
        return false unless (points_1_min <= points_2_max) && (points_2_min <= points_1_max)
      end
      
      points_2.each do |point, index|
        next_point = points_2[(index+1)%points_2.length]
        length, axis_x_point_12, axis_y_point_12 = ShapeLib.line_length_and_axis_point_12 point, next_point
        normal_x_point_12 = -axis_y_point_12
        normal_y_point_12 =  axis_x_point_12
        
        points_1_min, points_1_max = *project(points_1, normal_x_point_12, normal_y_point_12)
        points_2_min, points_2_max = *project(points_2, normal_x_point_12, normal_y_point_12)
        return false unless (points_1_min <= points_2_max) && (points_2_min <= points_1_max)
      end
      
      true
    end
    
    def hits_point? points, x, y
      x = x.to_i
      y = y.to_i
      
      points.each_with_index do |point, index|
        next_point = points[(index+1)%points.length]
        length, axis_x_point_12, axis_y_point_12 = ShapeLib.line_length_and_axis_point_12 point, next_point
        normal_x_point_12 = -axis_y_point_12
        normal_y_point_12 =  axis_x_point_12
        min_point_12    =  1.0/0.0
        max_point_12    = -1.0/0.0
        
        point_dot_product_point_12 = x * normal_x_point_12 + y * normal_y_point_12
        
        points.each do |p|
          dot_product_point_12 = p[0] * normal_x_point_12 + p[1] * normal_y_point_12
          min_point_12 = dot_product_point_12 if dot_product_point_12 < min_point_12
          max_point_12 = dot_product_point_12 if dot_product_point_12 > max_point_12
        end
        
        return false if point_dot_product_point_12 > max_point_12 || point_dot_product_point_12 < min_point_12
      end
      
      true
    end
    
    
    private
    
    
    def project points, axis_x, axis_y
      min = 1.0/0.0
      max = -1.0/0.0
    
      points.each do |point|
        dot = point[0]*axis_x + point[1]*axis_y
        min = dot if dot < min
        max = dot if dot > max
      end
      
      return min, max
    end
    
    def distance x1, y1, x2, y2
      Gosu.distance(x1, y1, x2, y2).abs
    end
    
    
  end # << self
end # module