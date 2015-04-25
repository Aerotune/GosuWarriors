class Systems::Hits
  SystemHelpers = SystemHelpers
  
  def initialize game_session
    @game_session   = game_session
    @entity_manager = game_session.entity_manager
  end
  
  def update time
    update_ticks
    
    @entity_manager.entities_with_components(:Sprite, :Drawable).combination(2).each do |entity_1, entity_2|
      drawable_1        = @entity_manager.get_component entity_1, :Drawable
      drawable_2        = @entity_manager.get_component entity_2, :Drawable
      
      hit_immunities_1  = @entity_manager.get_component entity_1, :HitImmunities
      hit_immunities_2  = @entity_manager.get_component entity_2, :HitImmunities
      
      sprite_1          = @entity_manager.get_component entity_1, :Sprite
      sprite_2          = @entity_manager.get_component entity_2, :Sprite
      
      sprite_1_resource = Resources::Sprites[sprite_1.sprite_resource_path]
      sprite_2_resource = Resources::Sprites[sprite_2.sprite_resource_path]
      
      shapes_1          = sprite_1_resource['frames'][sprite_1.index]['shapes']
      shapes_2          = sprite_2_resource['frames'][sprite_2.index]['shapes']
      
      factor_x_1        = sprite_1_resource['face_direction'] * drawable_1.factor_x
      factor_x_2        = sprite_2_resource['face_direction'] * drawable_2.factor_x
      
      distance_x        = drawable_2.x - drawable_1.x
      distance_y        = drawable_2.y - drawable_1.y
      
      takes_damage_shapes_1 = shapes_1.select { |shape| shape['tags'].include? 'takes_damage' }
      takes_damage_shapes_2 = shapes_2.select { |shape| shape['tags'].include? 'takes_damage' }
      
      deals_damage_shapes_1 = shapes_1.select { |shape| shape['tags'].include? 'deals_damage' }
      deals_damage_shapes_2 = shapes_2.select { |shape| shape['tags'].include? 'deals_damage' }
      
      each_shape_colliding deals_damage_shapes_1, deals_damage_shapes_2, distance_x, distance_y do |shape|
        # Damage boxes hitting each other cancel each other out
        deals_damage_shapes_1.delete shape
        deals_damage_shapes_2.delete shape
      end
      
      entity_1_hit_by = []
      entity_2_hit_by = []
      
      
      deals_damage_shapes_1.product(takes_damage_shapes_2).each do |deals_damage_shape, takes_damage_shape|
        if shape_hit? deals_damage_shape, takes_damage_shape, distance_x, distance_y, factor_x_1, factor_x_2
          hit_id = SystemHelpers::Hit.hit_id @entity_manager, entity_1, deals_damage_shape
          entity_2_hit_by.push deals_damage_shape unless hit_immunities_2.hit_ids.include? hit_id
          hit_immunities_2.hit_ids << hit_id
        end
      end
      
      deals_damage_shapes_2.product(takes_damage_shapes_1).each do |deals_damage_shape, takes_damage_shape|
        if shape_hit? deals_damage_shape, takes_damage_shape, -distance_x, -distance_y, factor_x_2, factor_x_1
          hit_id = SystemHelpers::Hit.hit_id @entity_manager, entity_2, deals_damage_shape
          entity_1_hit_by.push deals_damage_shape unless hit_immunities_1.hit_ids.include? hit_id
          hit_immunities_1.hit_ids << hit_id
        end
      end
      
      entity_1_hit_by.each do |hit|
        entity_1
        Resources::Sounds['target_break'].play
        sprite_1.mode = 'forward'
        sprite_1.start_time = time
        sprite_1.start_index = 1
        sprite_1.index = 1
        sprite_1.fps = 40
        $window.scoreboard['targets'] += 1
        if $window.scoreboard['targets'] >= 3
          Resources::Sounds['success'].play
        end
      end
      
      entity_2_hit_by.each do |hit|
        Resources::Sounds['target_break'].play
        sprite_2.mode = 'forward'
        sprite_2.start_time = time
        sprite_2.start_index = 1
        sprite_2.index = 1
        sprite_2.fps = 40
        $window.scoreboard['targets'] += 1
        if $window.scoreboard['targets'] >= 3
          Resources::Sounds['success'].play
        end
      end
      
      
    end
  end
  
  def update_ticks
    @entity_manager.entities_with_components(:Sprite, :Drawable).combination(2).each do |entity_1, entity_2|
      hit_immunities_1  = @entity_manager.get_component entity_1, :HitImmunities
      hit_immunities_2  = @entity_manager.get_component entity_2, :HitImmunities
      
      sprite_1          = @entity_manager.get_component entity_1, :Sprite
      sprite_2          = @entity_manager.get_component entity_2, :Sprite
      
      sprite_1_resource = Resources::Sprites[sprite_1.sprite_resource_path]
      sprite_2_resource = Resources::Sprites[sprite_2.sprite_resource_path]
      
      shapes_1          = sprite_1_resource['frames'][sprite_1.index]['shapes']
      shapes_2          = sprite_2_resource['frames'][sprite_2.index]['shapes']
            
      if sprite_1.index != sprite_1.prev_index
        takes_damage_shapes_2 = shapes_2.select { |shape| shape['tags'].include? 'takes_damage' }
        deals_damage_shapes_1 = shapes_1.select { |shape| shape['tags'].include? 'deals_damage' }
        
        deals_damage_shapes_1.product(takes_damage_shapes_2).each do |deals_damage_shape, takes_damage_shape|
          if deals_damage_shape['tags'].include? 'tick'
            hit_id = SystemHelpers::Hit.hit_id @entity_manager, entity_1, deals_damage_shape
            hit_immunities_2.hit_ids.delete hit_id 
          end
        end
      end
      
      if sprite_2.index != sprite_2.prev_index
        takes_damage_shapes_1 = shapes_1.select { |shape| shape['tags'].include? 'takes_damage' }
        deals_damage_shapes_2 = shapes_2.select { |shape| shape['tags'].include? 'deals_damage' }
        
        deals_damage_shapes_2.product(takes_damage_shapes_1).each do |deals_damage_shape, takes_damage_shape|
          if deals_damage_shape['tags'].include? 'tick'
            hit_id = SystemHelpers::Hit.hit_id @entity_manager, entity_2, deals_damage_shape
            hit_immunities_1.hit_ids.delete hit_id
          end
        end
      end
    end
  end
  
  def each_shape_colliding shapes_1, shapes_2, distance_x, distance_y, &block
    shapes_1.product(shapes_2).each do |shape_1, shape_2|
      if shape_hit? shape_1, shape_2, distance_x, distance_y
        block.call(shape_1)
        block.call(shape_2)
      end
    end
  end
  
  def shape_hit? shape_1, shape_2, distance_x, distance_y, factor_x_1, factor_x_2
    shape_1_convexes = []
    shape_2_convexes = []
    
    shape_1['convexes'].each do |convex|
      c = []
      convex.each do |point|
        c << [point[0]*factor_x_1, point[1]]
      end
      shape_1_convexes << c
    end
    
    shape_2['convexes'].each do |convex|
      c = []
      convex.each do |point|
        c << [point[0]*factor_x_2+distance_x, point[1]+distance_y]
      end
      shape_2_convexes << c
    end
    
    shape_1_convexes.each do |convex_1|
      shape_2_convexes.each do |convex_2|
        return true if ShapeHelper::ShapeCollision.overlap? convex_1, convex_2
      end
    end
    
    return false
  end
end