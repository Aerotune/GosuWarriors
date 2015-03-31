module WindowStates::GameSession::SystemHelpers::PathMotion
  class << self
    def speed_point_10 entity_manager, entity, time
      speed_point_10 = 0
      pmc          = entity_manager.get_component entity, :PathMotionContinuous
      pmt          = entity_manager.get_component entity, :PathMotionTween
      
      if pmc
        speed_point_10 += QuadraticOutEaser.value_point_10(pmc.duration, (time - pmc.start_time), pmc.start_speed_point_10, pmc.end_speed_point_10)
      end
      
      if pmt
        speed_point_10 += QuadraticOutEaser.derivative_point_20(pmt.duration, time - pmt.start_time, 0, pmt.distance) >> 20
      end
      
      speed_point_10
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
        return QuadraticOutEaser.integral_point_10(pmc.duration, time - pmc.start_time, pmc.start_speed_point_10, pmc.end_speed_point_10) >> 10
      else
        return 0
      end      
    end
    
    def pmt_distance entity_manager, entity, time
      pmt = entity_manager.get_component entity, :PathMotionTween
      
      if pmt
        return QuadraticOutEaser.value_point_10(pmt.duration, time - pmt.start_time, 0, pmt.distance) >> 10
      else
        return 0
      end
    end
  end
end