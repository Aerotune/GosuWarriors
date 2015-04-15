module ShapeHelper::ShapeCollision
  class << self
    def mtv points_1, points_2
      result_normal_x_point_12 = nil
      result_normal_y_point_12 = nil
      result_offset_point_12   = 1.0/0.0
      
      points_1.each_with_index do |point, index|
        next_point = points_1[(index+1)%points_1.length]
        
        dx = next_point[0] - point[0]
        dy = next_point[1] - point[1]
        
        length, axis_x_point_12, axis_y_point_12 = ShapeHelper::Line.line_length_and_axis_point_12 point, next_point
        
        normal_x_point_12 = -axis_y_point_12
        normal_y_point_12 =  axis_x_point_12
        
        points_1_min, points_1_max = *ShapeHelper.project(points_1, normal_x_point_12, normal_y_point_12)
        points_2_min, points_2_max = *ShapeHelper.project(points_2, normal_x_point_12, normal_y_point_12)
        
        if (points_1_min <= points_2_max) && (points_2_min <= points_1_max)
          offset_1_point_12 = (points_1_max - points_2_min)
          offset_2_point_12 = (points_2_max - points_1_min)
                    
          if offset_1_point_12 < result_offset_point_12
            result_normal_x_point_12 = normal_x_point_12
            result_normal_y_point_12 = normal_y_point_12
            result_offset_point_12   = offset_1_point_12
          end
        
          if offset_2_point_12 < result_offset_point_12
            result_normal_x_point_12 = normal_x_point_12
            result_normal_y_point_12 = normal_y_point_12
            result_offset_point_12   = offset_2_point_12
          end
        end
      end
      
      points_2.each do |point, index|
        next_point = points_2[(index+1)%points_2.length]
        
        dx = next_point[0] - point[0]
        dy = next_point[1] - point[1]
        
        length, axis_x_point_12, axis_y_point_12 = ShapeHelper::Line.line_length_and_axis_point_12 point, next_point
        
        normal_x_point_12 = -axis_y_point_12
        normal_y_point_12 =  axis_x_point_12
        
        points_1_min, points_1_max = *ShapeHelper.project(points_1, normal_x_point_12, normal_y_point_12)
        points_2_min, points_2_max = *ShapeHelper.project(points_2, normal_x_point_12, normal_y_point_12)
        
        if (points_1_min <= points_2_max) && (points_2_min <= points_1_max)
          offset_1_point_12 = (points_1_max - points_2_min)
          offset_2_point_12 = (points_2_max - points_1_min)
                    
          if offset_1_point_12 < result_offset_point_12
            result_normal_x_point_12 = normal_x_point_12
            result_normal_y_point_12 = normal_y_point_12
            result_offset_point_12   = offset_1_point_12
          end
        
          if offset_2_point_12 < result_offset_point_12
            result_normal_x_point_12 = normal_x_point_12
            result_normal_y_point_12 = normal_y_point_12
            result_offset_point_12   = offset_2_point_12
          end
        end 
      end
      
      if result_normal_x_point_12
        return result_offset_point_12 >> 12, (result_normal_x_point_12*result_offset_point_12)>>24, (result_normal_y_point_12*result_offset_point_12)>>24
      else
        return nil, nil
      end
      #return [result_offset_point_12, result_normal_x_point_12, result_normal_y_point_12]
      #return distance_point_12>>12#((normal_x_point_12*distance_point_12)>>22), ((normal_y_point_12*distance_point_12)>>22)
    end
    
    def overlap? points_1, points_2
      points_1.each_with_index do |point, index|
        next_point = points_1[(index+1)%points_1.length]
        
        dx = next_point[0] - point[0]
        dy = next_point[1] - point[1]
        
        normal_x = -dy << 10
        normal_y =  dx << 10
        
        points_1_min, points_1_max = *ShapeHelper.project(points_1, normal_x, normal_y)
        points_2_min, points_2_max = *ShapeHelper.project(points_2, normal_x, normal_y)
        return false unless (points_1_min <= points_2_max) && (points_2_min <= points_1_max)
      end
      
      points_2.each do |point, index|
        next_point = points_2[(index+1)%points_2.length]
        
        dx = next_point[0] - point[0]
        dy = next_point[1] - point[1]
        
        normal_x = -dy << 10
        normal_y =  dx << 10
        
        points_1_min, points_1_max = *ShapeHelper.project(points_1, normal_x, normal_y)
        points_2_min, points_2_max = *ShapeHelper.project(points_2, normal_x, normal_y)
        return false unless (points_1_min <= points_2_max) && (points_2_min <= points_1_max)
      end
      
      true
    end
  end
end