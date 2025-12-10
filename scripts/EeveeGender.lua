--[[
	
	Yo! Total here!
	If you plan on deleting this script, just remember to add the eevee tail texture's & UVs back to its base textures!
	I was unable to have both tail types on the base texture without breaking foundation, so I opted for a separate texture.
	It's expecting 1 (2 if shiny) textures, but this script specifically overrides that, and preforms changes after all others. 
	
	This script is kinda hard coded, please go easy on me!
	
--]]

-- Required scripts
local parts = require("lib.PartsAPI")
local typeData = require("scripts.TypeControl")

-- Kills script early if Eevee couldnt be found in the types table
if not typeData.data["eevee"] then return {} end

-- Config setup
config:name("EeveelutionTaur")
local gender = config:load("GenderToggle") or false

-- Modifies the texture function to add an additional step of setting the gender of eevee
local prevUpdateTexture = typeData.updateTexture
function typeData:updateTexture()
	
	-- Do all prior instructions
	prevUpdateTexture()
	
	-- Kill script if not eevee
	if typeData.curString ~= "eevee" then return end
	
	-- Textures
	local primary = textures["textures.eeveeTail"] or textures["EeveeTaur.eeveeTail"]
	local secondary = textures["textures.eeveeTail_e"] or textures["EeveeTaur.eeveeTail_e"]
	
	-- Shiny check
	if typeData.shiny then
		primary = textures["textures.eeveeTail_shiny"] or textures["EeveeTaur.eeveeTail_shiny"] or primary
		secondary = textures["textures.eeveeTail_shiny_e"] or textures["EeveeTaur.eeveeTail_shiny_e"] or secondary
	end
	
	-- Tail
	local tail = parts.group.EeveeTail
	
	-- Apply tail changes
	if tail then
		
		for _, part in ipairs(tail:getChildren()) do
			
			part
				:primaryTexture("CUSTOM", primary)
				:uv(gender and vec(0, 0.5) or 0)
			
			if secondary then
				
				part:secondaryTexture("CUSTOM", secondary)
				
			end
			
		end
		
	end
	
end

-- Gender toggle
function pings.setGenderToggle(boolean)
	
	gender = boolean
	config:save("GenderToggle", gender)
	
	if typeData.curString == "eevee" then
		typeData:updateTexture()
	end
	
end

-- Sync variables
function pings.syncGender(...)
	
	gender = ...
	
end

-- Host only instructions
if not host:isHost() then return end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncGender(gender)
	end
	
end

-- Required scripts
local s, wheel, itemCheck, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Shiny") -- Tries to find script, not required

-- Check for if page already exists
local pageExists = action_wheel:getPage("Eeveelution")

-- Pages
local parentPage      = action_wheel:getPage("Main")
local eeveelutionPage = pageExists or action_wheel:newPage("Eeveelution")

-- Actions table setup
local a = {}

-- Actions
if not pageExists then
	a.pageAct = parentPage:newAction()
		:item(itemCheck("cobblemon:everstone", "rabbit_spawn_egg"))
		:onLeftClick(function() wheel:descend(eeveelutionPage) end)
end

a.genderAct = eeveelutionPage:newAction()
	:item(itemCheck("blue_dye"))
	:toggleItem(itemCheck("pink_dye"))
	:onToggle(pings.setGenderToggle)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if a.pageAct then
			a.pageAct
				:title(toJson(
					{text = "Eeveelutions Settings", bold = true, color = c.primary}
				))
		end
		
		a.genderAct
			:title(toJson(
				{
					"",
					{text = "Toggle Eevee Gender\n\n", bold = true, color = c.primary},
					{text = "Toggles the gender of Eevee.", color = c.secondary},
					{text = typeData.curString ~= "eevee" and "\n\nCurrent type is not eevee! No gender will be applied!" or "", color = "gold"}
					
				}
			))
			:toggled(gender)
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end