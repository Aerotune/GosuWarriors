WindowStates::GameSession::Systems::CharacterAnimationStates.generalize_class :run do
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def on_set entity, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
        
    set_sprite_command = WindowStates::GameSession::Commands::SetSprite.new @entity_manager, entity, {
      'sprite_resource_path' => ["characters", character.type, character.animation_state],
      'fps' => 32,
      'start_time' => time,
      'mode' => 'loop',
      'index' => 0,
      'start_index' => 0
    }    
    set_sprite_command.do!
    
    transition_to_speed_point_10 entity, time, 12_000*drawable.factor_x, 40
  end
  
  def control_down entity, control, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    case control
    when 'right'
      if drawable.factor_x < 0
        character.set_animation_state = 'slide_to_idle'
      end
    when 'left'
      if drawable.factor_x > 0
        character.set_animation_state = 'slide_to_idle'
      end
    end
  end
  
  def control_up entity, control, time
    character = @entity_manager.get_component entity, :Character
    drawable  = @entity_manager.get_component entity, :Drawable
    
    case control
    when 'right'
      if drawable.factor_x > 0
        character.set_animation_state = 'slide_to_idle'
      end
    when 'left'
      if drawable.factor_x < 0
        character.set_animation_state = 'slide_to_idle'
      end
    end
  end
  
  def update entity, time
    character = @entity_manager.get_component entity, :Character
    controls  = @entity_manager.get_component entity, :Controls
    drawable  = @entity_manager.get_component entity, :Drawable
    
    if drawable.factor_x > 0
      unless controls.held.include? 'right'
        character.set_animation_state = 'slide_to_idle'
      end
    else
      unless controls.held.include? 'left'
        character.set_animation_state = 'slide_to_idle'
      end
    end
  end
end