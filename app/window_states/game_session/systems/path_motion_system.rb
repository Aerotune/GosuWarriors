class WindowStates::GameSession::Systems::PathMotion
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def update time
    stage = Resources::Stages['test_level']
    #spawn       = stage['spawn']
    #shape_index = spawn['shape_index']
    #shape       = stage['shapes'][shape_index]
    
    @entity_manager.each_entity_with_component :PathStart do |entity, path_start|
      drawable = @entity_manager.get_component entity, :Drawable
      distance = WindowStates::GameSession::SystemHelpers::PathMotion.distance @entity_manager, entity, time
      shape    = stage['shapes'][path_start['shape_index']]
      
      points = shape['outline']
      point_index, distance_along_line, distance_to_point = ShapeHelper::Walk.point_index_and_distance_along_line points, path_start['start_point_index'], distance
      if distance != distance_to_point+distance_along_line
        #!!! this is fine offline but I don't want a ton of commands every time this happens online
        #path_start.distance -= distance - (distance_to_point+distance_along_line) 
        character = @entity_manager.get_component entity, :Character
        #animation_state = WindowStates::GameSession::Systems::CharacterAnimationStates.animation_state(character.type, 'jump_down')
        #animation_state.set_free_motion entity, time
        character.set_animation_state = 'fall_down'        
      end
      
      position = ShapeHelper::Path.position(points, point_index, distance_along_line)
      
      drawable.x = position[0]
      drawable.y = position[1]
    end
  end
end