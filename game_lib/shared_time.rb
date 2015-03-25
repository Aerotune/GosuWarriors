class SharedTime
  def initialize
    
  end
  
  def now_point_10
    (Time.now.to_f * (1 << 10)).to_i
  end
end