---------------------------------------------------------------------------
-- Factorio 2.x: sprite pictures must be wrapped in a "layers" table.
-- Everything else is inherited from the vanilla substation.
---------------------------------------------------------------------------

local function make_substation(name, wire_distance, supply_distance, max_health, icon, picture)
  local pole = util.table.deepcopy(data.raw["electric-pole"]["substation"])

  pole.name = name
  pole.maximum_wire_distance = wire_distance
  pole.supply_area_distance = supply_distance
  pole.max_health = max_health

  pole.icon = icon
  pole.icon_size = 32

  pole.pictures =
  {
    layers =
    {
      {
        filename = picture,
        priority = "high",
        width = 132,
        height = 158,
        direction_count = 4,
        shift = {0.75, -0.70}
      }
    }
  }

  pole.minable.result = name
  pole.fast_replaceable_group = "electric-pole"

  data:extend({pole})
end

data.raw["electric-pole"]["substation"].fast_replaceable_group = "electric-pole"

make_substation(
  "substation-2",
  32,
  16,
  200,
  "__TriumphSubstation__/graphics/icons/substation-2_icon.png",
  "__TriumphSubstation__/graphics/entity/substation-2/substation-2.png"
)

make_substation(
  "substation-3",
  48,
  24,
  100,
  "__TriumphSubstation__/graphics/icons/substation-3_icon.png",
  "__TriumphSubstation__/graphics/entity/substation-3/substation-3.png"
)

make_substation(
  "substation-4",
  64,
  32,
  100,
  "__TriumphSubstation__/graphics/icons/substation-4_icon.png",
  "__TriumphSubstation__/graphics/entity/substation-4/substation-4.png"
)
