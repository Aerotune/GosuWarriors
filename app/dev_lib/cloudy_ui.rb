require 'gosu'

module CloudyUi
  BUILTIN_THEMES_DIR = File.join(File.dirname(__FILE__), '../data/themes').freeze
  
  BUILTIN_THEMES = {
    cloudy: File.join(BUILTIN_THEMES_DIR, 'cloudy').freeze
  }.freeze
  
  INACTIVE_TEXT_COLOR = 0xFF708090
  NEUTRAL_TEXT_COLOR  = 0xFF555555
  
  require_relative 'cloudy_ui/radio_button'
  require_relative 'cloudy_ui/button'
  require_relative 'cloudy_ui/slider'
  require_relative 'cloudy_ui/scrollbar'
  require_relative 'cloudy_ui/window'
  require_relative 'cloudy_ui/dynamic_field'
  
  def self.load_images window, theme = :cloudy
    load_path = File.join(DEV_LIB_PATH, 'cloudy_ui', 'images')
    CloudyUi::RadioButton .load_images window, load_path
    CloudyUi::Button      .load_images window, load_path
    CloudyUi::Slider      .load_images window, load_path
    CloudyUi::Scrollbar   .load_images window, load_path
  end
end