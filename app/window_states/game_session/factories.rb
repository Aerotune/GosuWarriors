module WindowStates::GameSession::Factories
  Dir[File.join(GAME_SESSION_PATH, *%w[factories *.rb])].each { |file| require file }
end