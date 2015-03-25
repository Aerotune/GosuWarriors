require_relative 'point'

class Components::Position < Components::Point
  attr_accessor :x, :y, :next_x, :next_y
  
  def initialize x, y
    @x = x
    @y = y
    @next_x = x
    @next_y = y
  end
end