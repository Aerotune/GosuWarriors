module SystemHelpers::Character
  class << self
    def stats game_session, entity
      character = game_session.entity_manager.get_component entity, :Character
      Resources::CharacterStats[character.type]
    end
  end
end