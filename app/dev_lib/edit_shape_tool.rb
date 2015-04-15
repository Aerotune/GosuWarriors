class EditShapeTool
  attr_accessor :shape
  
  def shape=shape
    MouseTrap.release self
    @shape = shape
  end
  
  def initialize shape, level_editor
    @shape = shape
    @level_editor = level_editor
  end
  
  def update
    return unless @shape
    
    if mouse_over_point_index || @drag_point_index
      NeutralCursor.set_state :grab
    else
      NeutralCursor.set_state :normal
    end
    
    if @drag_point_index
      drag_point    = outline[@drag_point_index]
      drag_point[0] = @level_editor.mouse_x
      drag_point[1] = @level_editor.mouse_y
    end
  end
  
  def mouse_over_point_index
    outline.find_index { |point| 4 > IntMath.distance(@level_editor.mouse_x, @level_editor.mouse_y, *point) }
  end
  
  def key_down key
    return unless @shape
    
    case key
    when 'backspace', 'delete'
      index = outline.index outline.min_by { |point| IntMath.distance(*point, @level_editor.mouse_x, @level_editor.mouse_y) }
      outline.delete_at index if index
      update_convexes!
    when 'mouse_left'
      if MouseTrap.capture self
        new_point = [@level_editor.mouse_x, @level_editor.mouse_y]
        
        if drag_point_index = mouse_over_point_index
          @drag_point_index = drag_point_index
        else
          index, _axis_distance = *ShapeHelper::Point.point_index_and_distance_along_line(outline, @level_editor.mouse_x, @level_editor.mouse_y)
          if index
            index = (index + 1) % outline.length
            outline.insert index, new_point
            @drag_point_index = index
          else
            outline << new_point
            @drag_point_index = index
          end       
        end
      end
    end
  end
  
  def outline
    @shape['outline']
  end
  
  def release!
    key_up 'mouse_left'
  end
  
  def update_convexes!
    ConvexDecomposer.set_polygon outline
    convexes = ConvexDecomposer.decompose
    @shape['convexes'].clear
    if ConvexDecomposer.is_simple?
      @shape['convexes'].push *convexes 
    else
      puts "INVALID LEVEL #{Time.now}"
    end
  end
  
  def key_up key
    case key
    when 'mouse_left'
      if MouseTrap.release self
        if @drag_point_index
          @drag_point_index = nil
        end
        outline.reverse! unless ShapeHelper.cw? outline
        update_convexes!
      end
    end
  end
end