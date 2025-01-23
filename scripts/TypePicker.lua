-- Required script
local typeData = require("scripts.TypeControl")

-- Kills script early if only one type was found in the types table
if #typeData.types == 1 then return {} end

-- Eevee type
function pings.setEeveeType(i)
	
	-- Update type
	typeData:setTarget(((typeData.tarType + i - 1) % #typeData.types) + 1)
	
	-- TEMP PLZ DELETE LATER
	typeData:syncCurType()
	
	typeData:updateParts()
	typeData:updateTexture()
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local s, c = pcall(require, "scripts.ColorProperties")
if not s then c = {} end

-- Ping function
local function allowPing(x)
	
	-- Let ping through if origin override is not active
	if not typeData.origin then
		pings.setEeveeType(x)
	end
	
end

-- Table setup
local t = {}

-- Action
t.setTypeAct = action_wheel:newAction()
	:onLeftClick(function() allowPing(1) end)
	:onRightClick(function() allowPing(-1) end)
	:onScroll(function(x) allowPing(x) end)

-- Update action
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.setTypeAct
			:title(toJson(
				{
					"",
					{text = typeData.tarString:gsub("^%l", string.upper).."\n\n", bold = true, color = c.primary},
					{text = "Left click, Right click, or Scroll to set your type!", color = c.secondary},
					{text = typeData.origin and "\n\nCurrently overridden by origin type toggle." or "", color = "gold"}
				}
			))
			:item(typeData.data[typeData.tarString].stone)
		
		for _, act in pairs(t) do
			act:hoverColor(c.hover)
		end
		
	end
	
end

-- Return action
return t