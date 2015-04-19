if __FILE__ == $0
  # Table Generator
  sin_table_point_10 = []
  cos_table_point_10 = []
  atan_table_point_10 = []
  ln_cosh_table_point_10 = []
  tau = Math::PI * 2
  tau_point_10 = ((Math::PI * 2) * (1<<10)).round
  pi_point_10 = tau_point_10 / 2

  #tau_point_10.times do |i|
  #  sin_table_point_10[i]  = (Math.sin(i.to_f / (1<<10).to_f) * (1<<10)).round
  #  cos_table_point_10[i]  = (Math.cos(i.to_f / (1<<10).to_f) * (1<<10)).round
  #  atan_table_point_10[i] = (Math.atan(i.to_f / (1<<5).to_f) * (1<<10)).round
  #end
  
  256.times do |i|
    sin_table_point_10[i]  = (Math.sin( i / 256.0 * tau) * (1<<10)).round
    cos_table_point_10[i]  = (Math.cos( i / 256.0 * tau) * (1<<10)).round
    atan_table_point_10[i] = (Math.atan(i / 8.0   * tau) * (1<<10)).round
    ln_cosh_table_point_10[i] = (Math.log(Math.cosh(i / 64.0)) * (1<<10)).round
  end

  atan_table_point_10.delete(atan_table_point_10.last)
    
  File.open(File.join(File.dirname(__FILE__), 'int_math_constants.rb'), 'w+') do |file|
    file << <<-MODULE
module IntMath
  SIN_TABLE_POINT_10  = #{sin_table_point_10.inspect}.freeze
  COS_TABLE_POINT_10  = #{cos_table_point_10.inspect}.freeze
  ATAN_TABLE_POINT_10 = #{atan_table_point_10.inspect}.freeze
  LN_COSH_TABLE_POINT_10 = #{ln_cosh_table_point_10.inspect}.freeze
end
MODULE
  end
end