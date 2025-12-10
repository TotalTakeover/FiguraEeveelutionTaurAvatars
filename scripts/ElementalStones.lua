-- Required script
local typeData = require("scripts.TypeControl")

-- Kills script early if only one type was found in the types table
if #typeData.types == 1 then return {} end

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
	if stone and typeData.origin then
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
			
		end
		
	end
	
end

-- Stone toggle
function pings.setStone(boolean)
	
	stone = boolean
	config:save("EeveeStone", stone)
	
end

-- Sync variables
function pings.syncStone(...)
	
	stone = ...
	
end

-- Host only instructions
if not host:isHost() then return end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncStone(stone)
	end
	
end

-- Required scripts
local s, wheel, itemCheck, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.TypePicker") -- Tries to find script, not required

-- Check for if page already exists
local pageExists = action_wheel:getPage("Type")

-- Pages
local parentPage = action_wheel:getPage("Eeveelution") or action_wheel:getPage("Main")
local typePage   = pageExists or action_wheel:newPage("Type")

-- Actions table setup
local a = {}

-- Actions
if not pageExists then
	a.pageAct = parentPage:newAction()
		:item(itemCheck("cobblemon:everstone", "rabbit_spawn_egg"))
		:onLeftClick(function() wheel:descend(typePage) end)
end

a.stoneAct = typePage:newAction()
	:item(itemCheck("terracotta"))
	:onToggle(function(boolean) if not typeData.origin then pings.setStone(boolean) end end)
	:toggled(stone)

-- Update action
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if a.pageAct then
			a.pageAct
				:title(toJson(
					{text = "Eeveelutions Types", bold = true, color = c.primary}
				))
		end
		
		a.stoneAct
			:title(toJson(
				{
					"",
					{text = "Toggle Stone Type Changing\n\n", bold = true, color = c.primary},
					{text = "Allow various stones to change your typing when held.\nThis expects Cobblemon items, but if they are not present, glazed terracotta works too.", color = c.secondary},
					{text = typeData.origin and "\n\nCurrently overridden by origin type toggle." or "", color = "gold"}
				}
			))
			:toggleItem(typeData.data[typeData.types[math.floor(world.getTime() * 0.05) % #typeData.types + 1]].stone)
			:toggled(stone)
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end