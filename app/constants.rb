MAIN_PATH = '.'
APP_PATH  = File.join(MAIN_PATH, 'app')

Dir[File.join(APP_PATH, *%w[constants *.rb])].each { |file| require file }
