class Systems::MotionStates
  Dir[File.join(GAME_SESSION_PATH, 'systems', 'motion_states', '*.rb')].each { |file| require file }
end