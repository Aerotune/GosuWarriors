module ShapeHelper
  Dir[File.join(GAME_LIB_PATH, *%w[shape_helpers *.rb])].each { |rb| require rb }
  
  class << self
    def create_shape
      {'tags' => [], 'outline' => [], 'convexes' => []}
    end
    
    def area points
      area = 0
      
      points.each_with_index do |prev_point, index|
        next_point = points[(index+1)%points.length]
        area += prev_point[0] * next_point[1]
        area -= next_point[0] * prev_point[1]
      end
      
      area / 2
    end
    
    def cw? points_or_polygon_area
      case points_or_polygon_area
      when Numeric
        points_or_polygon_area > 0
      when Array
        area(points_or_polygon_area) > 0
      end
    end
    
    def ccw? points_or_polygon_area
      case points_or_polygon_area
      when Numeric
        points_or_polygon_area < 0
      when Array
        area(points_or_polygon_area) < 0
      end
    end
    
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
    
    def distance_along_axis x, y, axis_x, axis_y
      x * axis_x + axis_y * y
    end
  end
end