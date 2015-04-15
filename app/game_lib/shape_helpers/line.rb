module ShapeHelper::Line
  class << self
    def line_length_and_axis_point_12 point_1, point_2
      length                = IntMath.distance(point_1[0], point_1[1], point_2[0], point_2[1])
      axis_x_point_12       = ((point_2[0] - point_1[0]) << 12) / length
      axis_y_point_12       = ((point_2[1] - point_1[1]) << 12) / length
      return length, axis_x_point_12, axis_y_point_12
    end
    
    def closest_distance_to_point_on_line point, line
      line_length,
      axis_x_point_12,
      axis_y_point_12 = line_length_and_axis_point_12 *line
      
      dx = point[0] - line[0][0]
      dy = point[1] - line[0][1]
      
      distance = (dx * axis_x_point_12 + dy * axis_y_point_12) >> 12
      distance = 0           if distance < 0
      distance = line_length if distance > line_length
      distance
    end
  end
end