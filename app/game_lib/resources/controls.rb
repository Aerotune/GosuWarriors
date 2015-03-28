class Resources::Controls
  attr_reader :control_id
  
  def initialize settings='default'
    settings_path         = File.join SETTINGS_PATH, 'controls', "#{settings}.yaml"
    @control_id           = YAML.parse_file(settings_path).to_ruby
    #@control_id_down_time = {}
    #@control_id_up_time   = {}
    #@buffer               = []
    #@controls_down        = []
  end
  
  def control_for_key key
    @control_id.key(key)
  end
  
  #def deactivate! time
  #  @deactivated = true
  #  @controls_down.each do |control|
  #    control_up control, time
  #  end
  #end
  #
  #def activate! time
  #  @deactivated = false
  #end
  #
  #def on_control_down &block
  #  @on_control_down = block
  #end
  #
  #def on_control_up &block
  #  @on_control_up = block
  #end
  #
  #def latest_control_still_down *control_ids
  #  control_ids
  #  .select { |control_id| @controls_down.include? control_id }
  #  .min_by { |control_id| time_since_control_down(control_id) }
  #end  
  #
  #def latest_control_down *control_ids
  #  control_ids.min_by { |control_id| time_since_control_down(control_id) }
  #end
  #
  #def button_down button_id, time
  #  key_symbol = KEY_SYMBOLS[button_id]
  #  control_id = @control_id[key_symbol]
  #  control_down control_id, time if control_id
  #end
  #
  #def control_down? control_id
  #  return false if @deactivated
  #  key_symbol = @control_id.key control_id
  #  button_id = KEY_SYMBOLS.key(key_symbol)
  #  $window.button_down? button_id
  #end
  #
  #def button_up button_id, time
  #  key_symbol = KEY_SYMBOLS[button_id]
  #  control_id = @control_id[key_symbol]
  #  control_up control_id, time if control_id
  #end
  #
  #
  #def control_up? control_id
  #  return true if @deactivated
  #  !control_down?(control_id)
  #end
  #
  #def time_since_control_down control_id, current_time
  #  if @control_id_down_time.has_key? control_id
  #    current_time - @control_id_down_time[control_id]
  #  else
  #    1.0/0.0
  #  end
  #end
  #
  #def time_since_control_up control_id, current_time
  #  if @control_id_up_time.has_key? control_id
  #    current_time - @control_id_up_time[control_id]
  #  else
  #    1.0/0.0
  #  end
  #end
  #
  #private
  #
  #def control_down control_id, time
  #  @controls_down << control_id
  #  @buffer << [control_id, time]
  #  @buffer = @buffer[-10..-1] if @buffer.length > 10
  #  @control_id_down_time[control_id] = time
  #  @on_control_down.call control_id, time
  #end
  #
  #def control_up control_id
  #  @controls_down.delete control_id
  #  @control_id_up_time[control_id] = time
  #  @on_control_up.call control_id, time
  #end
end