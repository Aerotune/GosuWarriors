module WindowStates::GameSession::Components
  Dir[File.join(GAME_SESSION_PATH, *%w[components *.rb])].each { |file| require file }
end