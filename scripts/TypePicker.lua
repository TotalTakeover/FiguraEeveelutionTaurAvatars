-- Host only instructions
if not host:isHost() then return end

-- Required script
local typeData = require("scripts.TypeControl")

-- Kills script early if only one type was found in the types table
if #typeData.types == 1 then return {} end

-- Required scripts
local s, pageNav, acts, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Pokeball") -- Tries to find script, not required
pcall(require, "scripts.Shiny") -- Tries to find script, not required

-- Check for if page already exists
local pageExists = action_wheel:getPage("Type")

-- Pages
local parentPage = action_wheel:getPage("Eeveelution") or action_wheel:getPage("Main")
local typePage   = pageExists or action_wheel:newPage("Type")

-- Set type loop
local function setType(i)
	if not (typeData.origin and typeData.origin.curr) then
		return ((typeData.type.curr + i - 1) % #typeData.types) + 1
	else
		return typeData.type.curr
	end
end

-- Actions
if not pageExists then
	acts.typesPage = parentPage:newAction()
		:item("cobblemon:everstone", "rabbit_spawn_egg")
		:onLeftClick(function() pageNav.descend(typePage) end)
end

acts.eeveeTypeChange = typePage:newAction()
	:onLeftClick(function() typeData.type:update(setType(1)) end)
	:onRightClick(function() typeData.type:update(setType(-1)) end)
	:onScroll(function(x) typeData.type:update(setType(x), 10) end)

-- This allows this script to move an action made by another, in the event it exists
local eeveelutionPage = action_wheel:getPage("Eeveelution")
if eeveelutionPage and acts.pokeballTypeHide then
	for k, v in ipairs(eeveelutionPage:getActions()) do
		if v == acts.pokeballTypeHide then eeveelutionPage:setAction(k, nil) break end
	end
	typePage:setAction(-1, acts.pokeballTypeHide)
end

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if acts.typesPage then
			acts.typesPage
				:title(toJson(
					{text = "Eeveelutions Types", bold = true, color = c.primary}
				))
				:hoverColor(c.hover)
		end
		
		acts.eeveeTypeChange
			:title(toJson(
				{
					"",
					{text = typeData.getString():gsub("^%l", string.upper).."\n\n", bold = true, color = c.primary},
					{text = "Left click, Right click, or Scroll to set your type!", color = c.secondary},
					{text = typeData.origin and typeData.origin.curr and "\n\nCurrently overridden by origin type toggle." or "", color = "gold"}
				}
			))
			:item(typeData.data[typeData.getString()].stone)
			:hoverColor(c.hover)
		
	end
	
end