class WindowStates::GameSession::Components::Tint < Component
  attr_reader :color
  
  def initialize color
    self.color = color
  end
  
  def color= color
    color    = color.dup
    color[0] = 1.0 if color[0] > 1.0
    color[1] = 1.0 if color[1] > 1.0
    color[2] = 1.0 if color[2] > 1.0
    color[0] = 0.0 if color[0] < 0.0
    color[1] = 0.0 if color[1] < 0.0
    color[2] = 0.0 if color[2] < 0.0
    @color   = color
  end
  
  def r
    @color[0]
  end
  
  def r= v
    v = 1.0 if v > 1.0
    v = 0.0 if v < 0.0
    @color[0] = v
  end
  
  def g
    @color[1]
  end
  
  def g= v
    v = 1.0 if v > 1.0
    v = 0.0 if v < 0.0
    @color[1] = v
  end
  
  def b
    @color[2]
  end
  
  def b= v
    v = 1.0 if v > 1.0
    v = 0.0 if v < 0.0
    @color[2] = v
  end
end