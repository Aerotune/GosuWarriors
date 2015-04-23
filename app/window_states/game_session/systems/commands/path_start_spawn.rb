module WindowStates::GameSession::Systems::Commands::PathStartSpawn
  class << self
    def do entity_manager, entity, options
      stage       = options['stage']
      spawn       = stage['spawn']
      shape_index = spawn['shape_index']
      shape       = stage['shapes'][shape_index]
      start_point_index, start_point_distance = ShapeHelper::Point.point_index_and_distance_along_line shape['outline'], spawn['x'], spawn['y'] do |point_1, point_2|
        ShapeHelper::Walk.walkable? point_1, point_2
      end
      
      path_start = WindowStates::GameSession::Components::PathStart.new \
        'id'                => 0,
        'shape_index'       => shape_index,
        'start_point_index' => start_point_index,
        'distance'          => start_point_distance

      entity_manager.add_component entity, path_start
    end
    
    def undo entity_manager, entity, spawn
      entity_manager.remove_component entity, :PathStart
    end
  end
end