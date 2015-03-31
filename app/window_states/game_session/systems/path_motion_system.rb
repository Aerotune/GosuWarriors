class WindowStates::GameSession::Systems::PathMotion
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def update time
    @entity_manager.each_entity_with_component :PathStart do |entity, path_start|
      drawable = @entity_manager.get_component entity, :Drawable
      distance = WindowStates::GameSession::SystemHelpers::PathMotion.distance @entity_manager, entity, time
      drawable.x = distance % $window.width if drawable #!!!
      #pmc = @entity_manager.get_component entity, :PathMotionContinuous
      #if pmc
      #  current_time   = time - pmc.start_time
      #  delta_distance = QuadraticOutEaser.integral_point_10(pmc.duration, current_time, pmc.start_speed_point_10, pmc.end_speed_point_10) >> 10
      #  pmc.distance   = path_start.distance + delta_distance
      #  drawable       = @entity_manager.get_component entity, :Drawable
      #  drawable.x     = pmc.distance % $window.width if drawable #!!!
      #end
    end
  end
end