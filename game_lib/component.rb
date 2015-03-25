require_relative 'identifier'

class Component
  def id
    @id ||= Identifier.create_id
  end
end