module ShapeHelper::Render
  class << self
    def draw_shape shape, outline_color, convex_color
      draw_convexes shape, convex_color
      draw_outline  shape, outline_color
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
  
    def draw_line point_1, point_2, color
      #$window.draw_line point_1[0], point_1[1], color, point_2[0], point_2[1], color, Z
      $window.draw_image_line point_1[0], point_1[1], point_2[0], point_2[1], color, Z
    end
    
    def draw_walls shape, color
      shape['outline'].each_with_index do |point_1, index|
        point_2 = shape['outline'][(index+1)%shape['outline'].length]
        
        wall_facing_right_angle = 1024
        wall_facing_left_angle = -1024
        
        dx = point_2[0] - point_1[0]
        dy = point_2[1] - point_1[1]
        
        if dx == 0
          draw_line point_1, point_2, color
        end
        
        #angle = IntMath.atan2_point_12 dy, dx
        #
        #if angle == wall_facing_right_angle || angle == wall_facing_left_angle
        #  draw_line point_1, point_2, color
        #end
      end
    end
    
    def draw_ceilings shape, color      
      shape['outline'].each_with_index do |point_1, index|
        point_2 = shape['outline'][(index+1)%shape['outline'].length]
        
        dx = point_2[0] - point_1[0]
        dy = point_2[1] - point_1[1]
        
        if dy == 0 && dx < 0
          draw_line point_1, point_2, color
        end
      end
    end
  end
end