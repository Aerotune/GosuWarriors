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
      character = @entity_manager.get_component entity, :Character
      distance = WindowStates::GameSession::SystemHelpers::PathMotion.distance @entity_manager, entity, time
      shape    = stage['shapes'][path_start['shape_index']]
      
      points = shape['outline']
      point_index, distance_along_line, distance_to_point = ShapeHelper::Walk.point_index_and_distance_along_line points, path_start['start_point_index'], distance
      distance_along_path = distance_to_point+distance_along_line
      distance_beyond_path = distance - distance_along_path
      #if distance != distance_to_point+distance_along_line
      #  character = @entity_manager.get_component entity, :Character
      #  character.set_animation_state = 'fall_down'        
      #end
      
      #change implicit
      character['stage_collisions']['path_movement']['beyond_ledge'] = true if distance != distance_along_path
      path_start.distance -= distance_beyond_path
      path_start.distance += 1 if distance_beyond_path > 0
      path_start.distance -= 1 if distance_beyond_path < 0
      
      position = ShapeHelper::Path.position(points, point_index, distance_along_line)
      
      drawable.x = position[0]
      drawable.y = position[1]
    end
  end
end