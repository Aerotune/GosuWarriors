module SpriteResourceFileTool
  def self.to_a file_path, relative_path
    extname = File.extname(file_path)
    sprite_resource_path_name = Pathname.new(file_path).relative_path_from(relative_path)
    sprite_resource_path      = sprite_resource_path_name.to_s.split(File::SEPARATOR)
    sprite_resource_path[-1]  = File.basename(sprite_resource_path[-1], extname)
    sprite_resource_path
  end
end