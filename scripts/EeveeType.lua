-- Config setup
config:name("EeveelutionTaur")
local setType = config:load("EeveeType") or "eevee"

-- Variable setup
local curType = setType

-- Eevee type
function pings.setEeveeType(type, bool)
	
	setType = bool and type or "eevee"
	config:save("EeveeType", setType)
	
end

-- Host only instructions, return type data
if not host:isHost() then return typeData end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local s, c = pcall(require, "scripts.ColorProperties")

-- Table setup
local t = {}

-- Actions
t.vaporeonAct = action_wheel:newAction()
	:item(itemCheck("cobblemon:water_stone", "blue_glazed_terracotta"))
	:onToggle(function(bool) pings.setEeveeType("vaporeon", bool) end)

t.jolteonAct = action_wheel:newAction()
	:item(itemCheck("cobblemon:thunder_stone", "yellow_glazed_terracotta"))
	:onToggle(function(bool) pings.setEeveeType("jolteon", bool) end)

t.flareonAct = action_wheel:newAction()
	:item(itemCheck("cobblemon:fire_stone", "red_glazed_terracotta"))
	:onToggle(function(bool) pings.setEeveeType("flareon", bool) end)

t.espeonAct = action_wheel:newAction()
	:item(itemCheck("cobblemon:psychic_gem", "magenta_glazed_terracotta"))
	:onToggle(function(bool) pings.setEeveeType("espeon", bool) end)

t.umbreonAct = action_wheel:newAction()
	:item(itemCheck("cobblemon:dark_gem", "black_glazed_terracotta"))
	:onToggle(function(bool) pings.setEeveeType("umbreon", bool) end)

t.leafeonAct = action_wheel:newAction()
	:item(itemCheck("cobblemon:leaf_stone", "lime_glazed_terracotta"))
	:onToggle(function(bool) pings.setEeveeType("leafeon", bool) end)

t.glaceonAct = action_wheel:newAction()
	:item(itemCheck("cobblemon:ice_stone", "blue_glazed_terracotta"))
	:onToggle(function(bool) pings.setEeveeType("glaceon", bool) end)

t.sylveonAct = action_wheel:newAction()
	:item(itemCheck("cobblemon:fairy_gem", "pink_glazed_terracotta"))
	:onToggle(function(bool) pings.setEeveeType("sylveon", bool) end)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		
		if t.vaporeonAct then
			t.vaporeonAct
				:title(toJson(
					{
						"",
						{text = "Vaporeon\n\n", bold = true, color = c.primary},
						{text = "Right click on any option to go back.", color = c.secondary}
					}
				))
				:toggled(setType == "vaporeon")
		end
		
		if t.jolteonAct then
			t.jolteonAct
				:title(toJson(
					{
						"",
						{text = "Jolteon\n\n", bold = true, color = c.primary},
						{text = "Right click on any option to go back.", color = c.secondary}
					}
				))
				:toggled(setType == "jolteon")
		end
		
		if t.flareonAct then
			t.flareonAct
				:title(toJson(
					{
						"",
						{text = "Flareon\n\n", bold = true, color = c.primary},
						{text = "Right click on any option to go back.", color = c.secondary}
					}
				))
				:toggled(setType == "flareon")
		end
		
		if t.espeonAct then
			t.espeonAct
				:title(toJson(
					{
						"",
						{text = "Espeon\n\n", bold = true, color = c.primary},
						{text = "Right click on any option to go back.", color = c.secondary}
					}
				))
				:toggled(setType == "espeon")
		end
		
		if t.umbreonAct then
			t.umbreonAct
				:title(toJson(
					{
						"",
						{text = "Umbreon\n\n", bold = true, color = c.primary},
						{text = "Right click on any option to go back.", color = c.secondary}
					}
				))
				:toggled(setType == "umbreon")
		end
		
		if t.leafeonAct then
			t.leafeonAct
				:title(toJson(
					{
						"",
						{text = "Leafeon\n\n", bold = true, color = c.primary},
						{text = "Right click on any option to go back.", color = c.secondary}
					}
				))
				:toggled(setType == "leafeon")
		end
		
		if t.glaceonAct then
			t.glaceonAct
				:title(toJson(
					{
						"",
						{text = "Glaceon\n\n", bold = true, color = c.primary},
						{text = "Right click on any option to go back.", color = c.secondary}
					}
				))
				:toggled(setType == "glaceon")
		end
		
		if t.sylveonAct then
			t.sylveonAct
				:title(toJson(
					{
						"",
						{text = "Sylveon\n\n", bold = true, color = c.primary},
						{text = "Right click on any option to go back.", color = c.secondary}
					}
				))
				:toggled(setType == "sylveon")
		end
		
		for _, page in pairs(t) do
			page:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end

-- Return type data and actions
return typeData, t