class ShapeVertex
  attr_accessor :x, :y, :distance_x, :distance_y, :direction_x_point_12, :direction_y_point_12, :bounding_box
  
  def self.vertices_from_convex points
    vertices = []
    
    points.each_with_index do |point, index|
      prev_point = points[index-1]
      vertices << ShapeVertex.new(prev_point[0], prev_point[1], point[0], point[1])
    end
    
    vertices
  end
  
  def initialize x, y, end_x, end_y
    @x                              = x
    @y                              = y
    @end_x                          = end_x
    @end_y                          = end_y
    @distance                       = IntMath.distance(x, y, end_x, end_y)
    @direction_x_point_12           = ((end_x - x) << 12) / @distance
    @direction_y_point_12           = ((end_y - y) << 12) / @distance
    @bounding_box                   = BoundingBox.allocate
    @bounding_box.update_using_points [[@x, @y], [@end_x, @end_y]]
  end
  
  def surface?
    @is_surface
  end
  
  def normal_x_point_12
    -@direction_y_point_12
  end
  
  def normal_y_point_12
    @direction_x_point_12
  end
  
  def == other
    other.kind_of?(ShapeVertex)                           &&
    @x                    == other.x                      &&
    @y                    == other.y                      &&
    @distance             == other.distance               &&
    @direction_x_point_12 == other.direction_x_point_12   &&
    @direction_y_point_12 == other.direction_y_point_12
  end
  
  def to_msgpack *o
    to_hash.to_msgpack *o
  end
  
  def to_hash
    {
      'x' => @x,
      'y' => @y,
      'end_x' => @end_x,
      'end_y' => @end_y,
      'is_surface' => @is_surface
    }
  end
end