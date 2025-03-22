-- Required scripts
local origins  = require("lib.OriginsAPI")
local typeData = require("scripts.TypeControl")

-- Kills script early if only one type was found in the types table
if #typeData.types == 1 then return {} end

-- Config setup
config:name("EeveelutionTaur")
typeData.origin = config:load("OriginType")
if typeData.origin == nil then typeData.origin = true end

function events.TICK()
	
	if typeData.origin then
		for _, v in ipairs(typeData.types) do
			if typeData.tarString ~= v and origins.hasOrigin(player, "eeveelutiontaurs:"..v.."taur") then
				
				-- Update type
				typeData:setTarget(typeData:getIndex(v))
				
			end
		end
	end
	
end

-- Stone toggle
function pings.setOrigin(boolean)
	
	typeData.origin = boolean
	config:save("OriginType", typeData.origin)
	
end

-- Sync variable
function pings.syncOrigin(a)
	
	typeData.origin = a
	
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
t.originAct = action_wheel:newAction()
	:item(itemCheck("ender_pearl"))
	:toggleItem(itemCheck("origins:orb_of_origin"))
	:onToggle(pings.setOrigin)
	:toggled(typeData.origin)

-- Update action
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.originAct
			:title(toJson(
				{
					"",
					{text = "Toggle Origin Override\n\n", bold = true, color = c.primary},
					{text = "Allow your origin to override your chosen type.", color = c.secondary}
				}
			))
		
		for _, act in pairs(t) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end

-- Return action
return t