class WindowStates::GameSession::Systems::PathMotion
  def initialize game_session
    @game_session   = game_session
    @entity_manager = game_session.entity_manager
  end
  
  def update time
    stage = @game_session.stage
    
    @entity_manager.each_entity_with_component :PathStart do |entity, path_start|
      drawable = @entity_manager.get_component entity, :Drawable
      character = @entity_manager.get_component entity, :Character
      distance = WindowStates::GameSession::SystemHelpers::PathMotion.distance @entity_manager, entity, time
      shape    = stage['shapes'][path_start['shape_index']]
      
      points = shape['outline']
      point_index, distance_along_line, distance_to_point = ShapeHelper::Walk.point_index_and_distance_along_line points, path_start['start_point_index'], distance
      distance_along_path = distance_to_point+distance_along_line
      distance_beyond_path = distance - distance_along_path
      
      push_beyond_ledge = WindowStates::GameSession::SystemHelpers::PathMotion.push_beyond_ledge? @entity_manager, entity
      
      #change implicit
      path_start.distance -= distance_beyond_path
      character['stage_collisions']['path_movement']['distance_beyond_ledge'] = distance_beyond_path
      if distance_beyond_path > 0 && push_beyond_ledge
        character['stage_collisions']['path_movement']['direction_beyond_ledge'] = 1
      elsif distance_beyond_path < 0 && push_beyond_ledge
        character['stage_collisions']['path_movement']['direction_beyond_ledge'] = -1
      else
        character['stage_collisions']['path_movement']['direction_beyond_ledge'] = nil
      end
      
      position = ShapeHelper::Path.position(points, point_index, distance_along_line)
      
      drawable.prev_x = drawable.x
      drawable.prev_y = drawable.y
      
      drawable.x = position[0]
      drawable.y = position[1]
    end
  end
end