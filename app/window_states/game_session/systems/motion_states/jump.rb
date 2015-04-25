module Systems::MotionStates::Jump
  extend Systems::MotionState
  
  class << self
    def set game_session, entity, time
      entity_manager = game_session.entity_manager
      character = entity_manager.get_component entity, :Character
      drawable  = entity_manager.get_component entity, :Drawable
      controls  = entity_manager.get_component entity, :Controls
      
      path_speed_point_10 = SystemHelpers::PathMotion.speed_point_10 entity_manager, entity, time
      
      drawable.prev_y -= 2
      drawable.y      -= 2
      set_free_motion entity_manager, entity, time, drawable.x, drawable.y
      
      free_motion_y entity_manager, entity, time, \
        'start_speed_point_10' => ANDROID_JUMP_SPEED_POINT_10, 
        'end_speed_point_10' => ANDROID_END_SPEED_POINT_10,
        'transition_time' => ANDROID_TRANSITION_TIME_Y,
        'easer' => 'sin_out'
      
      unless controls.held.detect { |control| control == 'jump' }
        fall entity_manager, entity, time
      end
      
      stats = character_stats entity_manager, entity
      x_speed_point_10 = \
      case controls.held.select { |control| ['left', 'right'].include? control }.last
      when 'left'; -stats['run_speed']
      when 'right'; stats['run_speed']
      else
        0
      end
      free_motion_x entity_manager, entity, time, \
        'start_speed_point_10' => path_speed_point_10,
        'end_speed_point_10' => x_speed_point_10,
        'transition_time' => 5_0
    end
  
    def update entity_manager, entity, time
      character      = entity_manager.get_component entity, :Character
      _free_motion_y = entity_manager.get_component entity, :FreeMotionY      
      _free_motion_y_time = time - _free_motion_y['start_time']
      time_left = _free_motion_y['transition_time'] - _free_motion_y_time
      character.set_motion_state = 'Fall' if time_left <= _free_motion_y['transition_time']/6
    end
    
    def fall entity_manager, entity, time
      _free_motion_y = entity_manager.get_component entity, :FreeMotionY
    
      if _free_motion_y['start_speed_point_10'] == ANDROID_JUMP_SPEED_POINT_10
        speed_y_point_10 = SystemHelpers::FreeMotion.speed_y_point_10 entity_manager, entity, time
        progress_point_10 = ((time - _free_motion_y['start_time'])<<10) / _free_motion_y['transition_time'] 
        remaining_transition_time = (((1<<10) - progress_point_10) * _free_motion_y['transition_time']) >> 10
        free_motion_y entity_manager, entity, time, \
          'start_speed_point_10' => speed_y_point_10, 
          'end_speed_point_10' => ANDROID_END_SPEED_POINT_10,
          'transition_time' => remaining_transition_time / 2,
          'easer' => 'sin_out'
      end
    end
    
    def control_down game_session, entity, control, time
      entity_manager = game_session.entity_manager
      case control
      when 'left'
        float_speed entity_manager, entity, time, -1
      when 'right'
        float_speed entity_manager, entity, time, 1
      end
    end
  
    def control_up game_session, entity, control, time
      entity_manager = game_session.entity_manager
      controls = entity_manager.get_component entity, :Controls
      case control
      when 'right'
        if controls.held.detect { |control| control == 'left' }
          float_speed entity_manager, entity, time, -1
        else
          float_speed entity_manager, entity, time, 0
        end
      when 'left'
        if controls.held.detect { |control| control == 'right' }
          float_speed entity_manager, entity, time, 1
        else
          float_speed entity_manager, entity, time, 0
        end
      when 'jump'
        fall entity_manager, entity, time
      end
    end
  end
end