class Systems::Graphics::Sprite  
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def update drawable, time
    sprite = drawable.draw_component
    frames = Resources::Sprites[sprite.sprite_resource_path]['frames']
    sprite.index = (sprite.index + 0.5) % frames.length
  end
  
  def draw drawable
    sprite = drawable.draw_component
    frames = Resources::Sprites[sprite.sprite_resource_path]['frames']
    frame  = frames[sprite.index]
    
    draw_sprite drawable, frame
    draw_shapes drawable, frame
  end
  
  def draw_sprite drawable, frame
    self.class.draw_frame frame, drawable.x, drawable.y, Z, drawable.factor_x
  end
  
  def self.draw_frame frame, x, y, z, factor_x
    offset_x         =  frame['offset_x']*factor_x
    offset_y         =  frame['offset_y']
    image            =  frame['image']
    image.draw x+offset_x, y+offset_y, z, factor_x
  end
  
  def draw_shapes drawable, frame
    x = drawable.x
    y = drawable.y
    factor_x = drawable.factor_x
    
    #sprite_resource['shapes']['hit_box_convexes']['upper_body'].each do |convex|
    #  convex.each_with_index do |point, index|
    #    prev_point = convex[index-1]
    #    color = 0xFFFF0000
    #    x1 = point[0] * factor_x + x
    #    y1 = point[1] + y
    #    x2 = prev_point[0] * factor_x + x
    #    y2 = prev_point[1] + y
    #    
    #    $window.draw_line x1, y1, color, x2, y2, color, Z
    #  end
    #end
  end
end