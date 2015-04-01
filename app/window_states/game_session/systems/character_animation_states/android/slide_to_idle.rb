WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    
    set_sprite_command = WindowStates::GameSession::Commands::SetSprite.new @entity_manager, entity, {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'fps' => :sprite_resource_fps,
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
    set_sprite_command.do!
    
    character.queued_animation_state = 'idle'
    
    _stats          = stats(entity)
    speed           = 0
    transition_time = _stats['stop_transition_time']
    transition_to_speed_point_10 entity, time, speed, transition_time
  end
  
  def control_down entity, control, time
    character = @entity_manager.get_component entity, :Character
    
    case control
    when 'attack'
      character.queued_animation_state = 'punch_1'
    end
  end
  
  def update entity, time
    sprite    = @entity_manager.get_component entity, :Sprite
    character = @entity_manager.get_component entity, :Character
    
    if character.queued_animation_state == 'idle' && ((5..6) === sprite.index)
      controls  = @entity_manager.get_component entity, :Controls
      drawable  = @entity_manager.get_component entity, :Drawable
      
      left_or_right = controls.held.select { |control| ['left', 'right'].include? control }
      if (drawable.factor_x > 0 && left_or_right.last == 'right') || (drawable.factor_x < 0 && left_or_right.last == 'left')
        set_sprite_command = WindowStates::GameSession::Commands::SetSprite.new @entity_manager, entity, {
          'sprite_resource_path' => ["characters", character.type, character.animation_state],
          'fps' => :sprite_resource_fps,
          'start_time' => time,
          'mode' => 'backward',
          'index' => sprite.index,
          'start_index' => sprite.index
        }
    
        character.queued_animation_state = 'run'
    
        set_sprite_command.do!
        
        _stats = stats(entity)
        speed           = _stats['run_speed']*drawable.factor_x
        transition_time = _stats['run_transition_time']
        transition_to_speed_point_10 entity, time, speed, transition_time
      end
    end
    
    if sprite.done
      character.set_animation_state = character.queued_animation_state
    end
  end
end