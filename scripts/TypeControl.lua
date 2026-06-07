  -------------------
 --- Initial Setup ---
  -------------------

-- Required scripts
local parts = require("lib.PartsAPI")
local sync  = require("lib.LetThatSyncFig")
local itemCheck = require("lib.ItemCheck")

--[[
	
	Notes:
	Below is a list of all the eevee types this avatar will attempt to use, by name.
	If you do not wish to include a specific type, you can delete it from this table, or delete it's primary texture.
	This script will find accessories under the same name, and toggle their visibility if the curType matches.
	Be sure to delete any accessories from the model that you no longer need! You don't need to, but it helps save space!
	
	If you wish to add a type, all you need to do is add it to the table, and add its primary texture to the model under the same name, lowercase.
	To add accessories to a specific type, add its name (uppercase) to the group name.
	
--]]
-- Init types
local types = {
	"eevee",
	"vaporeon",
	"jolteon",
	"flareon",
	"espeon",
	"umbreon",
	"leafeon",
	"glaceon",
	"sylveon"
}

-- Deletes type if texture cannot be found
for i = #types, 1, -1 do
	
	if not (textures["textures."..types[i]] or textures["EeveeTaur."..types[i]]) then
		
		-- Remove type if primary is not found
		table.remove(types, i)
		
	end
	
end

  -----------------
 --- Table Setup ---
  -----------------

-- Establish table
local typeData = {
	type = sync.new("EeveeType", 1):config(),
	types = types,
	data = {}
}

-- Create data tables
for k, v in ipairs(typeData.types) do
	typeData.data[v] = {id = k, parts = {}, textures = {}}
end

-- Reset if type is out of bounds
if typeData.type.curr > #typeData.types then
	typeData.type:update(1)
end

  ----------------
 --- Store Data ---
  ----------------

--[[
	
	Note:
	This is used for action wheel icons.
	In addition, `ElementalStones.lua` will pick which stones will transform the player to what type!
	
	Each type has 3 entries, which it will select the highest entry it can, dependent on the item's existance.
	If the item does not exist, the next item in the table is chosen, if able.
	The item choices follow the format of:
	1. Cobblemon item that relates to the type.
	2. Minecraft item that origins can utilize.
	3. Minecraft item that is guarenteed to exist by 1.16.5.
	
--]]
-- Stones
local stones = {
	eevee = {
		"cobblemon:everstone",
		"rabbit_hide", -- This is filler/consistency, origin will not use this
		"brown_glazed_terracotta"
	},
	vaporeon = {
		"cobblemon:water_stone",
		"heart_of_the_sea",
		"blue_glazed_terracotta"
	},
	jolteon = {
		"cobblemon:thunder_stone",
		"waxed_copper_block",
		"yellow_glazed_terracotta"
	},
	flareon = {
		"cobblemon:fire_stone",
		"blaze_rod",
		"red_glazed_terracotta"
	},
	espeon = {
		"cobblemon:dawn_stone",
		"phantom_membrane",
		"magenta_glazed_terracotta"
	},
	umbreon = {
		"cobblemon:dusk_stone",
		"echo_shard",
		"black_glazed_terracotta"
	},
	leafeon = {
		"cobblemon:leaf_stone",
		"glistering_melon_slice",
		"lime_glazed_terracotta"
	},
	glaceon = {
		"cobblemon:ice_stone",
		"blue_ice",
		"blue_glazed_terracotta"
	},
	sylveon = {
		"cobblemon:shiny_stone",
		"amethyst_shard",
		"pink_glazed_terracotta"
	}
}

-- Check stones validity
for k, v in pairs(stones) do
	stones[k] = itemCheck(table.unpack(v)).id
end

-- Store data
for _, v in ipairs(typeData.types) do
	
	-- Parts
	typeData.data[v].parts = parts:createTable(function(part) return part:getName() ~= "EeveeTaur" and part:getName():find(v:gsub("^%l", string.upper)) end)
	
	-- Textures
	typeData.data[v].textures.primary = textures["textures."..v] or textures["EeveeTaur."..v]
	typeData.data[v].textures.secondary = textures["textures."..v.."_e"] or textures["EeveeTaur."..v.."_e"]
	
	-- Stones
	typeData.data[v].stone = stones[v]
	
end

  ---------------
 --- Functions ---
  ---------------

-- Returns index of specifc type, if able
function typeData.getIndex(s)
	return typeData.data[s] and typeData.data[s].id or nil
end

-- Returns string of current type
function typeData.getString()
	return typeData.types[typeData.type.curr]
end

-- Texture swap parts
typeData.mainParts = parts:createTable(function(part) return part:getName():find("_Type") end)

-- Updates textures on all texture swapping parts
-- This function will be modified by the following scripts, if able:
-- Shiny.lua
-- EeveeGender.lua
function typeData.updateTexture()
	
	-- Texture path
	local texData = typeData.data[typeData.getString()].textures
	
	-- Apply
	for _, part in ipairs(typeData.mainParts) do
		
		-- Set primary
		part:primaryTexture("CUSTOM", texData.primary)
		
		-- Set secondary
		if texData.secondary then
			
			part:secondaryTexture("CUSTOM", texData.secondary)
			
		else
			
			part:secondaryTexture("SECONDARY")
			
		end
		
	end
	
end

-- Updates parts shown
function typeData.updateParts()
	
	-- Toggle accessories based on type
	for k, v in pairs(typeData.data) do
		
		local isVisible = typeData.getString() == k
		for _, part in ipairs(v.parts) do
			
			part:visible(isVisible)
			
		end
		
	end
	
end

-- Updates all data to match
-- This function will be modified by the following scripts, if able:
-- Pokeball.lua
function typeData.updateAll()
	typeData.updateTexture()
	typeData.updateParts()
end

-- Init type setup
local prevUpdateAll = typeData.updateAll
function events.ENTITY_INIT()
	prevUpdateAll()
end

-- Apply function
typeData.type:applyFunc(function()
	typeData:updateAll()
end)

-- Return typeData
return typeData