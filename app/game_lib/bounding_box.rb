class BoundingBox
  attr_accessor :min_x, :max_x, :min_y, :max_y
  
  def initialize min_x, max_x, min_y, max_y
    @min_x = min_x
    @max_x = max_x
    @min_y = min_y
    @max_y = max_y
  end
  
  def hits_point? x, y
    x >= @min_x && x <= @max_x &&
    y >= @min_y && y <= @max_y
  end
  
  def update_using_points points
    reset_ranges
    
    points.each do |point|
      add_point_to_range *point
    end    
  end
  
  def update_using_vertices vertices
    reset_ranges
    
    vertices.each do |vertex|
      add_point_to_range vertex.x, vertex.y
    end 
  end
  
  def draw color, z=0
    $window.draw_quad \
    @min_x, @min_y, color,
    @min_x, @max_y, color,
    @max_x, @max_y, color,
    @max_x, @min_y, color, z
  end
  
  def to_msgpack *o
    to_hash.to_msgpack *o
  end
  
  def to_hash
    {
      'class' => self.class.to_s,
      'min_x' => @min_x,
      'min_y' => @min_y,
      'max_x' => @max_x,
      'max_y' => @max_y
    }
  end
  
  def to_binary_hash
    {
      VARIABLE_INDEX[Variable::CLASS] => CLASS_INDEX[self.class],
      VARIABLE_INDEX[Variable::MIN_X] => @min_x,
      VARIABLE_INDEX[Variable::MIN_Y] => @min_y,
      VARIABLE_INDEX[Variable::MAX_X] => @max_x,
      VARIABLE_INDEX[Variable::MAX_Y] => @max_y
    }
  end
  
  
  private
  
  
  def reset_ranges
    @min_x =  1.0/0.0
    @max_x = -1.0/0.0
    @min_y =  1.0/0.0
    @max_y = -1.0/0.0
  end
  
  def add_point_to_range x, y
    @min_x = x if x < @min_x
    @max_x = x if x > @max_x
    @min_y = y if y < @min_y
    @max_y = y if y > @max_y
  end
end