module WindowStates::GameSession::Systems::MotionStates::JumpInAir
  extend WindowStates::GameSession::Systems::MotionState
  
  class << self
    def set entity_manager, entity, time
      #sprite    = @entity_manager.get_component entity, :Sprite
      character = entity_manager.get_component entity, :Character
      drawable  = entity_manager.get_component entity, :Drawable
      controls  = entity_manager.get_component entity, :Controls
      stats = character_stats entity_manager, entity
      
      free_motion_y entity_manager, entity, time, \
        'start_speed_point_10' => ANDROID_JUMP_IN_AIR_SPEED_POINT_10, 
        'end_speed_point_10' => ANDROID_END_SPEED_POINT_10,
        'transition_time' => ANDROID_JUMP_IN_AIR_TRANSITION_TIME_Y,
        'easer' => 'quad_in_out'
      controls       = entity_manager.get_component entity, :Controls
      _free_motion_x = entity_manager.get_component entity, :FreeMotionX
      speed_x_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_x_point_10 entity_manager, entity, time
      x_speed = case controls.held.select { |control| ['left', 'right'].include? control }.last
      when 'left'; -stats['run_speed']
      when 'right'; stats['run_speed']
      else
        0
      end
      free_motion_x entity_manager, entity, time, \
        'start_speed_point_10' => speed_x_point_10,
        'end_speed_point_10' => x_speed,
        'transition_time' => 5_0
    end
  
    JUMP_SPEED_POINT_10 = -24_000
    END_SPEED_POINT_10  = 0#29_400
    TRANSITION_TIME_Y   = 32
  
    def control_down entity_manager, entity, control, time
      sprite = entity_manager.get_component entity, :Sprite
      
      case control
      when 'left'
        float_speed entity_manager, entity, time, -1
      when 'right'
        float_speed entity_manager, entity, time, 1
      end
    end
  
    def control_up entity_manager, entity, control, time
      sprite   = entity_manager.get_component entity, :Sprite    
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
  
    def fall entity_manager, entity, time
      _free_motion_y = entity_manager.get_component entity, :FreeMotionY
    
      if _free_motion_y && _free_motion_y['start_speed_point_10'] == ANDROID_JUMP_IN_AIR_SPEED_POINT_10
        speed_y_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_y_point_10 entity_manager, entity, time
        progress_point_10 = ((time - _free_motion_y['start_time'])<<10) / _free_motion_y['transition_time'] 
        remaining_transition_time = (((1<<10) - progress_point_10) * _free_motion_y['transition_time']) >> 10
        free_motion_y entity_manager, entity, time, \
          'start_speed_point_10' => speed_y_point_10, 
          'end_speed_point_10' => END_SPEED_POINT_10,
          'transition_time' => remaining_transition_time * 4 / 10,
          'easer' => 'quad_in_out'
      end
    end
  
    def update entity_manager, entity, time
      character = entity_manager.get_component entity, :Character
      controls  = entity_manager.get_component entity, :Controls
      _free_motion_y = entity_manager.get_component entity, :FreeMotionY
    
      speed_y_point_10 = WindowStates::GameSession::SystemHelpers::FreeMotion.speed_y_point_10 entity_manager, entity, time
    
      
      if _free_motion_y
        _free_motion_y_time = time - _free_motion_y['start_time']
        time_left = _free_motion_y['transition_time'] - _free_motion_y_time
        if time_left <= _free_motion_y['transition_time']/6
          character.set_motion_state = 'Fall'
        end
      end
    end
  end
end