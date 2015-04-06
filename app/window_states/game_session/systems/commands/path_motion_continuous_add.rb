module WindowStates::GameSession::Systems::PathMotionContinuousAdd
  class << self
    def do entity_manager, entity, pmc_hash
      pmc = WindowStates::GameSession::Components::PathMotionContinuous.new pmc_hash
      entity_manager.add_component entity, pmc
    end
    
    def undo entity_manager, entity, pmc_hash
      pmc = @entity_manager.get_components(entity, :PathMotionContinuous).select { |pmc| pmc['id'] == pmc_hash['id'] }
      entity_manager.remove_component entity, pmc
    end
  end
end