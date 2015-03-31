module Resources::Sounds
  class << self
    def require!
      load! unless @sounds
    end
    
    def load!
      @sounds = {
        'target_break' => Gosu::Sample.new($window, File.join(SFX_PATH, 'level', 'generic', 'target_break.ogg'))
      }
    end
  
    def [] sound_id
      @sounds[sound_id]
    end
  end
end