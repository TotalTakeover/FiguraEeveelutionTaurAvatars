-- Required scripts
local typeData = require("scripts.TypeControl")
local sync     = require("lib.LetThatSyncFig")

-- Optional script
local allowColor, colors = pcall(require, "scripts.ColorProperties")
if not allowColor then colors = {} end

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

-- Synced variable setup
typeData.shiny = sync.new("ShinyToggle", vec(client.uuidToIntArray(avatar:getUUID())).x % 4096 == 0):config()

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
		for h, color in pairs(colors.typeColors[k]) do
			initColors[k][h] = color
		end
	end
	
end

-- Modifies the update function to allow the player to enter their pokeball before changing types
local prevUpdateTexture = typeData.updateTexture
function typeData.updateTexture()
	
	-- Current type
	local currStr = typeData.getString()
	
	-- Textures
	local primary = typeData.shiny.curr and shinyTex[currStr].primary or initTex[currStr].primary
	local secondary = typeData.shiny.curr and shinyTex[currStr].secondary or initTex[currStr].secondary
	
	-- Set textures
	typeData.data[currStr].textures.primary = primary
	typeData.data[currStr].textures.secondary = secondary
	
	-- Set part textures
	for _, part in ipairs(shinyParts[currStr]) do
		
		part:primaryTexture("CUSTOM", primary)
		
		if typeData.data[currStr].textures.secondary then
			
			part:secondaryTexture("CUSTOM", secondary)
			
		else
			
			part:secondaryTexture("SECONDARY")
			
		end
		
	end
	
	prevUpdateTexture()
	
	-- Update colors
	if allowColor then
		
		colors.typeColors[currStr] = typeData.shiny.curr and shinyColors[currStr] or initColors[currStr]
		
	end
	
end

-- Apply function
typeData.shiny:addFunc(function()
	typeData.updateTexture()
	if player:isLoaded() and typeData.shiny.curr then
		sounds:playSound("block.amethyst_block.chime", player:getPos())
	end
end)

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local s, pageNav, acts = pcall(require, "scripts.ActionWheel")
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

-- Actions
if not pageExists then
	acts.eeveePage = parentPage:newAction()
		:item("cobblemon:everstone", "rabbit_spawn_egg")
		:onLeftClick(function() pageNav.descend(eeveelutionPage) end)
end

acts.shinyToggle = eeveelutionPage:newAction()
	:item("gunpowder")
	:toggleItem("glowstone_dust")
	:onToggle(function(bool)
		typeData.shiny:update(bool)
	end)
	:toggled(typeData.shiny.curr)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if acts.eeveePage then
			acts.eeveePage
				:title(toJson(
					{text = "Eeveelutions Settings", bold = true, color = colors.primary}
				))
				:hoverColor(colors.hover)
		end
		
		acts.shinyToggle
			:title(toJson(
				{
					"",
					{text = "Toggle Shiny Textures\n\n", bold = true, color = colors.primary},
					{text = "Toggles the usage of shiny textures for your pokemon parts.", color = colors.secondary}
				}
			))
			:hoverColor(colors.hover)
			:toggleColor(colors.active)
		
	end
	
end