class Range
  # Compatibility with ruby 1.9.3
  unless method_defined? :size
    def size
      to_a.size
    end
  end
end