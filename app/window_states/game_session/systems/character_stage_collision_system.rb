class WindowStates::GameSession::Systems::CharacterStageCollisionSystem
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def update time
    stage = Resources::Stages['test_level']
    $stage = stage
    #@entity_manager.each_entity_with_component :Character do |entity, character|
    #  sprite_resource = WindowStates::GameSession::SystemHelpers::Sprite.sprite_resource @entity_manager, entity
    #end
    # Use only vertical and horizontal walls and ceilings
    # Push character out of ceilings
    # Push character out of walls
    # Place character on walkable surfaces
    
    @entity_manager.each_entity_with_component :FreeMotionX do |entity, free_motion_x|
      free_motion_y = @entity_manager.get_component entity, :FreeMotionY
      drawable = @entity_manager.get_component entity, :Drawable
      character = @entity_manager.get_component entity, :Character
      
      x = drawable.x
      y = drawable.y
      
      speed_x_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_x_point_10(@entity_manager, entity, time)
      speed_y_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_y_point_10(@entity_manager, entity, time)      
      air_speed = IntMath.distance(0,0, speed_x_point_10, speed_y_point_10) >> 10
      
      prev_x = WindowStates::GameSession::SystemHelpers::FreeMotion.x(@entity_manager, entity, time-1)
      prev_y = WindowStates::GameSession::SystemHelpers::FreeMotion.y(@entity_manager, entity, time-1)
      #next_x = WindowStates::GameSession::SystemHelpers::FreeMotion.x(@entity_manager, entity, time-1)
      #next_y = WindowStates::GameSession::SystemHelpers::FreeMotion.y(@entity_manager, entity, time-1)
      
      sprite_frame = WindowStates::GameSession::SystemHelpers::Sprite.current_frame @entity_manager, entity            
      #whole_body_shapes = sprite_frame['shapes'].select { |shape| shape['tags'].include? 'whole_body' }
      #mtv_x_result = nil
      #mtv_y_result = nil
      #mtv_x_max = nil
      #mtv_y_max = nil
      #mtv_result_square_dist = nil
      #
      #stage['shapes'].each_with_index do |shape, shape_index|
      #  shape['convexes'].each do |convex_points|
      #    whole_body_shapes.each do |whole_body_shape|
      #      points = ShapeHelper.translate whole_body_shape['convex_hull'], x, y
      #      mtv_x, mtv_y = ShapeHelper::ShapeCollision.mtv convex_points, points
      #      if mtv_x && mtv_y
      #        mtv_result_square_dist ||= mtv_x**2 + mtv_y**2
      #        mtv_x_result       ||= mtv_x
      #        mtv_y_result       ||= mtv_y
      #        
      #        mtv_square_dist = mtv_x**2 + mtv_y**2
      #        
      #        if mtv_square_dist > mtv_result_square_dist
      #          mtv_x_result = mtv_x #if mtv_x.abs < mtv_x_min.abs
      #          mtv_y_result = mtv_y #if mtv_y.abs < mtv_y_min.abs
      #          #mtv_x_max = mtv_x if mtv_x.abs < mtv_x_max.abs
      #          #mtv_y_max = mtv_y if mtv_y.abs < mtv_y_max.abs
      #        end
      #        
      #        
      #        
      #        #min, max = ShapeHelper.project(convex_points, 1, 0)
      #        #free_motion_x.start_x = x-air_speed/2-1 + (x-next_x)
      #        #free_motion_x.start_time = time
      #        #free_motion_x.start_speed_point_10 = 0
      #      end
      #    end
      #  end
      #end
      
      #if mtv_x_result && mtv_y_result
      #  free_motion_x.start_x += mtv_x_result
      #  free_motion_y.start_y += mtv_y_result
      #  x += mtv_x_result
      #  y += mtv_y_result
      #  #p [mtv_x_min, mtv_y_min]
      #end
      
      # Feet hit test
      next unless speed_y_point_10 > 0
      
      sprite_resource = WindowStates::GameSession::SystemHelpers::Sprite.sprite_resource @entity_manager, entity
      feet_line = sprite_resource['feet_line']
      feet_hit_shape = [
        [prev_x+feet_line[0][0], prev_y+feet_line[0][1]],
        [prev_x+feet_line[1][0], prev_y+feet_line[1][1]],
        [x+feet_line[1][0], y+feet_line[1][1]],
        [x+feet_line[0][0], y+feet_line[0][1]]
      ]
      
      hit = false
      hit_shape_indexes = []
      dx, dy = nil, nil
            
      stage['shapes'].each_with_index do |shape, shape_index|
        shape['convexes'].each do |convex_points|
          if ShapeHelper::ShapeCollision.overlap? convex_points, feet_hit_shape
            hit = true
            hit_shape_indexes << shape_index unless hit_shape_indexes.include? shape_index
          end
        end
      end
      
      
      warn "Multiple hit shapes when character hit map" if hit_shape_indexes.length > 1
      hit_shape_index = hit_shape_indexes.first
      
      if hit
        shape = stage['shapes'][hit_shape_index]
        
        walkable_condition = ->(point_1, point_2) {ShapeHelper::Walk.walkable?(point_1, point_2)}
        
        line = [[prev_x, prev_y], [x, y]]
      
        start_point_index, start_point_distance = ShapeHelper::LineCollision.point_index_and_distance_along_line shape['outline'], line, &walkable_condition
        line_collision = true if start_point_index
        if start_point_index.nil?
          start_point_index, start_point_distance = ShapeHelper::Point.point_index_and_distance_along_line shape['outline'], x, y, &walkable_condition
        end
        
        if start_point_index && start_point_distance
          land_x, land_y = ShapeHelper::Path.position shape['outline'], start_point_index, start_point_distance
          land_distance = [IntMath.distance(x, y, land_x, land_y), IntMath.distance(prev_x, prev_y, land_x, land_y)].min
          
          if line_collision || (land_distance < (air_speed*5+25))
            @entity_manager.remove_component entity, :FreeMotionX
            @entity_manager.remove_component entity, :FreeMotionY
            
            WindowStates::GameSession::Systems::Commands::PathStartSet.do @entity_manager, entity, \
            'shape_index' => hit_shape_index,
            'start_point_index' => start_point_index,
            'start_point_distance' => start_point_distance
            
            if start_point_distance == 0
              if speed_x_point_10 < 0
                point_1_index = (start_point_index - 1) % shape['outline'].length
                point_2_index = (start_point_index    ) % shape['outline'].length
              else
                point_1_index = (start_point_index    ) % shape['outline'].length
                point_2_index = (start_point_index + 1) % shape['outline'].length
              end
            elsif start_point_distance > 0
              point_1_index = (start_point_index    ) % shape['outline'].length
              point_2_index = (start_point_index + 1) % shape['outline'].length
            elsif start_point_distance < 0
              point_1_index = (start_point_index - 1) % shape['outline'].length
              point_2_index = (start_point_index    ) % shape['outline'].length
            end
            
            point_1 = shape['outline'][point_1_index]
            point_2 = shape['outline'][point_2_index]
            
            line_length, axis_x_point_12, axis_y_point_12 = ShapeHelper::Line.line_length_and_axis_point_12 point_1, point_2
            
            start_speed_point_10 = ((axis_x_point_12 * speed_x_point_10) >> 12)*8/10 + ((axis_y_point_12 * speed_y_point_10)>>12)
        
            @entity_manager.add_component entity, WindowStates::GameSession::Components::PathMotionContinuous.new(
              'id'                   => 0,
              'start_time'           => time,
              'start_speed_point_10' => start_speed_point_10,
              'end_speed_point_10'   => 0,
              'duration'             => 60
            )
            
            character.set_animation_state = 'land'
          end
        end
        
      end
      
    end
  end
end