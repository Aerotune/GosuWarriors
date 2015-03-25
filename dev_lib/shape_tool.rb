class ShapeTool
  attr_reader :convexes, :points
  
  def initialize points, convexes
    @points = points
    @convexes = convexes
  end
  
  def add_point x, y
    @points << [x, y]
    calculate_convexes
  end
  
  def undo!
    @points.pop
    calculate_convexes
  end
  
  def calculate_convexes
    ConvexDecomposer.set_polygon @points
    convexes = ConvexDecomposer.decompose
    @convexes.clear
    @convexes.push *convexes if ConvexDecomposer.is_simple?
  end
  
  def draw offset_x, offset_y
    if @convexes.length > 0
      draw_convexes offset_x, offset_y
    else
      draw_outline offset_x, offset_y
    end
  end
  
  def draw_convexes offset_x, offset_y
    color = 0x3344FF44
    @convexes.each do |convex|
      convex.each_with_index do |point, index|
        prev_point = convex[index-1]
        $window.draw_line prev_point[0]+offset_x, prev_point[1]+offset_y, color, point[0]+offset_x, point[1]+offset_y, color
      end
    end
    
    color = 0xFF44FF44
    prev_point = @points[-1]
    @points.each do |point|   
      $window.draw_line point[0]+offset_x, point[1]+offset_y, color, prev_point[0]+offset_x, prev_point[1]+offset_y, color
      prev_point = point
    end
    
    mouse_point = [$window.mouse_x, $window.mouse_y]
    preview_color = 0x99FF2222
    mouse_preview_color = 0x33FF2222
    $window.draw_line mouse_point[0], mouse_point[1], mouse_preview_color, @points[-1][0]+offset_x, @points[-1][1]+offset_y, preview_color
    $window.draw_line mouse_point[0], mouse_point[1], mouse_preview_color, @points[0][0]+offset_x, @points[0][1]+offset_y, preview_color
  end
  
  def draw_outline offset_x, offset_y
    return if @points.empty?
    
    if @convexes.length > 0
      final_color = 0xFFFFFFFF
      preview_color = 0x4488FFFF
    else
      final_color = 0xFFFF0000
      preview_color = 0xFFFF0000
    end
    
    mouse_point = [$window.mouse_x, $window.mouse_y]
    prev_point = mouse_point
    $window.draw_line mouse_point[0], mouse_point[1], preview_color, @points[-1][0]+offset_x, @points[-1][1]+offset_y, preview_color
    $window.draw_line mouse_point[0], mouse_point[1], preview_color, @points[0][0]+offset_x, @points[0][1]+offset_y, preview_color
    
    prev_point = @points[-1]
    color = 0x33FFFFFF
    
    @points.each do |point|   
      $window.draw_line point[0]+offset_x, point[1]+offset_y, color, prev_point[0]+offset_x, prev_point[1]+offset_y, color
      prev_point = point
      color = final_color
    end
  end
end