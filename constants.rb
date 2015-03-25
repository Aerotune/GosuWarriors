MAIN_PATH = '.'

Dir[File.join(MAIN_PATH, *%w[constants *.rb])].each { |file| require file }
