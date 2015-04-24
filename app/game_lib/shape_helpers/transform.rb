module ShapeHelper::Transform
  class << self
    def translate points, translate_x, translate_y
      points.map { |point| [point[0]+translate_x, point[1]+translate_y] }
    end
    
    def translate! points, translate_x, translate_y
      points.map! { |point| [point[0]+translate_x, point[1]+translate_y] }
    end
  end
end