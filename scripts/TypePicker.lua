-- Required script
local typeData = require("scripts.TypeControl")

-- Kills script early if only one type was found in the types table
if #typeData.types == 1 then return {} end

-- Eevee type
function pings.setEeveeType(i)
	
	-- Update type
	typeData:setTarget(((typeData.tarType + i - 1) % #typeData.types) + 1)
	
end

-- Host only instructions
if not host:isHost() then return end

-- Ping function
local function allowPing(x)
	
	-- Let ping through if origin override is not active
	if not typeData.origin then
		pings.setEeveeType(x)
	end
	
end

-- Required scripts
local s, wheel, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
local s, pokeballActs = pcall(require, "scripts.Pokeball") -- Tries to find script, not required
if not s then pokeballActs = {} end
pcall(require, "scripts.Shiny") -- Tries to find script, not required

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

a.setTypeAct = typePage:newAction()
	:onLeftClick(function() allowPing(1) end)
	:onRightClick(function() allowPing(-1) end)
	:onScroll(function(x) allowPing(x) end)

-- This allows this script to move an action made by another, in the event it exists
local eeveelutionPage = action_wheel:getPage("Eeveelution")
if eeveelutionPage and pokeballActs.typeHideAct then
	for k, v in ipairs(eeveelutionPage:getActions()) do
		if v == pokeballActs.typeHideAct then eeveelutionPage:setAction(k, nil) break end
	end
	typePage:setAction(-1, pokeballActs.typeHideAct)
end

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if a.pageAct then
			a.pageAct
				:title(toJson(
					{text = "Eeveelutions Types", bold = true, color = c.primary}
				))
		end
		
		a.setTypeAct
			:title(toJson(
				{
					"",
					{text = typeData.tarString:gsub("^%l", string.upper).."\n\n", bold = true, color = c.primary},
					{text = "Left click, Right click, or Scroll to set your type!", color = c.secondary},
					{text = typeData.origin and "\n\nCurrently overridden by origin type toggle." or "", color = "gold"}
				}
			))
			:item(table.unpack(typeData.data[typeData.tarString].stone))
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover)
		end
		
	end
	
end