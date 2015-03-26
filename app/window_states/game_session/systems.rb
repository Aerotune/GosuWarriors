module Systems
  Dir[File.join(GAME_SESSION_PATH, *%w[systems *.rb])].each { |file| require file }
end