class Components::Sprite < Component
  attr_accessor \
    :sprite_resource_path,
    :start_time,
    :current_time,
    :duration,
    :fps,
    :mode,
    :index
    
    
  def initialize options
    @sprite_resource_path = options["sprite_resource_path"]
    @start_time           = options["start_time"]
    @current_time         = options["current_time"] || @start_time
    @duration             = options["duration"]
    @fps                  = options["fps"]
    @mode                 = options["mode"] || "loop"
    @index                = options["index"].to_i
  end
end