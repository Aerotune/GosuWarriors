class WindowState
  def update; end
  def draw; end
  def key_down symbol; end
  def key_up symbol; end
  def on_set; end
end

module WindowStates
  Dir[File.join(WINDOW_STATES_PATH, '*.rb')].each { |file| require file }
end