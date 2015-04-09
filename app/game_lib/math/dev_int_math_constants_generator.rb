if __FILE__ == $0
  # Table Generator
  @sin_table = []
  @cos_table = []
  @atan_table = []
  one_circle_point_12 = 1 << 12
  one_point_16 = 1 << 16

  one_circle_point_12.times do |rotation|
    radians = (rotation.to_f * (Math::PI * 2) / one_circle_point_12.to_f)
    point_16 = (Math.sin(radians) * one_point_16.to_f).round
    @sin_table[rotation] = point_16
  end

  one_circle_point_12.times do |rotation|
    radians = (rotation.to_f * (Math::PI * 2) / one_circle_point_12.to_f)
    point_16 = (Math.cos(radians) * one_point_16.to_f).round
    @cos_table[rotation] = point_16
  end
  
  one_circle_point_12.times do |i|
    #(x range is 0.0..64.0)
    x = i.to_f / 64.0 # like i >> 6
    point_12 = (Math.atan(x) / (Math::PI) * one_circle_point_12.to_f/2.0).round
    @atan_table[i] = point_12
  end
    
  File.open(File.join(File.dirname(__FILE__), 'int_math_constants.rb'), 'w+') do |file|
    file << <<-MODULE
module IntMath
  SIN_TABLE_POINT_16  = #{@sin_table.inspect}
  COS_TABLE_POINT_16  = #{@cos_table.inspect}
  ATAN_TABLE_POINT_12 = #{@atan_table.inspect}
  SIN_TABLE_POINT_16.freeze
  COS_TABLE_POINT_16.freeze
  ATAN_TABLE_POINT_12.freeze
end
MODULE
  end
end