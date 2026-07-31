--[[
	
	Yo! Total here!
	If you plan on deleting this script, just remember to add the eevee tail texture's & UVs back to its base textures!
	I was unable to have both tail types on the base texture without breaking foundation, so I opted for a separate texture.
	It's expecting 1 (2 if shiny) textures, but this script specifically overrides that, and preforms changes after all others. 
	
	This script is kinda hard coded, please go easy on me!
	
--]]

-- Required scripts
local parts    = require("lib.PartsAPI")
local typeData = require("scripts.TypeControl")
local sync     = require("lib.LetThatSyncFig")

-- Kills script early if Eevee couldnt be found in the types table
if not typeData.data["eevee"] then return {} end

-- Synced variables setup
local gender = sync.new("GenderToggle", false):config()

-- Modifies the texture function to add an additional step of setting the gender of eevee
local prevUpdateTexture = typeData.updateTexture
function typeData.updateTexture()
	
	-- Do all prior instructions
	prevUpdateTexture()
	
	-- Kill script if not eevee
	if typeData.getString() ~= "eevee" then return end
	
	-- Textures
	local primary = textures["textures.eeveeTail"] or textures["EeveeTaur.eeveeTail"]
	local secondary = textures["textures.eeveeTail_e"] or textures["EeveeTaur.eeveeTail_e"]
	
	-- Shiny check
	if typeData.shiny and typeData.shiny.curr then
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
				:uv(gender.curr and vec(0, 0.5) or 0)
			
			if secondary then
				
				part:secondaryTexture("CUSTOM", secondary)
				
			end
			
		end
		
	end
	
end

-- Apply function
gender:applyFunc(function()
	if typeData.getString() == "eevee" then
		typeData.updateTexture()
	end
end)

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local s, pageNav, acts, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Shiny") -- Tries to find script, not required

-- Check for if page already exists
local pageExists = action_wheel:getPage("Eeveelution")

-- Pages
local parentPage      = action_wheel:getPage("Main")
local eeveelutionPage = pageExists or action_wheel:newPage("Eeveelution")

-- Actions
if not pageExists then
	acts.eeveePage = parentPage:newAction()
		:item("cobblemon:everstone", "rabbit_spawn_egg")
		:onLeftClick(function() pageNav.descend(eeveelutionPage) end)
end

acts.genderToggle = eeveelutionPage:newAction()
	:item("blue_dye")
	:toggleItem("pink_dye")
	:onToggle(function(bool)
		gender:update(bool)
	end)
	:toggled(gender.curr)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if acts.eeveePage then
			acts.eeveePage
				:title(toJson(
					{text = "Eeveelutions Settings", bold = true, color = c.primary}
				))
				:hoverColor(c.hover)
		end
		
		acts.genderToggle
			:title(toJson(
				{
					"",
					{text = "Toggle Eevee Gender\n\n", bold = true, color = c.primary},
					{text = "Toggles the gender of Eevee.", color = c.secondary},
					{text = typeData.getString() ~= "eevee" and "\n\nCurrent type is not eevee! No gender will be applied!" or "", color = "gold"}
					
				}
			))
			:hoverColor(c.hover)
			:toggleColor(c.active)
		
	end
	
end