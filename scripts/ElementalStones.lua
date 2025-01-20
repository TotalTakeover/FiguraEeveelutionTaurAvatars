-- Required script
local typeData = require("scripts.TypeControl")

-- Kills script early if only one type was found in the types table
if #typeData.types == 1 then return {} end

-- Optional script
local s, origin = pcall(require, "scripts.OriginsType")
if not s then origin = {} end

-- Config setup
config:name("EeveelutionTaur")
local stone = config:load("TypeStone")
if stone == nil then stone = true end

-- Match hand item to stone, returns nil if no match
local function matchHand(item)
	
	for _, v in ipairs(typeData.types) do
		
		-- Stone associated with type
		local typeStone = typeData.data[v].stone
		if typeStone and item == typeStone.id then
			return v
		end
		
	end
	
	-- Returns nil if none found
	return nil
	
end

function events.RENDER(delta, context)
	
	-- Disable stone if origin override is active
	if stone and origin.setType then
		stone = false
	end
	
	-- Check main hand for stones, and if verified, toggle to type
	if stone then
		
		-- Variables
		local match = false
		local main = player:getHeldItem().id
		local off  = player:getHeldItem(true).id
		
		-- Stone variables
		local mainStone = matchHand(main)
		local offStone = matchHand(off)
		local pickedStone = mainStone or offStone
		
		if pickedStone and pickedStone ~= typeData.tarString then
			
			-- Update type
			typeData:setTarget(typeData:getIndex(pickedStone))
			
			-- TEMP PLZ DELETE LATER
			typeData:syncCurType()
			
			typeData:updateParts()
			typeData:updateTexture()
			
		end
		
	end
	
end

-- Stone toggle
function pings.setStone(boolean)
	
	stone = boolean
	config:save("EeveeStone", stone)
	
end

-- Sync variable
function pings.syncStone(a)
	
	stone = a
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local s, c = pcall(require, "scripts.ColorProperties")
if not s then c = {} end

-- Table setup
local t = {}

-- Action
t.stoneAct = action_wheel:newAction()
	:item(itemCheck("terracotta"))
	:onToggle(function(boolean) if not origin.setType then pings.setStone(boolean) end end)
	:toggled(stone)

-- Update action
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.stoneAct
			:title(toJson(
				{
					"",
					{text = "Toggle Stone Type Changing\n\n", bold = true, color = c.primary},
					{text = "Allow various stones to change your typing when held.\nThis expects Cobblemon items, but if they are not present, glazed terracotta works too.", color = c.secondary},
					{text = origin.setType and "\n\nCurrently overridden by origin type toggle." or "", color = "gold"}
				}
			))
			:toggleItem(typeData.data[typeData.types[math.floor(world.getTime() * 0.05) % #typeData.types + 1]].stone)
			:toggled(stone)
		
		for _, page in pairs(t) do
			page:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end

-- Return action
return t