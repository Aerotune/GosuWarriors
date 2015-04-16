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
    
    def translate_shape! shape, dx, dy
      shape['outline'].each do |point|
        point[0] += dx
        point[1] += dy
      end
      
      shape['convexes'].each do |convex|
        convex.each do |point|
          point[0] += dx
          point[1] += dy
        end
      end
    end
    
    def translate points, x, y
      result = []
      points.each do |point|
        result << [point[0]+x, point[1]+y]
      end
      result
    end
    
    def project points, axis_x, axis_y
      return "Can't project #{points.length} points against axis!" if points.length <= 1
      
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
    
    # source:
    # http://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Convex_hull/Monotone_chain#Ruby
    def convex_hull points
      points.sort!.uniq!
      return points if points.length < 3
      def cross(o, a, b)
        (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])
      end
      lower = Array.new
      points.each{|p|
        while lower.length > 1 and cross(lower[-2], lower[-1], p) <= 0 do lower.pop end
        lower.push(p)
      }
      upper = Array.new
      points.reverse_each{|p|
        while upper.length > 1 and cross(upper[-2], upper[-1], p) <= 0 do upper.pop end
        upper.push(p)
      }
      return lower[0...-1] + upper[0...-1]
    end
  end
end