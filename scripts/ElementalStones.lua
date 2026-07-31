-- Required scripts
local typeData = require("scripts.TypeControl")
local sync     = require("lib.LetThatSyncFig")

-- Kills script early if only one type was found in the types table
if #typeData.types == 1 then return {} end

-- Synced variables setup
local stone = sync.new("TypeStone", true):config()

-- Match hand item to stone, returns nil if no match
local function matchHand(item)
	
	for _, v in ipairs(typeData.types) do
		
		-- Stone associated with type
		local typeStone = typeData.data[v].stone
		if typeStone and item == typeStone then
			return v
		end
		
	end
	
	-- Returns nil if none found
	return nil
	
end

function events.RENDER(delta, context)
	
	-- Disable stone if origin override is active
	if stone.curr and typeData.origin and typeData.origin.curr then
		stone:update(false)
	end
	
	-- Check main hand for stones, and if verified, toggle to type
	if stone.curr then
		local foundStone = matchHand(player:getHeldItem().id) or matchHand(player:getHeldItem(true).id)
		if foundStone and foundStone ~= typeData.type.curr then
			typeData.type:update(typeData.getIndex(foundStone))
		end
	end
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local s, pageNav, acts, colors = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.TypePicker") -- Tries to find script, not required

-- Check for if page already exists
local pageExists = action_wheel:getPage("Type")

-- Pages
local parentPage = action_wheel:getPage("Eeveelution") or action_wheel:getPage("Main")
local typePage   = pageExists or action_wheel:newPage("Type")

-- Actions
if not pageExists then
	acts.typesPage = parentPage:newAction()
		:item("cobblemon:everstone", "rabbit_spawn_egg")
		:onLeftClick(function() pageNav.descend(typePage) end)
end

acts.stoneToggle = typePage:newAction()
	:item("terracotta")
	:onToggle(function(bool)
		if not (typeData.origin and typeData.origin.curr) then
			stone:update(bool)
		end
	end)
	:toggled(stone.curr)

-- Update action
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if acts.typesPage then
			acts.typesPage
				:title(toJson(
					{text = "Eeveelutions Types", bold = true, color = colors.primary}
				))
				:hoverColor(colors.hover)
		end
		
		acts.stoneToggle
			:title(toJson(
				{
					"",
					{text = "Toggle Stone Type Changing\n\n", bold = true, color = colors.primary},
					{text = "Allow various stones to change your typing when held.\nThis expects Cobblemon items, but if they are not present, glazed terracotta works too.", color = colors.secondary},
					{text = typeData.origin and typeData.origin.curr and "\n\nCurrently overridden by origin type toggle." or "", color = "gold"}
				}
			))
			:toggleItem(typeData.data[typeData.types[math.floor(world.getTime() * 0.05) % #typeData.types + 1]].stone)
			:toggled(stone.curr)
			:hoverColor(colors.hover)
			:toggleColor(colors.active)
		
	end
	
end