module SystemHelpers::PathMotion
  class << self
    def speed_point_10 entity_manager, entity, time
      speed_point_10 = 0
      pmc          = entity_manager.get_component entity, :PathMotionContinuous
      pmt          = entity_manager.get_component entity, :PathMotionTween
      
      if pmc
        speed_point_10 += Easers::QuadraticOut.value_point_10(pmc.duration, (time - pmc.start_time), pmc.start_speed_point_10, pmc.end_speed_point_10)
      end
      
      if pmt
        speed_point_10 += Easers::QuadraticOut.derivative_point_20(pmt.duration, time - pmt.start_time, 0, pmt.distance) >> 20
      end
      
      speed_point_10
    end
    
    def push_beyond_ledge? entity_manager, entity
      pmc          = entity_manager.get_component entity, :PathMotionContinuous
      pmt          = entity_manager.get_component entity, :PathMotionTween
      return true if pmc && pmc['push_beyond_ledge']
      return true if pmt && pmt['push_beyond_ledge']
      return false
    end
    
    def axis_point_12 entity_manager, entity, time, stage
      path_start = entity_manager.get_component entity, :PathStart
      path_start.distance
      
      _distance = distance entity_manager, entity, time
      
      shape = stage['shapes'][path_start['shape_index']]
      points = shape['outline']
      
      
      point_index, distance_along_line, distance_to_point = ShapeHelper::Walk.point_index_and_distance_along_line points, path_start['start_point_index'], _distance

      if distance_along_line >= 0
        point_1_index = (point_index    ) % points.length
        point_2_index = (point_index + 1) % points.length
      else
        point_1_index = (point_index - 1) % points.length
        point_2_index = (point_index    ) % points.length
      end
      
      #point_1_index = (point_index    ) % points.length
      #point_2_index = (point_index + 1) % points.length
      
      #if speed_point_10(entity_manager, entity, time) < 0
      #  point_1_index = (path_start['start_point_index'] - 1) % shape['outline'].length
      #  point_2_index = (path_start['start_point_index']    ) % shape['outline'].length
      #else
      #  point_1_index = (path_start['start_point_index']    ) % shape['outline'].length
      #  point_2_index = (path_start['start_point_index'] + 1) % shape['outline'].length
      #end
      
      point_1 = shape['outline'][point_1_index]
      point_2 = shape['outline'][point_2_index]
      
      line_length, axis_x_point_12, axis_y_point_12 = ShapeHelper::Line.line_length_and_axis_point_12 point_1, point_2
      return line_length, axis_x_point_12, axis_y_point_12
    end
    
    def distance entity_manager, entity, time
      path_start = entity_manager.get_component entity, :PathStart
      
      distance  = path_start.distance
      distance += pmc_distance entity_manager, entity, time
      distance += pmt_distance entity_manager, entity, time
      
      distance
    end
    
    def pmc_distance entity_manager, entity, time
      pmc = entity_manager.get_component entity, :PathMotionContinuous
      
      if pmc
        return Easers::QuadraticOut.integral_point_10(pmc.duration, time - pmc.start_time, pmc.start_speed_point_10, pmc.end_speed_point_10) >> 10
      else
        return 0
      end      
    end
    
    def pmt_distance entity_manager, entity, time
      pmt = entity_manager.get_component entity, :PathMotionTween
      
      if pmt
        return Easers::QuadraticOut.value_point_10(pmt.duration, time - pmt.start_time, 0, pmt.distance) >> 10
      else
        return 0
      end
    end
  end
end