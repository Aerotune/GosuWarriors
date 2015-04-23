class WindowStates::GameSession::Systems::CharacterStageCollisionSystem
  def initialize game_session
    @stage = game_session.stage
    @entity_manager = game_session.entity_manager
  end
  
  def update time
    stage = @stage
    
    @entity_manager.each_entity_with_component :Character do |entity, character|
      sprite = @entity_manager.get_component entity, :Sprite
      drawable = @entity_manager.get_component entity, :Drawable
      
      next unless sprite && drawable
      
      sprite_resource = Resources::Sprites[sprite.sprite_resource_path]
      bounding_box = ShapeHelper.translate sprite_resource['bounding_box'], drawable.x, drawable.y
      
      wall_facing_right_x = nil
      wall_facing_left_x  = nil
      ceiling_y           = nil
      
      stage['shapes'].each_with_index do |shape, shape_index|
        shape['outline'].each_with_index do |point_1, point_1_index|
          point_2_index = (point_1_index + 1) % shape['outline'].length
          point_2 = shape['outline'][point_2_index]
          
          dx = point_2[0] - point_1[0]
          dy = point_2[1] - point_1[1]
          
          is_wall = dx == 0
          is_ceiling = dy == 0 && dx < 0
          
          
          stage_collisions = character['stage_collisions']
          if is_wall
            if dy > 0
              #wall is facing right
              if ShapeHelper::ShapeCollision.overlap? bounding_box, [point_1, point_2]
                wall_facing_right_x ||= point_1[0]
                wall_facing_right_x = point_1[0] if point_1[0] > wall_facing_right_x
              end
            elsif dy < 0
              #wall is facing left
              if ShapeHelper::ShapeCollision.overlap? bounding_box, [point_1, point_2]
                wall_facing_left_x ||= point_1[0]
                wall_facing_left_x = point_1[0] if point_1[0] < wall_facing_left_x
              end
            end
          end
          
          if is_ceiling
            if ShapeHelper::ShapeCollision.overlap? bounding_box, [point_1, point_2]
              ceiling_y ||= point_1[1]
              ceiling_y = point_1[1] if point_1[1] > ceiling_y
            end
          end
        end
      end
      
      #change implicit
      character['stage_collisions']['wall_facing_right_x'] = wall_facing_right_x
      character['stage_collisions']['wall_facing_left_x']  = wall_facing_left_x
      character['stage_collisions']['ceiling_y']           = ceiling_y
    end
    
    @entity_manager.each_entity_with_component :FreeMotionX do |entity, free_motion_x|
      free_motion_y = @entity_manager.get_component entity, :FreeMotionY
      drawable = @entity_manager.get_component entity, :Drawable
      character = @entity_manager.get_component entity, :Character
      
      x = drawable.x
      y = drawable.y
      prev_x = drawable.prev_x
      prev_y = drawable.prev_y    
            
      hit_shape_indexes = []
      
      stage['shapes'].each_with_index do |shape, shape_index|
        shape['convexes'].each do |convex_points|
          if ShapeHelper::ShapeCollision.overlap? convex_points, [[x, y], [prev_x, prev_y]]
            hit_shape_indexes << shape_index unless hit_shape_indexes.include? shape_index
          end
        end
      end
      
      #!!!
      hit_shape_indexes.each do |hit_shape_index|
        shape = stage['shapes'][hit_shape_index]
        
        walkable_condition = ->(point_1, point_2) {ShapeHelper::Walk.walkable?(point_1, point_2)}
        
        #line = [[prev_x, prev_y], [x, y]]
        #start_point_index, start_point_distance = ShapeHelper::LineCollision.point_index_and_distance_along_line shape['outline'], line, &walkable_condition
        
        start_point_index, start_point_distance = ShapeHelper::Point.point_index_and_distance_along_line shape['outline'], x, y, &walkable_condition
        
        if start_point_index && start_point_distance
          character['stage_collisions']['path_movement']['hit_shape_index']      = hit_shape_index
          character['stage_collisions']['path_movement']['start_point_index']    = start_point_index
          character['stage_collisions']['path_movement']['start_point_distance'] = start_point_distance
          
          #character.set_animation_state = 'land'
          break
        end
        
      end
      
    end
  end
end