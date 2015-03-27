class WindowStates::GameSession::Systems::CharacterAnimationStates
  @@animation_state_classes = {}
  
  def self.create_class file, &block
    character = File.basename(File.dirname(file))
    state     = File.basename(file, '.rb')
    @@animation_state_classes[character] ||= {}
    @@animation_state_classes[character][state] = Class.new WindowStates::GameSession::Systems::CharacterAnimationState, &block    
  end
  
  Dir[File.join(GAME_SESSION_PATH, *%w[systems character_animation_states ** *.rb])].each { |file| require file }
  
  def initialize entity_manager
    @entity_manager = entity_manager
    @animation_state = {}
    @@animation_state_classes.each do |character_type, animation_state_classes|
      @animation_state[character_type] ||= {}
      animation_state_classes.each do |animation_state, animation_state_klass|
        @animation_state[character_type][animation_state] = animation_state_klass.new(@entity_manager)
      end
    end
  end
  
  def key_down key, time
    @entity_manager.each_entity_with_component :Character do |entity, character|
      next unless character.control_type == "player"
      animation_state(character).key_down entity, key, time
    end
  end
  
  def key_up key, time
    @entity_manager.each_entity_with_component :Character do |entity, character|
      next unless character.control_type == "player"
      animation_state(character).key_up entity, key, time
    end
  end
  
  def update time
    @entity_manager.each_entity_with_component :Character do |entity, character|
      animation_state = @animation_state[character.type][character.animation_state]
      animation_state.update entity, time if animation_state
      
      if character.set_animation_state        
        next_animation_state = @animation_state[character.type][character.set_animation_state]
        if next_animation_state
          prev_animation_state = @animation_state[character.type][character.animation_state]
          
          character.animation_state = character.set_animation_state
          character.set_animation_state = nil
          
          prev_animation_state.on_unset entity, time if prev_animation_state
          next_animation_state.on_set   entity, time
        end
      end      
    end
  end
  
  private
  
  def animation_state character
    @animation_state[character.type][character.animation_state]
  end
end