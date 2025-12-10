-- Required script
local typeData = require("scripts.TypeControl")

-- Optional script
local allowColor, c = pcall(require, "scripts.ColorProperties")
if not allowColor then c = {} end

-- Shiny colors
local shinyColors = {}
if allowColor then
	
	shinyColors.eevee    = {primary = vectors.hexToRGB("C9C8b5")}
	shinyColors.vaporeon = {primary = vectors.hexToRGB("C275C5")}
	shinyColors.jolteon  = {primary = vectors.hexToRGB("91D644")}
	shinyColors.flareon  = {primary = vectors.hexToRGB("AC742C")}
	shinyColors.espeon   = {primary = vectors.hexToRGB("65C13C")}
	shinyColors.umbreon  = {primary = vectors.hexToRGB("323B3E")}
	shinyColors.leafeon  = {primary = vectors.hexToRGB("13A14B")}
	shinyColors.glaceon  = {primary = vectors.hexToRGB("218BC0")}
	shinyColors.sylveon  = {primary = vectors.hexToRGB("7BB9EB")}
	
end

-- Config setup
config:name("EeveelutionTaur")
typeData.shiny = config:load("ShinyToggle") == nil and vec(client.uuidToIntArray(avatar:getUUID())).x % 4096 == 0 or config:load("ShinyToggle")

-- Store data
local initTex = {}
local shinyTex = {}
local shinyParts = {}
local initColors = {}
for k, v in pairs(typeData.data) do
	
	-- Create tables
	initTex[k] = {}
	shinyTex[k] = {}
	shinyParts[k] = {}
	initColors[k] = {}
	
	-- Init textures
	initTex[k].primary = v.textures.primary
	initTex[k].secondary = v.textures.secondary
	
	-- Shiny textures
	shinyTex[k].primary = textures["textures."..k.."_shiny"] or textures["EeveeTaur."..k.."_shiny"]
	shinyTex[k].secondary = textures["textures."..k.."_shiny_e"] or textures["EeveeTaur."..k.."_shiny_e"]
	
	-- Shiny parts
	for _, part in ipairs(v.parts) do
		for i, child in ipairs(part:getChildren()) do
			
			if child:getName():find("_[Ss]hiny") then
				table.insert(shinyParts[k], child)
			end
			
		end
	end
	
	-- Store init colors
	if allowColor then
		for h, color in pairs(c.typeColors[k]) do
			initColors[k][h] = color
		end
	end
	
end

-- Modifies the update function to allow the player to enter their pokeball before changing types
local prevUpdateTexture = typeData.updateTexture
function typeData:updateTexture()
	
	-- Current type
	local curType = typeData.curString
	
	-- Textures
	local primary = typeData.shiny and shinyTex[curType].primary or initTex[curType].primary
	local secondary = typeData.shiny and shinyTex[curType].secondary or initTex[curType].secondary
	
	-- Set textures
	typeData.data[curType].textures.primary = primary
	typeData.data[curType].textures.secondary = secondary
	
	-- Set part textures
	for _, part in ipairs(shinyParts[curType]) do
		
		part:primaryTexture("CUSTOM", primary)
		
		if typeData.data[curType].textures.secondary then
			
			part:secondaryTexture("CUSTOM", secondary)
			
		else
			
			part:secondaryTexture("SECONDARY")
			
		end
		
	end
	
	prevUpdateTexture()
	
	-- Update colors
	if allowColor then
		
		c.typeColors[curType] = typeData.shiny and shinyColors[curType] or initColors[curType]
		
	end
	
end

-- Shiny toggle
function pings.setShinyToggle(boolean)
	
	typeData.shiny = boolean
	config:save("ShinyToggle", typeData.shiny)
	
	typeData:updateTexture()
	
	if player:isLoaded() and typeData.shiny then
		sounds:playSound("block.amethyst_block.chime", player:getPos())
	end
	
end

-- Sync variables
function pings.syncShiny(...)
	
	typeData.shiny = ...
	
end

-- Host only instructions
if not host:isHost() then return end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncShiny(typeData.shiny)
	end
	
end

-- Required scripts
local s, wheel, itemCheck = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Pokeball") -- Tries to find script, not required

-- Secondary colors
if allowColor then
	
	shinyColors.eevee.secondary    = vectors.hexToRGB("D4DCE9")
	shinyColors.vaporeon.secondary = vectors.hexToRGB("E5E2A5")
	shinyColors.jolteon.secondary  = vectors.hexToRGB("DBDBE0")
	shinyColors.flareon.secondary  = vectors.hexToRGB("DEC568")
	shinyColors.espeon.secondary   = vectors.hexToRGB("C04053")
	shinyColors.umbreon.secondary  = vectors.hexToRGB("47BDE2")
	shinyColors.leafeon.secondary  = vectors.hexToRGB("FAD185")
	shinyColors.glaceon.secondary  = vectors.hexToRGB("C7FAFF")
	shinyColors.sylveon.secondary  = vectors.hexToRGB("EA8B9A")
	
end

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

a.shinyAct = eeveelutionPage:newAction()
	:item(itemCheck("gunpowder"))
	:toggleItem(itemCheck("glowstone_dust"))
	:onToggle(pings.setShinyToggle)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if a.pageAct then
			a.pageAct
				:title(toJson(
					{text = "Eeveelutions Settings", bold = true, color = c.primary}
				))
		end
		
		a.shinyAct
			:title(toJson(
				{
					"",
					{text = "Toggle Shiny Textures\n\n", bold = true, color = c.primary},
					{text = "Toggles the usage of shiny textures for your pokemon parts.", color = c.secondary}
				}
			))
			:toggled(typeData.shiny)
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end