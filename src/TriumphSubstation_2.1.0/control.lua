--control.lua

script.on_event(defines.events.on_entity_died, function(event)
  local entity = event.entity
  if entity and entity.valid and entity.name == "substation-3" then
    -- Factorio 2.x removed the "speed" parameter from create_entity().
    -- A projectile spawned exactly on its target never detonates, so spawn
    -- it slightly away from the substation and give it a speed manually.
    local position = entity.position
    local rocket = entity.surface.create_entity{
      name = "atomic-rocket",
      position = {position.x, position.y - 0.5},
      target = position,
      force = entity.force
    }

    if rocket then
      rocket.speed = 0.3
    end
  end
end)
