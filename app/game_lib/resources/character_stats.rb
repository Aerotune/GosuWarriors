module Resources::CharacterStats
  @stats = {}
  @default_stats = {
    'run_speed' => 12_500,
    'run_transition_time' => 14,
    'stop_transition_time' => 16
  }
  
  class << self
    attr_reader :stats, :loaded
    
    def [] character_name
      @stats[character_name]
    end
    
    def require!
      load! unless @loaded
    end
    
    def load!
      @loaded = false
      
      Dir[File.join(RESOURCES_PATH, 'stats', 'characters', '*.msgpack')].each do |msgpack_path|
        character_name = File.basename(msgpack_path, '.msgpack')
      
        character_stats = MessagePack.unpack_file(msgpack_path)
        character_stats ||= {}
        @default_stats.each do |key, value|
          character_stats[key] ||= Marshal.load(Marshal.dump(value))
        end
        
        @stats[character_name] = character_stats
      end
      
      @loaded = true
    end
    
    def save_all!
      @stats.each do |character_name, stats|
        stat_path = File.join(RESOURCES_PATH, 'stats', 'characters', "#{character_name}.msgpack")
        File.open(stat_path, 'wb') do |f|
          f << stats.to_msgpack
        end
      end
    end
  end
end