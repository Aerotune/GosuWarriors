module Resources::Stages
  @stages = {}
  
  class << self
    attr_reader :loaded
    
    def require!
      load! unless @loaded
    end
    
    def load!
      @loaded = false
      
      Dir[File.join(STAGE_RESOURCE_PATH, '*.msgpack')].each do |msgpack_path|
        stage_id = File.basename(msgpack_path, '.msgpack')
        msgpack  = MessagePack.unpack_file(msgpack_path)
        @stages[stage_id] = {
          'id' => stage_id,
          'shapes' => msgpack['shapes'] || [],
          'spawn' => msgpack['spawn']
        }
      end
      
      @loaded = true
    end
    
    def [] stage_id
      @stages[stage_id] ||= {
        'id' => stage_id,
        'shapes' => []
      }
    end
    
    def save_all!
      @stages.each do |stage_id, stage|
        msgpack = stage.to_msgpack
        msgpack_path = File.join(STAGE_RESOURCE_PATH, stage_id) + '.msgpack'
        File.open msgpack_path, 'wb' do |f|
          f << msgpack
        end
      end
    end
  end
end