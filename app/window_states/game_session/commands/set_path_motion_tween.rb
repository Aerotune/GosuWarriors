class WindowStates::GameSession::Commands::SetPathMotionTween < Command
  def initialize entity_manager, entity, pmt_hash
    super()
    @entity_manager   = entity_manager
    @entity           = entity
    @pmt_hash         = pmt_hash
  end
  
  def do_action
    prev_pmt        = @entity_manager.get_component @entity, :PathMotionTween
    
    if prev_pmt
      @prev_pmt_hash ||= prev_pmt.to_hash 
      @entity_manager.remove_component @entity, :PathMotionTween
    end
    
    next_pmt = WindowStates::GameSession::Components::PathMotionTween.new @pmt_hash
    @entity_manager.add_component @entity, next_pmt
  end
  
  def undo_action
    @entity_manager.remove_component @entity, :PathMotionTween
    
    if @prev_pmt_hash
      prev_pmt = WindowStates::GameSession::Components::PathMotionTween.new @prev_pmt_hash
      @entity_manager.add_component @entity, prev_pmt
    end
  end
end