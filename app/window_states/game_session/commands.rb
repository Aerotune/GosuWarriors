module WindowStates::GameSession::Commands
  Dir[File.join(GAME_SESSION_PATH, *%w[commands *.rb])].each { |file| require file }
end