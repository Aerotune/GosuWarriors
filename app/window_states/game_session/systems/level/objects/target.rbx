if hit_by_entity = shape_hits on_any: ['special'], by_any: ['deals_damage']
  #play hit sound
end

if hit_by_entity = shape_hits on_any: ['takes_damage'], by_all: ['deals_damage', 'stuns']
  #play shatter sound
  #shatter
end