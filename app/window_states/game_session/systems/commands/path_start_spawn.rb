module Systems::Commands::PathStartSpawn
  class << self
    def do game_session, command
      entity      = command['entity']
      stage       = game_session.stage
      spawn       = stage['spawn']
      shape_index = spawn['shape_index']
      shape       = stage['shapes'][shape_index]
      
      start_point_index, start_point_distance = ShapeHelper::Point.point_index_and_distance_along_line shape['outline'], spawn['x'], spawn['y'] do |point_1, point_2|
        ShapeHelper::Walk.walkable? point_1, point_2
      end
      
      path_start = WindowStates::GameSession::Components::PathStart.new \
        'id'                => command['id'],
        'shape_index'       => shape_index,
        'start_point_index' => start_point_index,
        'distance'          => start_point_distance

      game_session.entity_manager.add_component entity, path_start
    end
    
    def undo game_session, command
      entity_manager = game_session.entity_manager
      path_start = entity_manager.get_components(entity, :PathStart).find { |component| component['id'] == command['id'] }
      entity_manager.delete_component entity, path_start
    end
  end
end