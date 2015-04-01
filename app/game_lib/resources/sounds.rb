module Resources::Sounds
  class << self
    def require!
      load! unless @sounds
    end
    
    def load!
      @sounds = {
        'target_break' => Gosu::Sample.new($window, File.join(SFX_PATH, 'level', 'generic', 'target_break.ogg')),
        'success' => Gosu::Sample.new($window, File.join(SFX_PATH, 'level', 'generic', 'success.ogg'))
      }
      
      @samples = Hash.new { |h, k| h[k] = [] }
      @prev_sample = {}
      Dir[File.join(SFX_PATH, '**', '*.ogg')].each do |full_sample_path|
        sample_pattern = Pathname.new(full_sample_path).relative_path_from(SFX_PATH)
        folder_pattern = File.join(File.dirname(sample_pattern),'*.ogg')
        
        sample = Gosu::Sample.new($window, full_sample_path)
        
        @samples[sample_pattern.to_s] << sample
        @samples[folder_pattern.to_s] << sample        
      end
      @sfx = {}
    end
  
    def [] sound_id
      @sounds[sound_id]
    end
    
    def sfx pattern
      samples = @samples[pattern]
      index = rand(samples.length)
      @prev_sample[pattern] ||= index
      if @prev_sample[pattern] == index
        index -= 1
      end
      @prev_sample[pattern] = index
      samples[index]
    end
  end
end