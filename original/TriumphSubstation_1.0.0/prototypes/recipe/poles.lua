

--substations--
local advancedsubstation = util.table.deepcopy(data.raw.recipe["substation"])
advancedsubstation.name = "substation-2"
advancedsubstation.enabled = "false"
advancedsubstation.energy_required = 15
advancedsubstation.ingredients =
{
  {"substation", 1},
  {"big-electric-pole",1},
  {"advanced-circuit", 10},
  {"steel-plate", 40},
  {"copper-plate", 20},
}
advancedsubstation.result = "substation-2"
data:extend({advancedsubstation})

local atomicsubstation = util.table.deepcopy(data.raw.recipe["substation"])
atomicsubstation.name = "substation-3"
atomicsubstation.enabled = "false"
atomicsubstation.energy_required = 30
atomicsubstation.ingredients =
{
  {"substation-2", 1},
  {"big-electric-pole",1},
  {"processing-unit", 20},
  {"refined-concrete", 100},
  {"copper-plate", 50},
  {"uranium-fuel-cell",5},
}
atomicsubstation.result = "substation-3"
data:extend({atomicsubstation})

local atomicsubstation2 = util.table.deepcopy(data.raw.recipe["substation"])
atomicsubstation2.name = "substation-4"
atomicsubstation2.enabled = "false"
atomicsubstation2.energy_required = 60
atomicsubstation2.ingredients =
{
  {"substation-3", 1},
  {"big-electric-pole",1},
  {"processing-unit", 40},
  {"refined-concrete", 200},
  {"copper-plate", 100},
  {"uranium-fuel-cell",10},
}
atomicsubstation2.result = "substation-4"
data:extend({atomicsubstation2})