require_relative 'identifier'

class EntityManager
  attr_reader :store
  
  def initialize
    ## Structure:
    ## @store = { ComponentClass => {entity => [component_instance]}}
    @store = Hash.new do |store, component_class|
      store[component_class] = Hash.new do |component_store, entity|
        component_store[entity] = []
      end
    end
    
    @components = {}
  end
  
  def create_entity
    Identifier.create_id
  end
  
  def get_component_by_component_id component_id
    @components[component_id]
  end
  
  def get_component entity, component_class
    @store[component_class][entity].first
  end
  
  def get_components entity, component_class
    @store[component_class][entity]
  end
  
  def get_all_components component_class
    @store[component_class].values.flatten!
  end
  
  def add_component entity, component
    @components[component.id] = component
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
      component_class = component_or_class
      @store[component_class].delete entity
    end    
  end
  
  def each_entity_with_components component_class
    @store[component_class].each do |entity, components|
      yield entity, components unless components.empty?
    end
  end
  
  def each_entity_with_component component_class
    @store[component_class].each do |entity, components|
      yield entity, components.first unless components.empty?
    end
  end
  
  #def intersection class1, class2    
  #  @store[class1].each do |entity, class1_component|
  #    class2_component = @store[class2][entity]
  #    yield entity, class1_component, class2_component if class2_component
  #  end
  #end
end