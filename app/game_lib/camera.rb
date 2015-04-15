class Camera
  attr_reader :vanishing_point_x, :vanishing_point_y
  attr_accessor :look_x, :look_y, :zoom, :left_limit, :right_limit, :up_limit, :down_limit
  
  def initialize look_x, look_y, zoom
    @look_x = look_x
    @look_y = look_y
    @zoom   = zoom
    @width  = $window.width.to_i
    @height = $window.height.to_i
    @vanishing_point_x = @width/2
    @vanishing_point_y = @height/2
  end
  
  
  def update
    self.min_x = @left_limit  if min_x < @left_limit  if @left_limit
    self.max_x = @right_limit if max_x > @right_limit if @right_limit
    self.min_y = @up_limit    if min_y < @up_limit    if @up_limit
    self.max_y = @down_limit  if max_y > @down_limit  if @down_limit
  end
  
  def view &block
    raise "Can't nest camera view within itself" if @camera_view
    @camera_view = true
    
    $window.scale @zoom, @zoom, @vanishing_point_x, @vanishing_point_y do
      $window.translate -min_x, -min_y do
        block.call
      end
    end
    
    @camera_view = false
  end
  
  def x_for_screen_x screen_x
    ((screen_x - @vanishing_point_x) / @zoom).to_i + @look_x
  end
  
  def y_for_screen_y screen_y
    ((screen_y - @vanishing_point_y) / @zoom).to_i + @look_y
  end
  
  def screen_x x
    ((x - min_x - @vanishing_point_x) * @zoom).to_i + @vanishing_point_x
  end
  
  def screen_y y
    ((y - min_y - @vanishing_point_y) * @zoom).to_i + @vanishing_point_y
  end
  
  def min_x
    @look_x - @vanishing_point_x
  end
  
  def min_x= min_x
    @look_x = min_x + @vanishing_point_x
  end
  
  def max_x
    @look_x + @vanishing_point_x
  end
  
  def max_x= max_x
    @look_x = max_x - @vanishing_point_x
  end
  
  def min_y
    @look_y - @vanishing_point_y
  end
  
  def min_y= min_y
    @look_y = min_y + @vanishing_point_y
  end
  
  def max_y
    @look_y + @vanishing_point_y
  end
  
  def max_y= max_y
    @look_y = max_y - @vanishing_point_y
  end
end