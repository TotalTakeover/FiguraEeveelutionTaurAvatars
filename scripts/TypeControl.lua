  -------------------
 --- Initial Setup ---
  -------------------

-- Required scripts
local parts     = require("lib.PartsAPI")
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

-- Config setup
config:name("EeveelutionTaur")
local initType = config:load("EeveeType") or 1

-- Establish table
local typeData = {
	tarType = initType,
	curType = initType,
	tarString = types[initType],
	curString = types[initType],
	types = types,
	data = {}
}

-- Create data tables
for k, v in ipairs(typeData.types) do
	
	typeData.data[v] = {id = k, parts = {}, textures = {}}
	
end

-- Reset if type is out of bounds
if initType > #typeData.types then
	
	typeData.tarType = 1
	typeData.curType = 1
	typeData.tarString = typeData.types[1]
	typeData.curString = typeData.types[1]
	
end

  ----------------
 --- Store Data ---
  ----------------

--[[
	
	Note:
	This is used for action wheel icons.
	In addition, `ElementalStones.lua` will pick which stones will transform the player to what type!

--]]
-- Stones
local stones = {
	
	eevee    = itemCheck("cobblemon:everstone",     "brown_glazed_terracotta"),
	vaporeon = itemCheck("cobblemon:water_stone",   "blue_glazed_terracotta"),
	jolteon  = itemCheck("cobblemon:thunder_stone", "yellow_glazed_terracotta"),
	flareon  = itemCheck("cobblemon:fire_stone",    "red_glazed_terracotta"),
	espeon   = itemCheck("cobblemon:dawn_stone",    "magenta_glazed_terracotta"),
	umbreon  = itemCheck("cobblemon:dusk_stone",    "black_glazed_terracotta"),
	leafeon  = itemCheck("cobblemon:leaf_stone",    "lime_glazed_terracotta"),
	glaceon  = itemCheck("cobblemon:ice_stone",     "blue_glazed_terracotta"),
	sylveon  = itemCheck("cobblemon:shiny_stone",   "pink_glazed_terracotta")
	
}

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
function typeData:getIndex(s)
	
	return typeData.data[s] and typeData.data[s].id or nil
	
end

-- Sets target type, if able, otherwise remains the same
function typeData:setTarget(i)
	
	typeData.tarType = typeData.types[i] and i or typeData.tarType
	typeData.tarString = typeData.types[i] or typeData.tarString
	
	config:save("EeveeType", typeData.tarType)
	
end

-- Syncs type variables
function typeData:syncCurType()
	
	typeData.curType = typeData.tarType
	typeData.curString = typeData.tarString
	
end

-- Texture swap parts
local mainParts = parts:createTable(function(part) return part:getName():find("_Type") end)

-- Updates textures on all texture swapping parts
-- These textures are modified by `Shiny.lua` to use shiny textures instead, if able
function typeData:updateTexture()
	
	-- Texture path
	local texData = typeData.data[typeData.curString].textures
	
	-- Apply
	for _, part in ipairs(mainParts) do
		
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
function typeData:updateParts()
	
	-- Toggle accessories based on type
	for k, v in pairs(typeData.data) do
		
		local isVisible = typeData.curString == k
		for _, part in ipairs(v.parts) do
			
			part:visible(isVisible)
			
		end
		
	end
	
end

-- Updates all data to match
-- This function will be modified by Pokeball.lua, as it will have its own methods
function typeData:updateAll()
	
	typeData:syncCurType()
	typeData:updateTexture()
	typeData:updateParts()
	
end

-- Init type setup
typeData:updateAll()

-- Sync variable
function pings.syncEeveeType(i)
	
	typeData:setTarget(i)
	
end

-- Host only instructions
if not host:isHost() then return typeData end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncEeveeType(typeData.tarType)
	end
	
end

-- Return typeData
return typeData