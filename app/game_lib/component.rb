class Component
  def initialize component_or_hash
    mirror component_or_hash
  end
  
  def to_hash
    hash = {}
    
    self.class.attributes.each do |attribute|
      hash[attribute.to_s] = Marshal.load(Marshal.dump(instance_variable_get("@#{attribute}")))
    end
    
    hash
  end
  
  def mirror component_or_hash
    component_or_hash.to_hash.each do |key, value|
      instance_variable_set "@#{key}", value if self.class.attributes.include? key
    end
  end
  
  def [] attribute
    if self.class.attributes.include? attribute
      instance_variable_get "@#{attribute}"
    else
      raise "#{self.class} doesn't have attribute: #{attribute.inspect}"
    end
  end
  
  def []= attribute, value
    if self.class.attributes.include? attribute
      instance_variable_set "@#{attribute}", value
    else
      raise "#{self.class} doesn't have attribute: #{attribute.inspect}"
    end
  end
  
  class << self
    attr_reader :attributes
    
    def has_attributes has_attributes
      @attributes ||= []
      has_attributes.each do |has_attribute|
        @attributes << has_attribute.to_s
        attr_accessor  has_attribute
      end
      @attributes.uniq!
    end
  end
end