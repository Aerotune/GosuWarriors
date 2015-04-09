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
      $window.draw_line point_1[0], point_1[1], color, point_2[0], point_2[1], color, Z
    end
  end
end