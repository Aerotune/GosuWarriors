module Systems
  require_relative 'system_helpers'
  Dir[File.join(GAME_SESSION_PATH, *%w[systems *.rb])].each { |file| require file }
end