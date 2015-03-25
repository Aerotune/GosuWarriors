class Components::Drawable < Component
  attr_accessor :draw_component, :x, :y, :z_order, :factor_x
  
  def initialize options
    @draw_component = options['draw_component']
    @x              = options['x']
    @y              = options['y']
    @z_order        = options['z_order']
    @factor_x       = options['factor_x']
  end
end