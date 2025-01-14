-- Required scripts
local parts    = require("lib.PartsAPI")
local typeData = require("scripts.EeveeType")

-- Variables
local _type = nil

-- Texture Swap Parts
local mainParts = parts:createTable(function(part) return part:getName():find("_Type") end)

-- Eevee Parts
local eeveeParts = {}
for _, v in ipairs(typeData.types) do
	eeveeParts[v] = parts:createTable(function(part) return part:getName():find(typeData:upperCase(v)) end)
end

function events.RENDER(delta, context)
	
	-- Enable parts based on type
	if _type ~= typeData.setType then
		
		-- Variables
		local typeString = typeData.types[typeData.setType]
		local primaryTex = typeData.textures.primary[typeString]
		local secondaryTex = typeData.textures.secondary[typeString]
		
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
		
		for k, v in pairs(eeveeParts) do
			
			local isVisible = typeString == k
			for _, part in ipairs(v) do
				
				part:visible(isVisible)
				
			end
			
		end
		
	end
	
	-- Store data
	_type = typeData.setType
	
end

-- Eevee type
function pings.setEeveeType(i)
	
	typeData.setType = typeData.setType + i
	if typeData.setType > #typeData.types then typeData.setType = 1 end
	if typeData.setType < 1 then typeData.setType = #typeData.types end
	config:save("EeveeType", typeData.setType)
	
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
t.typeAct = action_wheel:newAction()
	:onLeftClick(function() pings.setEeveeType(1) end)
	:onRightClick(function() pings.setEeveeType(-1) end)
	:onScroll(pings.setEeveeType)

-- Primary info table
local typeItem = {
	
	eevee    = itemCheck("cobblemon:everstone",     "white_glazed_terracotta"),
	vaporeon = itemCheck("cobblemon:water_stone",   "blue_glazed_terracotta"),
	jolteon  = itemCheck("cobblemon:thunder_stone", "yellow_glazed_terracotta"),
	flareon  = itemCheck("cobblemon:fire_stone",    "red_glazed_terracotta"),
	espeon   = itemCheck("cobblemon:psychic_gem",   "magenta_glazed_terracotta"),
	umbreon  = itemCheck("cobblemon:dark_gem",      "black_glazed_terracotta"),
	leafeon  = itemCheck("cobblemon:leaf_stone",    "lime_glazed_terracotta"),
	glaceon  = itemCheck("cobblemon:ice_stone",     "blue_glazed_terracotta"),
	sylveon  = itemCheck("cobblemon:fairy_gem",     "pink_glazed_terracotta")
	
}

-- Update action
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.typeAct
			:title(toJson(
				{
					"",
					{text = typeData:upperCase(typeData.types[typeData.setType]):gsub("^%l", string.upper).."\n\n", bold = true, color = c.primary},
					{text = "Left click, Right click, or scroll to set your type!", color = c.secondary}
				}
			))
			:item(typeItem[typeData.types[typeData.setType]])
		
		for _, page in pairs(t) do
			page:hoverColor(c.hover)
		end
		
	end
	
end

-- Return action
return t