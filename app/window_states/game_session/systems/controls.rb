class WindowStates::GameSession::Systems::Controls  
  def initialize entity_manager
    @entity_manager = entity_manager
    @control_resource = Resources::Controls.new
    @pressed = []
    @released = []
  end
  
  def key_down key
    @entity_manager.each_entity_with_component :Controls do |entity, controls|
      @pressed << @control_resource.control_for_key(key)
    end
  end
  
  def key_up key
    @entity_manager.each_entity_with_component :Controls do |entity, controls|
      @released << @control_resource.control_for_key(key)
    end
  end
  
  def update
    @entity_manager.each_entity_with_component :Controls do |entity, controls|
      controls.held.clear
      KEY_SYMBOLS.values.each do |key|
        control_id = @control_resource.control_for_key(key)
        controls.held << control_id if $window.key_down? key
      end
      
      controls.pressed.clear
      controls.released.clear
      
      controls.pressed.push *@pressed
      controls.released.push *@released
    end
    @pressed.clear
    @released.clear
  end
end