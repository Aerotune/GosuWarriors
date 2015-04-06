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
    p stage
    start_point_index, start_point_distance = ShapeLib.surface_point_index_and_distance shape['outline'], spawn['x'], spawn['y']
    
    @entity_manager.each_entity_with_component :PathStart do |entity, path_start|
      drawable = @entity_manager.get_component entity, :Drawable
      delta_distance = WindowStates::GameSession::SystemHelpers::PathMotion.distance @entity_manager, entity, time
      distance = start_point_distance + delta_distance
      distance_traveled, position = ShapeLib.position_on_surface shape['outline'], start_point_index, distance
      drawable.x = position[0]
      drawable.y = position[1]
    end
  end
end