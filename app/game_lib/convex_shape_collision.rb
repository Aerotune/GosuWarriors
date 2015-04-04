module ConvexShapeCollision
  class << self
    
    def overlap? vertices_1, vertices_2
      vertices_1.each do |vertex_for_axis|
        axis_x_point_12 = vertex_for_axis.normal_x_point_12
        axis_y_point_12 = vertex_for_axis.normal_y_point_12
        
        vertices_1_min, vertices_1_max = *project(vertices_1, axis_x_point_12, axis_y_point_12)
        vertices_2_min, vertices_2_max = *project(vertices_2, axis_x_point_12, axis_y_point_12)
        return false unless (vertices_1_min <= vertices_2_max) && (vertices_2_min <= vertices_1_max)
      end
      
      vertices_2.each do |vertex_for_axis|
        axis_x_point_12 = vertex_for_axis.normal_x_point_12
        axis_y_point_12 = vertex_for_axis.normal_y_point_12
        
        vertices_1_min, vertices_1_max = *project(vertices_1, axis_x_point_12, axis_y_point_12)
        vertices_2_min, vertices_2_max = *project(vertices_2, axis_x_point_12, axis_y_point_12)
        return false unless (vertices_1_min <= vertices_2_max) && (vertices_2_min <= vertices_1_max)
      end
      
      true
    end
    
    def hits_point? vertices, x, y
      x = x.to_i
      y = y.to_i
      
      vertices.each do |v|
        axis_x_point_12 = v.normal_x_point_12
        axis_y_point_12 = v.normal_y_point_12
        min_point_12    =  1.0/0.0
        max_point_12    = -1.0/0.0
        
        point_dot_product_point_12 = x * axis_x_point_12 + y * axis_y_point_12
        
        vertices.each do |vertex|
          dot_product_point_12 = vertex.x * axis_x_point_12 + vertex.y * axis_y_point_12
          min_point_12 = dot_product_point_12 if dot_product_point_12 < min_point_12
          max_point_12 = dot_product_point_12 if dot_product_point_12 > max_point_12
        end
        
        return false if point_dot_product_point_12 > max_point_12 || point_dot_product_point_12 < min_point_12
      end
      
      true
    end
    
    
    private
    
    
    def project vertices, axis_x, axis_y
      min = 1.0/0.0
      max = -1.0/0.0
    
      vertices.each do |vertex|
        x = vertex.x
        y = vertex.y
        dot = x*axis_x + y*axis_y
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