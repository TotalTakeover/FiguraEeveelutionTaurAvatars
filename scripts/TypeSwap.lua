-- Required scripts
local parts     = require("lib.PartsAPI")
local itemCheck = require("lib.ItemCheck")
local typeData  = require("scripts.TypeData")

-- Config setup
config:name("EeveelutionTaur")
local stone = config:load("TypeStone")
if stone == nil then stone = true end

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

-- Stones table
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

-- Delete stone info if type doesnt exist
for k in pairs(stones) do
	if not typeData.typesId[k] then
		stones[k] = nil
	end
end

-- Texture Swap Parts
local mainParts = parts:createTable(function(part) return part:getName():find("_Type") end)

-- Eevee Parts
local eeveeParts = {}
for _, v in ipairs(typeData.types) do
	eeveeParts[v] = parts:createTable(function(part) return part:getName():find(typeData:upperCase(v)) end)
end

function events.RENDER(delta, context)
	
	-- Check main hand for stones, and if verified, toggle to type
	if stone then
		
		-- Variables
		local main = player:getHeldItem().id
		local off  = player:getHeldItem(true).id
		
		for k, v in pairs(stones) do
			
			if (main == v.id or off == v.id) then
				
				typeData.setType = typeData.typesId[k]
				typeData.setString = k
				break
				
			end
			
		end
		
	end
	
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

-- Stone toggle
function pings.setEeveeStone(boolean)
	
	stone = boolean
	config:save("EeveeStone", stone)
	
end

-- Sync variable
function pings.syncEeveeType(a, b)
	
	typeData.setType = a
	stone            = b
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required script
local s, c = pcall(require, "scripts.ColorProperties")
if not s then c = {} end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncEeveeType(typeData.setType, stone)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.setTypeAct = action_wheel:newAction()
	:onLeftClick(function() pings.setEeveeType(1) end)
	:onRightClick(function() pings.setEeveeType(-1) end)
	:onScroll(pings.setEeveeType)

t.setStoneAct = action_wheel:newAction()
	:item(itemCheck("terracotta"))
	:onToggle(pings.setEeveeStone)
	:toggled(stone)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.setTypeAct
			:title(toJson(
				{
					"",
					{text = typeData:upperCase(typeData.setString):gsub("^%l", string.upper).."\n\n", bold = true, color = c.primary},
					{text = "Left click, Right click, or Scroll to set your type!", color = c.secondary}
				}
			))
			:item(stones[typeData.setString])
			:color(c.active)
		
		t.setStoneAct
			:title(toJson(
				{
					"",
					{text = "Toggle Stone Type Changing\n\n", bold = true, color = c.primary},
					{text = "Allow various stones to change your typing when held.\nThis expects Cobblemon items, but if they are not present, glazed terracotta works too.", color = c.secondary}
				}
			))
			:toggleItem(stones[typeData.types[math.floor(world.getTime() * 0.05) % #typeData.types + 1]])
			:toggleColor(c.active)
		
		for _, page in pairs(t) do
			page:hoverColor(c.hover)
		end
		
	end
	
end

-- Return actions
return t