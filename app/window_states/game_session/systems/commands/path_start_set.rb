module WindowStates::GameSession::Systems::Commands::PathStartSet
  class << self
    def do entity_manager, entity, options
      stage       = Resources::Stages[options['stage']]
      shape_index = options['shape_index']
      shape       = stage['shapes'][shape_index]
      start_point_index, start_point_distance = ShapeLib.surface_point_index_and_distance shape['outline'], options['path_start_x'], options['path_start_y']
      
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