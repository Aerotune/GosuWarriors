Z = 0

module ZOrder
  %w[
    CHARACTER
    TARGET
    STAGE
  ]
  .to_enum.reverse_each.each_with_index do |const_name, index|
    const_set(const_name, index)
  end
end