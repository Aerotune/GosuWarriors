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
      max_walkable_degrees  = 42
      circle                = IntMath::CIRCLE_POINT_12
      max_walkable_angle    = IntMath::CIRCLE_POINT_12 * max_walkable_degrees / 360 
      walkable_up_right     = circle-max_walkable_angle .. circle
      walkable_down_right   = 0 .. max_walkable_angle
      
      points = shape['outline']
      if points.length > 2
        _polygon_area = polygon_area points
        points = points.reverse unless cw? _polygon_area
        points.each_with_index do |next_point, index|
          point = points[index-1]
          
          dx = next_point[0] - point[0]
          dy = next_point[1] - point[1]
          
          angle = IntMath.atan2_point_12 dy, dx
          color = case angle
          when -max_walkable_angle .. max_walkable_angle
            0xFF00FF00
          when walkable_down_right
            0xFF11EE00
          else
            0xFFFF0000
          end
          draw_line point, next_point, color
        end
      end
    end
  
    def draw_line point_1, point_2, color
      $window.draw_line point_1[0], point_1[1], color, point_2[0], point_2[1], color, Z
    end
    
    def angle_between_points
      
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
  end # << self
end # module