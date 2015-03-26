module MouseTrap
  class << self
    def capture object
      if @captured == object
        true
      else
        if @captured
          false
        else
          @captured = object
          true
        end
      end
    end
    
    def captured? object
      @captured == object
    end
  
    def release object
      if @captured == object
        @captured = nil
        true
      else
        false
      end
    end
    
    def release!
      @captured = nil
      true
    end
  end
end