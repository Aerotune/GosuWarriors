require_relative 'point'

class WindowStates::GameSession::Components::Position < WindowStates::GameSession::Components::Point
  attr_accessor :x, :y, :next_x, :next_y
  
  def initialize x, y
    @x = x
    @y = y
    @next_x = x
    @next_y = y
  end
end