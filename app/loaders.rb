module Loaders
  Dir[File.join(LOADERS_PATH, '*.rb')].each { |file| require file }
end