module SystemHelpers
  Dir[File.join(GAME_SESSION_PATH, *%w[system_helpers *.rb])].each { |file| require file }
end