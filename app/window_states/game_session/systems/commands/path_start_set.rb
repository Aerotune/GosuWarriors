module WindowStates::GameSession::Systems::Commands::PathStartSet
  class << self
    def do entity_manager, entity, options
      stage       = Resources::Stages[options['stage']]
      shape_index = options['shape_index']
      shape       = stage['shapes'][shape_index]
      
      #if options['surface_only']
      #start_point_index, start_point_distance = ShapeLib.surface_point_index_and_distance shape['outline'], options['x'], options['y']
      start_point_index, start_point_distance = ShapeHelper::LineCollision.point_index_and_distance_along_line shape['outline'], options['line'] do |point_1, point_2|
        ShapeHelper::Walk.walkable? point_1, point_2
      end
      
      if start_point_index.nil?
        x = (options['line'][0][0] + options['line'][1][0])/2
        y = (options['line'][0][1] + options['line'][1][1])/2
        start_point_index, start_point_distance = ShapeHelper::Point.point_index_and_distance_along_line shape['outline'], x, y do |point_1, point_2|
          ShapeHelper::Walk.walkable? point_1, point_2
        end
      end
      
      #p 
      #else
      #  start_point_index, start_point_distance = ShapeLib.path_point_index_and_distance shape['outline'], options['path_start_x'], options['path_start_y']
      #end
      #puts "Start Point?: #{start_point_index_1 == start_point_index_2}"
      #puts "Start Point: #{start_point_index_}"
      #puts "Distance: #{start_point_distance_1}, #{start_point_distance_2}"
      
      #line_1 = [[prev_x, prev_y], [x-prev_x, y-prev_y]]
      
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