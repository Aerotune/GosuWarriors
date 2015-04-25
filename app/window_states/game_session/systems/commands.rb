class Systems::Commands  
  Dir[File.join(GAME_SESSION_PATH, 'systems', 'commands', '*.rb')].each { |file| require file }
  
  def initialize entity_manager
    @entity_manager = entity_manager
  end
  
  def do command
    
  end
  
  def undo command
    
  end
end