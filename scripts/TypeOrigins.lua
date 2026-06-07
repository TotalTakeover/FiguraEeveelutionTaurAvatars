-- Required scripts
local typeData = require("scripts.TypeControl")
local sync     = require("lib.LetThatSyncFig")
local origins  = require("lib.OriginsAPI")

-- Kills script early if only one type was found in the types table
if #typeData.types == 1 then return {} end

-- Synced variable setup
typeData.origin = sync.new("OriginType", true):config()

function events.TICK()
	
	if typeData.origin.curr then
		for _, v in ipairs(typeData.types) do
			if typeData.getString() ~= v and origins.hasOrigin(player, "eeveelutiontaurs:"..v.."taur") then
				
				-- Update type
				typeData.type:update(typeData.getIndex(v))
				
			end
		end
	end
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local s, wheel, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.TypeOrigins") -- Tries to find script, not required

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
		:item("cobblemon:everstone", "rabbit_spawn_egg")
		:onLeftClick(function() wheel:descend(typePage) end)
end

a.originAct = typePage:newAction()
	:item("ender_pearl")
	:toggleItem("origins:orb_of_origin", "snowball")
	:onToggle(function(bool)
		typeData.origin:update(bool)
	end)
	:toggled(typeData.origin.curr)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if a.pageAct then
			a.pageAct
				:title(toJson(
					{text = "Eeveelutions Types", bold = true, color = c.primary}
				))
		end
		
		a.originAct
			:title(toJson(
				{
					"",
					{text = "Toggle Origin Override\n\n", bold = true, color = c.primary},
					{text = "Allow your origin to override your chosen type.", color = c.secondary}
				}
			))
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end