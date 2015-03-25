class StepMachine
  def initialize initial_step
    @initial_step = initial_step.to_i
    @current_step = nil
  end
  
  # Calls the block for each step up to the new_step with the parameters |step, direction|
  # where direction is 1 for a step forward and -1 for a step backward.
  def step_to new_step, &block
    step = new_step.to_i
    
    take_initial_step &block unless @current_step
    
    if @current_step < step
      step_forward_to step, &block
    elsif @current_step > step
      step_backward_to step, &block
    end
  end
  
  private
  
  def step_forward_to step, &block    
    while @current_step < step
      @current_step += 1
      block.call @current_step, 1
    end
  end
  
  def step_backward_to step, &block    
    while @current_step > step
      block.call @current_step, -1
      @current_step -= 1
    end    
  end
  
  def take_initial_step &block
    if @initial_step
      block.call @initial_step, 1
      @current_step = @initial_step
      @initial_step = nil
    end
  end
end