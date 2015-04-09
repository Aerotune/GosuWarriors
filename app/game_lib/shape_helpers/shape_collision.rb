module ShapeHelper::ShapeCollision
  class << self
    def mtv points_1, points_2
      points_1.each_with_index do |point, index|
        next_point = points_1[(index+1)%points_1.length]
        length, axis_x_point_12, axis_y_point_12 = ShapeHelpers::Line.line_length_and_axis_point_12 point, next_point
        normal_x_point_12 = -axis_y_point_12
        normal_y_point_12 =  axis_x_point_12
        
        points_1_min, points_1_max = *project(points_1, normal_x_point_12, normal_y_point_12)
        points_2_min, points_2_max = *project(points_2, normal_x_point_12, normal_y_point_12)
        return false unless (points_1_min <= points_2_max) && (points_2_min <= points_1_max)
      end
      
      points_2.each do |point, index|
        next_point = points_2[(index+1)%points_2.length]
        length, axis_x_point_12, axis_y_point_12 = ShapeHelpers::Line.line_length_and_axis_point_12 point, next_point
        normal_x_point_12 = -axis_y_point_12
        normal_y_point_12 =  axis_x_point_12
        
        points_1_min, points_1_max = *project(points_1, normal_x_point_12, normal_y_point_12)
        points_2_min, points_2_max = *project(points_2, normal_x_point_12, normal_y_point_12)
        return false unless (points_1_min <= points_2_max) && (points_2_min <= points_1_max)
      end
      
      true
    end
    
    def overlap? points_1, points_2
      points_1.each_with_index do |point, index|
        next_point = points_1[(index+1)%points_1.length]
        
        dx = next_point[0] - point[0]
        dy = next_point[1] - point[1]
        
        normal_x = -dy
        normal_y =  dx
        
        points_1_min, points_1_max = *ShapeHelper.project(points_1, normal_x, normal_y)
        points_2_min, points_2_max = *ShapeHelper.project(points_2, normal_x, normal_y)
        return false unless (points_1_min <= points_2_max) && (points_2_min <= points_1_max)
      end
      
      points_2.each do |point, index|
        next_point = points_2[(index+1)%points_2.length]
        
        dx = next_point[0] - point[0]
        dy = next_point[1] - point[1]
        
        normal_x = -dy
        normal_y =  dx
        
        points_1_min, points_1_max = *ShapeHelper.project(points_1, normal_x, normal_y)
        points_2_min, points_2_max = *ShapeHelper.project(points_2, normal_x, normal_y)
        return false unless (points_1_min <= points_2_max) && (points_2_min <= points_1_max)
      end
      
      true
    end
  end
end