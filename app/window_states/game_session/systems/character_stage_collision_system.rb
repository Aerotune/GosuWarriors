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
    
    @entity_manager.each_entity_with_component :FreeMotionX do |entity, free_motion_x|
      drawable = @entity_manager.get_component entity, :Drawable
      character = @entity_manager.get_component entity, :Character
      
      x = drawable.x
      y = drawable.y
      
      speed_x_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_x_point_10(@entity_manager, entity, time)
      speed_y_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_y_point_10(@entity_manager, entity, time)      
      air_speed = IntMath.distance(0,0, speed_x_point_10, speed_y_point_10) >> 10
      
      prev_x = WindowStates::GameSession::SystemHelpers::FreeMotion.x(@entity_manager, entity, time-1)
      prev_y = WindowStates::GameSession::SystemHelpers::FreeMotion.y(@entity_manager, entity, time-1)
      
      sprite_frame = WindowStates::GameSession::SystemHelpers::Sprite.current_frame @entity_manager, entity      
      
      
      #Front hit test
      
      #front_line = sprite_resource['front_line']
      #
      #front_hit_shape = [
      #  [prev_x+front_line[0][0], prev_y+front_line[0][1]],
      #  [prev_x+front_line[1][0], prev_y+front_line[1][1]],
      #  [x+front_line[1][0], y+front_line[1][1]],
      #  [x+front_line[0][0], y+front_line[0][1]]
      #]
      
      #stage['shapes'].each_with_index do |shape, shape_index|
      #  shape['convexes'].each do |convex_points|
      #    if ShapeHelper::ShapeCollision.overlap? convex_points, front_hit_shape
      #      puts "Front hit!: #{shape_index}"
      #    end
      #  end
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
            
      stage['shapes'].each_with_index do |shape, shape_index|
        shape['convexes'].each do |convex_points|
          if ShapeHelper::ShapeCollision.overlap? convex_points, feet_hit_shape
            hit = true
            hit_shape_indexes << shape_index unless hit_shape_indexes.include? shape_index
          end
          
          #if ShapeHelper::ShapeCollision.overlap? convex_points, front_hit_shape
          #  puts "Front hit!: #{shape_index}"
          #end
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
          
          if line_collision || (land_distance < (air_speed*3+75))
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