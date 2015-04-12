module Easers
  Dir[File.join(GAME_LIB_PATH, 'easers', '*.rb')].each { |rb| require rb }
end