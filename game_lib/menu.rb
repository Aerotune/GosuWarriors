class Menu
  require_relative 'menu_item'
  
  def initialize options={text_size: 24}
    @text_size = options[:text_size]
    require_fonts!
    @menu_items = []
  end
  
  def key_up key
    @menu_items.each do |menu_item|
      menu_item.key_up key
    end
  end
  
  def update
    @menu_items.each &:update
  end
  
  def draw
    @menu_items.each_with_index do |menu_item|
      menu_item.draw
    end
  end
  
  def add_menu_item text, &on_click
    @menu_item_index ||= 0
    menu_item = Menu::Item.new(text, @text_size, $window.width/2, 50+@menu_item_index*(@text_size+2), Z, &on_click)
    @menu_items << menu_item
    @menu_item_index += 1
  end
  
  def require_fonts!
    require File.join(GAME_LIB_PATH, 'resources.rb')
    Resources::Fonts.require!
  end
end