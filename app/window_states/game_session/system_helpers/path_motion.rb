module WindowStates::GameSession::SystemHelpers::PathMotion
  class << self
    def speed_point_10 entity_manager, entity, time
      speed_point_10 = 0
      #path_start = entity_manager.get_component entity, :PathStart
      pmc          = entity_manager.get_component entity, :PathMotionContinuous
      if pmc
        speed_point_10 += QuadraticOutEaser.value_point_10(pmc.duration, (time - pmc.start_time), pmc.start_speed_point_10, pmc.end_speed_point_10)
      end
      
      speed_point_10
    end
    
    def distance entity_manager, entity, time
      path_start = entity_manager.get_component entity, :PathStart
      pmc        = entity_manager.get_component entity, :PathMotionContinuous
      
      distance   = path_start.distance
      
      if pmc
        current_time = time - pmc.start_time
        distance    += QuadraticOutEaser.integral_point_10(pmc.duration, current_time, pmc.start_speed_point_10, pmc.end_speed_point_10) >> 10
      end
      
      distance
    end
  end
end