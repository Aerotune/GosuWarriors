require 'securerandom'

module Identifier  
  def self.create_id
    SecureRandom.random_number 18446744073709551616 #2**64
  end
end