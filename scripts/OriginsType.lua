-- Required scripts
local originAPI = require("lib.OriginsAPI")
local typeData  = require("scripts.TypeControl")

-- Kills script early if only one type was found in the types table
if #typeData.types == 1 then return {} end

-- Table setup
local origin = {}

-- Config setup
config:name("EeveelutionTaur")
origin.setType = config:load("OriginType")
if origin.setType == nil then origin.setType = true end

function events.TICK()
	
	if origin.setType then
		for _, v in ipairs(typeData.types) do
			if typeData.tarString ~= v and originAPI.hasOrigin(player,  "eeveelutiontaurs:"..v.."taur") then
				
				-- Update type
				typeData:setTarget(typeData:getIndex(v))
				
				-- TEMP PLZ DELETE LATER
				typeData:syncCurType()
				
				typeData:updateParts()
				typeData:updateTexture()
				
			end
		end
	end
	
end

-- Stone toggle
function pings.setOrigin(boolean)
	
	origin.setType = boolean
	config:save("OriginType", origin.setType)
	
end

-- Sync variable
function pings.syncOrigin(a)
	
	origin.setType = a
	
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
	:toggled(origin.setType)

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
		
		for _, page in pairs(t) do
			page:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end

-- Return variable and action
return origin, t