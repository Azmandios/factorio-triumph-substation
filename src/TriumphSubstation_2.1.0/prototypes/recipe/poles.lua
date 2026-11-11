---------------------------------------------------------------------------
-- Factorio 2.x recipe format: ingredients/results use
-- {type = "item", name = "...", amount = ...}.
---------------------------------------------------------------------------

local function make_substation_recipe(name, energy, ingredients)
  local recipe = util.table.deepcopy(data.raw.recipe["substation"])

  recipe.name = name
  recipe.enabled = false
  recipe.energy_required = energy
  recipe.ingredients = ingredients
  recipe.results = {{type = "item", name = name, amount = 1}}
  recipe.result = nil
  recipe.result_count = nil

  data:extend({recipe})
end

make_substation_recipe("substation-2", 15, {
  {type = "item", name = "substation", amount = 1},
  {type = "item", name = "big-electric-pole", amount = 1},
  {type = "item", name = "advanced-circuit", amount = 10},
  {type = "item", name = "steel-plate", amount = 40},
  {type = "item", name = "copper-plate", amount = 20}
})

make_substation_recipe("substation-3", 30, {
  {type = "item", name = "substation-2", amount = 1},
  {type = "item", name = "big-electric-pole", amount = 1},
  {type = "item", name = "processing-unit", amount = 20},
  {type = "item", name = "refined-concrete", amount = 100},
  {type = "item", name = "copper-plate", amount = 50},
  {type = "item", name = "uranium-fuel-cell", amount = 5}
})

make_substation_recipe("substation-4", 60, {
  {type = "item", name = "substation-3", amount = 1},
  {type = "item", name = "big-electric-pole", amount = 1},
  {type = "item", name = "processing-unit", amount = 40},
  {type = "item", name = "refined-concrete", amount = 200},
  {type = "item", name = "copper-plate", amount = 100},
  {type = "item", name = "uranium-fuel-cell", amount = 10}
})
