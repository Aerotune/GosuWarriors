module Resources
  Dir[File.join(GAME_LIB_PATH, 'resources', '*.rb')].each { |file| require file }
end