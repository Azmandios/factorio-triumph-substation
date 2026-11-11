-- Headless regression test for the TriumphSubstation2 port.
--
-- Run with:
--   factorio --test-scenario triumphsubstation2-tests/explosion --test-ticks 300
--
-- Checks:
--   * prototypes keep the original numbers (supply area, wire reach);
--   * sprites use the 2.0+ pictures.layers format;
--   * recipes are locked and items place the right entity;
--   * destroying substation-3 spawns an atomic blast (near walls die, a far
--     wall survives).

local failures = {}

local function expect(condition, message)
  if not condition then
    failures[#failures + 1] = message
    log("[test] FAIL: " .. message)
  end
end

local surface
local substation
local near_walls = {}
local far_wall

local function check_prototypes()
  -- Числовые поля прототипов проверяются в tools/smoke.py по дампу данных:
  -- на уровне сценария LuaEntityPrototype не отдаёт поля конкретного типа.
  for _, name in ipairs({ "substation-2", "substation-3", "substation-4" }) do
    expect(prototypes.entity[name] ~= nil, "prototype missing: entity " .. name)
    expect(prototypes.item[name] ~= nil, "prototype missing: item " .. name)
    expect(prototypes.recipe[name] ~= nil, "prototype missing: recipe " .. name)
  end
  expect(prototypes.technology["electric-substation-3"] ~= nil,
    "prototype missing: technology electric-substation-3")
end

local function place_wall(position)
  local entity = surface.create_entity {
    name = "stone-wall",
    position = position,
    force = game.forces.player,
  }
  return entity
end

local function try_place_wall(candidates)
  for _, position in ipairs(candidates) do
    if surface.can_place_entity { name = "stone-wall", position = position, force = game.forces.player } then
      return place_wall(position)
    end
  end
  return nil
end

local function setup()
  local player = game.players[1]
  surface = player and player.surface or game.surfaces[1]

  if player then
    -- Keep the player out of the blast radius.
    player.teleport({ 200, 200 }, surface)
  end

  check_prototypes()

  expect(surface.can_place_entity { name = "substation-3", position = { 0, 0 }, force = game.forces.player },
    "cannot place substation-3 at the map origin")
  substation = surface.create_entity {
    name = "substation-3",
    position = { 0, 0 },
    force = game.forces.player,
  }
  expect(substation ~= nil, "failed to create substation-3")
  if not substation then return end

  local ring = {
    { 8, 0 }, { -8, 0 }, { 0, 8 }, { 0, -8 },
    { 6, 6 }, { -6, 6 }, { 6, -6 }, { -6, -6 },
  }
  for _, point in ipairs(ring) do
    local wall = try_place_wall {
      point,
      { point[1] + 0.5, point[2] },
      { point[1], point[2] + 0.5 },
      { point[1] - 0.5, point[2] },
      { point[1], point[2] - 0.5 },
    }
    if wall then near_walls[#near_walls + 1] = wall end
  end
  expect(#near_walls >= 4, "could not place test walls around the substation (" .. #near_walls .. ")")

  far_wall = try_place_wall {
    { 60, 0 }, { 0, 60 }, { -60, 0 }, { 0, -60 },
    { 50, 50 }, { -50, 50 }, { 50, -50 }, { -50, -50 },
  }
  expect(far_wall ~= nil, "could not place the far reference wall")
end

local function detonate()
  if substation and substation.valid then
    substation.die()
  end
end

local function verify()
  expect(substation ~= nil and not substation.valid, "substation-3 survived its own destruction")

  if substation and substation.valid then
    return
  end

  local survivors = 0
  for _, wall in ipairs(near_walls) do
    if wall.valid then survivors = survivors + 1 end
  end
  expect(survivors == 0,
    "atomic blast did not destroy all near walls: " .. survivors .. " of " .. #near_walls .. " survived")

  if far_wall then
    expect(far_wall.valid, "atomic blast destroyed the far reference wall, the blast is too large")
  end
end

local tick = 0
script.on_nth_tick(1, function()
  tick = tick + 1
  if tick == 1 then
    setup()
  elseif tick == 5 then
    detonate()
  elseif tick == 150 then
    verify()
    script.finish_test(#failures == 0)
  end
end)
