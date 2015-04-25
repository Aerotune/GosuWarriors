module Systems::Commands::PathStartAddDistance
  class << self
    def do entity_manager, entity, options
      path_start = entity_manager.get_component entity, :PathStart
      path_start.distance += options['distance'] if path_start #!!!
    end
    
    def undo entity_manager, entity, options
      path_start = entity_manager.get_component entity, :PathStart
      path_start.distance -= options['distance'] if path_start #!!!
    end
  end
end