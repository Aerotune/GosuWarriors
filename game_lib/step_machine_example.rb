if $0 == __FILE__
  require_relative 'step_machine'

  stepper = StepMachine.new 0
  block = ->(step, direction) do
    puts "#{direction == 1 ? 'do' : 'undo'} #{step}"
  end

  stepper.step_to 0, &block # => do 0
  stepper.step_to 0, &block # => (nothing)
  stepper.step_to 3, &block # => do 1, do 2, do 3
  stepper.step_to 3, &block # => (nothing)
  stepper.step_to 1, &block # => undo 3, undo 2
  stepper.step_to 1, &block # => (nothing)
  stepper.step_to 3, &block # => do 2, do 3
end