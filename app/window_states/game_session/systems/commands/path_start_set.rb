module WindowStates::GameSession::Systems::PathStartSet
  class << self
    def do entity_manager, entity, options
      path_start = entity_manager.get_component entity, :PathStart
      if path_start
        options['prev_path_start_hash'] = path_start.to_hash
        path_start.mirror options['path_start_hash']
      else
        path_start = WindowStates::GameSession::Components::PathStart.new options['path_start_hash']
        entity_manager.add_component entity, path_start
      end      
    end
    
    def undo entity_manager, entity, options
      if options['prev_path_start_hash']
        path_start = entity_manager.get_component entity, :PathStart
        path_start.mirror options['prev_path_start_hash']
      else
        path_start = @entity_manager.get_component(entity, :PathStart)
        entity_manager.remove_component entity, path_start
      end
    end
  end
end