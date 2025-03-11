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

-- Sync variable
function pings.syncGender(a)
	
	gender = a
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local s, c = pcall(require, "scripts.ColorProperties")
if not s then c = {} end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncGender(gender)
	end
	
end

-- Table setup
local t = {}

-- Action
t.genderAct = action_wheel:newAction()
	:item(itemCheck("blue_dye"))
	:toggleItem(itemCheck("pink_dye"))
	:onToggle(pings.setGenderToggle)

-- Update action
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.genderAct
			:title(toJson(
				{
					"",
					{text = "Toggle Eevee Gender\n\n", bold = true, color = c.primary},
					{text = "Toggles the gender of Eevee.", color = c.secondary},
					{text = typeData.curString ~= "eevee" and "\n\nCurrent type is not eevee! No gender will be applied!" or "", color = "gold"}
					
				}
			))
			:toggled(gender)
		
		for _, act in pairs(t) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end

-- Return action
return t