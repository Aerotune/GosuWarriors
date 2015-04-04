class WindowStates::GameSession::Systems::PathMotion
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def update time
    stage = Resources::Stages['test_level']
    spawn = stage['spawn']
    shape_index = spawn['shape_index']
    shape = stage['shapes'][shape_index]
    start_point_index = spawn['start_point_index']
    start_distance    = spawn['distance']
    
    @entity_manager.each_entity_with_component :PathStart do |entity, path_start|
      drawable = @entity_manager.get_component entity, :Drawable
      distance = WindowStates::GameSession::SystemHelpers::PathMotion.distance @entity_manager, entity, time
      position = IntMath.position_on_path shape['outline'], start_point_index, start_distance+distance
      drawable.x = position[0]
      drawable.y = position[1]
      #p position
      #drawable.x = distance % $window.width if drawable #!!!
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