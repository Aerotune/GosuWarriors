class WindowStates::GameSession::Systems::PathMotion
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def update time
    stage = Resources::Stages['test_level']
    #spawn       = stage['spawn']
    #shape_index = spawn['shape_index']
    #shape       = stage['shapes'][shape_index]
    
    @entity_manager.each_entity_with_component :PathStart do |entity, path_start|
      drawable = @entity_manager.get_component entity, :Drawable
      distance = WindowStates::GameSession::SystemHelpers::PathMotion.distance @entity_manager, entity, time
      shape    = stage['shapes'][path_start['shape_index']]
      
      distance_traveled, position = ShapeLib.position_on_surface shape['outline'], path_start['start_point_index'], distance
      drawable.x = position[0]
      drawable.y = position[1]
    end
  end
end