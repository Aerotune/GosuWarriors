module ConvexDecomposer
  @cxt = V8::Context.new timeout: 15000
  @cxt.load(File.join DEV_LIB_PATH, 'poly-decomp.js-master', 'src', 'Scalar.js')
  @cxt.load(File.join DEV_LIB_PATH, 'poly-decomp.js-master', 'src', 'Point.js')
  @cxt.load(File.join DEV_LIB_PATH, 'poly-decomp.js-master', 'src', 'Line.js')
  @cxt.load(File.join DEV_LIB_PATH, 'poly-decomp.js-master', 'src', 'Polygon.js')
  
  console = Object.new
  
  def console.warn(*a)
    puts sprintf(*a.map(&:to_s))
  end
  
  def console.log(*a)
    puts sprintf(*a.map(&:to_s))
  end
  
  @cxt['console'] = console
  
  class << self
    def set_polygon polygon
      @polygon  = polygon
      polygon = polygon.reverse unless clockwise?
      @cxt.eval("var polygon = new Polygon();")
      @cxt['polygon']['vertices'].push *polygon
    end
    
    def is_simple?
      @cxt.eval("var is_simple = polygon.isSimple();")
      @cxt['is_simple']
    end
    
    def clockwise?
      polygon_area > 0
    end
    
    def decompose quick=true      
      if quick
        @cxt.eval("var convexes = polygon.quickDecomp();")
      else
        @cxt.eval("var convexes = polygon.decomp();")
      end
      
      convexes = []
      @cxt['convexes'].to_a.each do |js_convex|
        convex = []
        js_convex['vertices'].to_a.reverse_each do |js_vertex|
          point = js_vertex.to_a
          point[0] = point[0].to_i
          point[1] = point[1].to_i
          convex << point
        end
        convexes << convex
      end
      
      # Return convexes with integer points in counter clockwise order
      return convexes
    end
    
    def polygon_area
      @area = 0.0
      
      @polygon.each_with_index do |point, i|
        j = i - 1
        @area += @polygon[j][0] * @polygon[i][1]
        @area -= @polygon[i][0] * @polygon[j][1]
      end
      
      (@area / 2.0).to_i
    end
  end
end