data:extend({
		{
			type = "technology",
			name = "electric-substation-3",
			-- The name ends with a tier number, so Factorio would build
			-- "<base name> 3" from the "electric-substation" locale key.
			-- Set the explicit keys to keep distinct names for every tier.
			localised_name = {"technology-name.electric-substation-3"},
			localised_description = {"technology-description.electric-substation-3"},
			icon = "__TriumphSubstation2__/graphics/tech/electric-energy-distribution.png",
			icon_size = 128,
			unit = {
				count = 150,
				ingredients = {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1},
				},
				time = 45
			},
			effects = {
				{
					type = "unlock-recipe",
					recipe = "substation-2"
				},

			},
			prerequisites = {
				"electric-energy-distribution-2",
				"advanced-circuit",
			},
			order = "a-j-z"
		}
	})
	
data:extend({
		{
			type = "technology",
			name = "electric-substation-4",
			-- The name ends with a tier number, so Factorio would build
			-- "<base name> 4" from the "electric-substation" locale key.
			-- Set the explicit keys to keep distinct names for every tier.
			localised_name = {"technology-name.electric-substation-4"},
			localised_description = {"technology-description.electric-substation-4"},
			icon = "__TriumphSubstation2__/graphics/tech/electric-energy-distribution.png",
			icon_size = 128,
			unit = {
				count = 300,
				ingredients = {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1},
					{"production-science-pack", 1},
					{"utility-science-pack", 1}
				},
				time = 200
			},
			effects = {
				{
					type = "unlock-recipe",
					recipe = "substation-3"
				},				
			},
			prerequisites = {
				"electric-substation-3",
				"nuclear-power",
			},		
			
			order = "a-j-z"
		}
	})
data:extend({
		{
			type = "technology",
			name = "electric-substation-5",
			-- The name ends with a tier number, so Factorio would build
			-- "<base name> 5" from the "electric-substation" locale key.
			-- Set the explicit keys to keep distinct names for every tier.
			localised_name = {"technology-name.electric-substation-5"},
			localised_description = {"technology-description.electric-substation-5"},
			icon = "__TriumphSubstation2__/graphics/tech/electric-energy-distribution.png",
			icon_size = 128,
			unit = {
				count = 600,
				ingredients = {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1},
					{"production-science-pack", 1},
					{"utility-science-pack", 1}
				},
				time = 400
			},
			effects = {
				{
					type = "unlock-recipe",
					recipe = "substation-4"
				},				
			},
			prerequisites = {
				"electric-substation-4",
				"nuclear-power",
			},		
			
			order = "a-j-z"
		}
	})