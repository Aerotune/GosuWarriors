module WindowStates::GameSession::Systems::PathMotionTweenAdd
  class << self
    def do entity_manager, entity, options
      entity_manager.add_component entity, WindowStates::GameSession::Components::PathMotionTween.new(options)
    end
    
    def undo entity_manager, entity, options
      
    end
  end
end