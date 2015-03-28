class EntityManager
  attr_reader :store
  
  def initialize components_module
    ## Structure:
    ## @store = { ComponentClass => {entity => [component_instance]}}
    @components_module = components_module
    @store = Hash.new do |store, component_class|
      store[component_class] = Hash.new do |component_store, entity|
        component_store[entity] = []
      end
    end    
  end
  
  def create_entity
    Identifier.create_id
  end
  
  def get_component entity, component_class_or_name
    @store[component_class(component_class_or_name)][entity].first
  end
  
  def get_components entity, component_class_or_name
    @store[component_class(component_class_or_name)][entity]
  end
  
  def get_all_components component_class_or_name
    @store[component_class(component_class_or_name)].values.flatten!
  end
  
  def add_component entity, component
    components = @store[component.class][entity]
    components << component unless components.include? component
  end
  
  def has_components? entity, *components
    components.each do |component|
      return false unless get_component entity, component
    end
    
    return true
  end
  
  def remove_component entity, component_or_class
    if component_or_class.kind_of? Component
      component_class = component_or_class.class
      @store[component_class][entity].delete component_or_class
    else
      @store[component_class(component_or_class)].delete entity
    end    
  end
  
  def each_entity_with_components component_class_or_name
    @store[component_class(component_class_or_name)].each do |entity, components|
      yield entity, components unless components.empty?
    end
  end
  
  def each_entity_with_component component_class_or_name
    @store[component_class(component_class_or_name)].each do |entity, components|
      yield entity, components.first unless components.empty?
    end
  end
  
  private
  
  def component_class component_class_or_name
    case component_class_or_name
    when Symbol, String
      @components_module.const_get component_class_or_name
    else
      component_class_or_name
    end
  end
  
  #def intersection class1, class2    
  #  @store[class1].each do |entity, class1_component|
  #    class2_component = @store[class2][entity]
  #    yield entity, class1_component, class2_component if class2_component
  #  end
  #end
end