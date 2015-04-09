module ShapeHelper::WalkRender
  class << self
    def draw_walkable shape, color
      points = shape['outline']
      
      if points.length > 2
        #points = points.reverse unless ShapeHelper.cw? points #!!! should just be clockwise
        points.each_with_index do |point, index|          
          next_point = points[(index+1)%points.length]
          ShapeHelper::Render.draw_line point, next_point, color if ShapeHelper::Walk.walkable?(point, next_point)
        end
      end
    end
    
    def draw_non_walkable shape, color
      points = shape['outline']
      
      if points.length > 2
        #points = points.reverse unless ShapeHelper.cw? points #!!! should just be clockwise
        points.each_with_index do |point, index|          
          next_point = points[(index+1)%points.length]
          ShapeHelper::Render.draw_line point, next_point, color unless ShapeHelper::Walk.walkable?(point, next_point)
        end
      end
    end
  end
end