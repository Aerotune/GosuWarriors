class WindowStates::GameSession::Commands::SetPathMotionContinuous < Command
  def initialize entity_manager, entity, pmc_hash, path_start_hash
    super()
    @entity_manager   = entity_manager
    @entity           = entity
    @pmc_hash         = pmc_hash
    @path_start_hash  = path_start_hash
  end
  
  def do_action
    prev_pmc        = @entity_manager.get_component @entity, :PathMotionContinuous
    prev_path_start = @entity_manager.get_component @entity, :PathStart
    
    if prev_path_start
      @prev_path_start_hash = prev_path_start.to_hash
      @entity_manager.remove_component @entity, :PathStart
    end
    
    if prev_pmc
      @prev_pmc_hash ||= prev_pmc.to_hash 
      @entity_manager.remove_component @entity, :PathMotionContinuous
    end
    
    next_path_start = WindowStates::GameSession::Components::PathStart.new @path_start_hash
    next_pmc        = WindowStates::GameSession::Components::PathMotionContinuous.new @pmc_hash
    @entity_manager.add_component @entity, next_path_start
    @entity_manager.add_component @entity, next_pmc
  end
  
  def undo_action
    @entity_manager.remove_component @entity, :PathMotionContinuous
    @entity_manager.remove_component @entity, :PathStart
        
    if @prev_path_start_hash
      prev_path_start = WindowStates::GameSession::Components::PathStart.new @prev_path_start_hash
      @entity_manager.add_component @entity, prev_path_start
    end
    
    if @prev_pmc_hash
      prev_pmc = WindowStates::GameSession::Components::PathMotionContinuous.new @prev_pmc_hash
      @entity_manager.add_component @entity, prev_pmc
    end
  end
end