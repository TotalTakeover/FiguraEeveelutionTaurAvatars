-- Required scripts
local parts    = require("lib.PartsAPI")
local typeData = require("scripts.TypeData")

-- Optional scripts
-- This allows the textures to update if shiny was toggled
local s, shiny = pcall(require, "scripts.Shiny")
if not s then shiny = {} end

-- This allows the type to swap if the pokeball script doesnt exist/doesnt function (due to no model)
local s, pokeball = pcall(require, "scripts.Pokeball")
if not s or pokeball == {} then
	
	function events.RENDER(delta, context)
		
		typeData.curType   = typeData.setType
		typeData.curString = typeData.setString
		
	end
	
end

-- Variables
local _type = nil
local _shiny = nil

-- Texture Swap Parts
local mainParts = parts:createTable(function(part) return part:getName():find("_Type") end)

-- Eevee Parts
local eeveeParts = {}
for _, v in ipairs(typeData.types) do
	eeveeParts[v] = parts:createTable(function(part) return part:getName():find(typeData:upperCase(v)) end)
end

function events.RENDER(delta, context)
	
	-- Enable parts based on type
	if _type ~= typeData.curType or _shiny ~= shiny.isShiny then
		
		-- Variables
		local primaryTex = typeData.textures.primary[typeData.curString]
		local secondaryTex = typeData.textures.secondary[typeData.curString]
		
		-- If Shiny.lua is present, it will provide shiny textures to use if it is able, and modify these to show the changes
		for _, part in ipairs(mainParts) do
			
			-- Set Primary
			part:primaryTexture("CUSTOM", primaryTex)
			
			-- Set Secondary
			if secondaryTex then
				part:secondaryTexture("CUSTOM", secondaryTex)
			else
				part:secondaryTexture("SECONDARY")
			end
			
		end
		
		-- Toggle accessories based on type
		for k, v in pairs(eeveeParts) do
			
			local isVisible = typeData.curString == k
			for _, part in ipairs(v) do
				
				part:visible(isVisible)
				
			end
			
		end
		
	end
	
	-- Store data
	_type  = typeData.curType
	_shiny = shiny.isShiny
	
end

-- Kills script early if only one type was found in the types table
-- This prevents the action wheel from creating the type choosing action
if #typeData.types == 1 then return {} end

-- Eevee type
function pings.setEeveeType(i)
	
	-- Update `setType`
	typeData.setType = typeData.setType + i
	if typeData.setType > #typeData.types then typeData.setType = 1 end
	if typeData.setType < 1 then typeData.setType = #typeData.types end
	config:save("EeveeType", typeData.setType)
	
	-- Update `setString`
	typeData.setString = typeData.types[typeData.setType]
	
end

-- Sync variable
function pings.syncEeveeType(a)
	
	typeData.setType = a
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local s, c = pcall(require, "scripts.ColorProperties")

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncEeveeType(typeData.setType)
	end
	
end

-- Table setup
local t = {}

-- Action
t.setTypeAct = action_wheel:newAction()
	:onLeftClick(function() pings.setEeveeType(1) end)
	:onRightClick(function() pings.setEeveeType(-1) end)
	:onScroll(pings.setEeveeType)

-- Primary info table
local typeItem = {
	
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

-- Table setup
local i = {}
i.typeItem = nil

-- Update action
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		-- Set action icon variable
		i.typeItem = typeItem[typeData.setString]
		
		t.setTypeAct
			:title(toJson(
				{
					"",
					{text = typeData:upperCase(typeData.setString):gsub("^%l", string.upper).."\n\n", bold = true, color = c.primary},
					{text = "Left click, Right click, or Scroll to set your type!", color = c.secondary}
				}
			))
			:item(i.typeItem)
		
		for _, page in pairs(t) do
			page:color(c.active):hoverColor(c.hover)
		end
		
	end
	
end

-- Return action
return t, i