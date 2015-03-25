require_relative 'step_machine'
require_relative 'shared_time'

class SessionTimer
  FPS = 60
  
  def initialize initial_frame=0
    @initial_frame  = initial_frame.to_i
    @start_frame    = @initial_frame
    @frame          = @initial_frame
    @step_machine   = StepMachine.new @initial_frame
    @shared_time    = SharedTime.new
  end
  
  def update_frame &block    
    if @start_time_point_10
      current_time_point_10 = @shared_time.now_point_10 - @start_time_point_10
      current_time_point_10 = 0 if current_time_point_10 < 0
      frame                 = @start_frame + ((current_time_point_10 * FPS) >> 10)
      frame                 = @initial_frame - 1 if frame < @initial_frame
      @frame                = frame
    end
    
    @step_machine.step_to @frame, &block
  end
  
  def start options={}
    unless @start_time_point_10
      @start_frame          = (options[:frame]               || @frame).to_i
      @start_time_point_10  = (options[:start_time_point_10] || @shared_time.now_point_10).to_i
    end
  end
  
  def stop
    @start_time_point_10 = nil
  end
end