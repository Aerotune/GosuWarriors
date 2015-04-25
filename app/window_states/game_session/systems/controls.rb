class Systems::Controls  
  def initialize game_session
    @game_session   = game_session
    @entity_manager = game_session.entity_manager
    @control_resource = Resources::Controls.new
  end
  
  def key_down key
    @entity_manager.each_entity_with_component :Controls do |entity, controls|
      controls.pressed << @control_resource.control_for_key(key)
      controls.held    << @control_resource.control_for_key(key)
    end
  end
  
  def key_up key
    @entity_manager.each_entity_with_component :Controls do |entity, controls|
      control_id = @control_resource.control_for_key(key)
      controls.pressed.delete control_id
      controls.held.delete control_id
      controls.released << control_id
    end
  end
  
  def update
    @entity_manager.each_entity_with_component :Controls do |entity, controls|
      KEY_SYMBOLS.values.each do |key|
        control_id = @control_resource.control_for_key(key)
        
        controls.pressed.each do |control_id|
          if $window.key_down? key
            controls.held << control_id
          end
        end
        
        controls.pressed.clear
        controls.released.clear
      end
    end
  end
end