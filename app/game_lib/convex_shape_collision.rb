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
    
    
    def nearest_point_on_surface vertices, x, y
      x = x.to_i
      y = y.to_i
    
      min_distance = 1.0/0.0
      nearest_x = nil
      nearest_y = nil
      nearest_vertex = nil
        
      vertices.each_with_index do |vertex, index|
        next_vertex = vertices[(index+1) % vertices.length]
        if vertex.surface?
          surface_distance_point_12 = vertex.normal_x_point_12*vertex.x + vertex.normal_y_point_12*vertex.y
          point_distance_point_12   = vertex.normal_x_point_12*x        + vertex.normal_y_point_12*y
          distance_point_12 = surface_distance_point_12 - point_distance_point_12
      
          surface_x = x + ((distance_point_12 * vertex.normal_x_point_12) >> 24)
          surface_y = y + ((distance_point_12 * vertex.normal_y_point_12) >> 24)
      
          if vertex.bounding_box.hits_point? surface_x, surface_y
            distance_to_surface = (distance_point_12 >> 12).abs
            if distance_to_surface < min_distance
              min_distance = distance_to_surface
              nearest_x = surface_x
              nearest_y = surface_y
              nearest_vertex = vertex
            end
          end
        end
      
        nearby_vertex = (vertex.surface? && vertex) || (next_vertex.surface? && next_vertex)
        if nearby_vertex
          distance_to_vertex = distance(x, y, vertex.x, vertex.y)
          if distance_to_vertex < min_distance
            min_distance = distance_to_vertex
            nearest_x = vertex.x
            nearest_y = vertex.y
            nearest_vertex = nearby_vertex
          end
        end
        
      end
    
      return nearest_vertex, nearest_x, nearest_y
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