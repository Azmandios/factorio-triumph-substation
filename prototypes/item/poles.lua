data.raw.item["substation"].order = "a[energy]-d[substation-1]"
data.raw.item["substation"].subgroup = "advanced-electric-poles"

local function make_substation_item(name, order, icon)
  local item = util.table.deepcopy(data.raw.item["substation"])

  item.name = name
  item.icon = icon
  item.icon_size = 32
  item.order = order
  item.subgroup = "advanced-electric-poles"
  item.place_result = name

  data:extend({item})
end

make_substation_item(
  "substation-2",
  "a[energy]-d[substation-2]",
  "__TriumphSubstation2__/graphics/icons/substation-2_icon.png"
)

make_substation_item(
  "substation-3",
  "a[energy]-e[substation-3]",
  "__TriumphSubstation2__/graphics/icons/substation-3_icon.png"
)

make_substation_item(
  "substation-4",
  "a[energy]-e[substation-4]",
  "__TriumphSubstation2__/graphics/icons/substation-4_icon.png"
)
