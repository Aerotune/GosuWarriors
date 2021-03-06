class Systems::Graphics::Sprite  
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def update entity, time
    
    
    
  end
  
  def update_each_frame entity, time
    sprite = @entity_manager.get_component entity, :Sprite
    frames = Resources::Sprites[sprite.sprite_resource_path]['frames']
    sprite_time = time - sprite.start_time
    
    case sprite.mode
    when 'loop'
      sprite.prev_index = sprite.prev_index ? sprite.index : sprite.start_index-1
      sprite.index = (sprite.start_index + sprite_time * sprite.fps / 60) % frames.length
      sprite.done  = false
    when 'forward'
      sprite.prev_index = sprite.prev_index ? sprite.index : sprite.start_index-1
      last_index = frames.length - 1
      index = sprite.start_index + sprite_time * sprite.fps / 60
      sprite.index = index > last_index ? last_index : index
      sprite.done  = index >= frames.length
    when 'backward'
      sprite.prev_index = sprite.prev_index ? sprite.index : sprite.start_index+1
      index = sprite.start_index - sprite_time * sprite.fps / 60
      sprite.index = index < 0 ? 0 : index
      sprite.done  = index <= -1
    when 'stop'
      sprite.prev_index = sprite.prev_index ? sprite.index : sprite.start_index-1
      sprite.index      = sprite.start_index
    end
    
    index      = sprite.index
    prev_index = sprite.prev_index
    if index != prev_index
      if index > prev_index
        (prev_index+1..index)         .each { |i| play_sound frames, i }
      end
    end
  end
  
  def play_sound frames, index
    sfx_pattern = frames[index]['sfx'].strip
    unless sfx_pattern.empty?
      sample = Resources::Sounds.sfx(sfx_pattern)
      sample.play 0.8 if sample
    end
  end
  
  def draw entity
    draw_sprite entity
    #draw_shapes drawable
  end
  
  def draw_sprite entity
    drawable        = @entity_manager.get_component entity, :Drawable
    sprite          = @entity_manager.get_component entity, :Sprite
    sprite_resource = Resources::Sprites[sprite.sprite_resource_path]
    frame           = sprite_resource['frames'][sprite.index]
    factor_x        = drawable.factor_x * sprite_resource['face_direction']
    self.class.draw_frame frame, drawable.x, drawable.y, Z, factor_x
  end
  
  #def self.draw_lines sprite, x, y, z, factor_x
  #  return unless sprite
  #  
  #  $window.translate x, y do
  #    ShapeHelper::Render.draw_line *sprite['front_line'], 0xFF00FF00
  #    ShapeHelper::Render.draw_line *sprite['back_line'], 0xFF00FF00
  #    ShapeHelper::Render.draw_line *sprite['feet_line'], 0xFF00FF00
  #    ShapeHelper::Render.draw_line *sprite['head_line'], 0xFF00FF00
  #  end
  #end
  
  def self.draw_frame frame, x, y, z, factor_x
    return unless frame
    
    offset_x         =  frame['offset_x'] * factor_x
    offset_y         =  frame['offset_y']
    image            =  frame['image']
    factor_y         = 1
    color            = 0xFFFFFFFF
    blending_mode    =  case frame['blending_mode']
    when 'normal' ;:default
    when 'add'    ;:additive
    else
      :default
    end
    image.draw x+offset_x, y+offset_y, z, factor_x, factor_y, color, blending_mode
  end
  
  #def draw_shapes drawable, frame
  #  x = drawable.x
  #  y = drawable.y
  #  factor_x = drawable.factor_x
  #  
  #  sprite_resource['shapes']['hit_box_convexes']['upper_body'].each do |convex|
  #    convex.each_with_index do |point, index|
  #      prev_point = convex[index-1]
  #      color = 0xFFFF0000
  #      x1 = point[0] * factor_x + x
  #      y1 = point[1] + y
  #      x2 = prev_point[0] * factor_x + x
  #      y2 = prev_point[1] + y
  #      
  #      $window.draw_line x1, y1, color, x2, y2, color, Z
  #    end
  #  end
  #end
end