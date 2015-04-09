WindowStates::GameSession::Systems::CharacterAnimationStates.create_class __FILE__ do
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    
    WindowStates::GameSession::Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'start_time' => time,
      'mode' => 'forward',
      'index' => 0,
      'start_index' => 0
    }
    
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
    when 'jump'
      controls = @entity_manager.get_component entity, :Controls
      left_or_right = controls.held.select { |control| ['left', 'right'].include? control }
      if left_or_right.last
        drawable = @entity_manager.get_component entity, :Drawable
        drawable.factor_x = left_or_right.last == 'right' ? 1 : -1
        character.set_animation_state = 'jump_up'
      else
        character.set_animation_state = 'jump_up'
      end
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
        WindowStates::GameSession::Systems::Commands::SpriteSwap.do @entity_manager, entity, 'sprite_hash' => {
          'sprite_resource_path' => ["characters", character.type, character.animation_state],
          'start_time' => time,
          'mode' => 'backward',
          'index' => sprite.index,
          'start_index' => sprite.index
        }
    
        character.queued_animation_state = 'run'
        
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