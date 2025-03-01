-- Required scripts
local typeData = require("scripts.TypeControl")

-- Table setup
local c = {}

-- Color table
-- If Shiny.lua is present, it will provide additional colors to use, and modify these to show the changes
c.typeColors = {
	
	eevee    = {primary = vectors.hexToRGB("AE6C44")},
	vaporeon = {primary = vectors.hexToRGB("61A5C5")},
	jolteon  = {primary = vectors.hexToRGB("E5BC41")},
	flareon  = {primary = vectors.hexToRGB("DE5F37")},
	espeon   = {primary = vectors.hexToRGB("C5A7C8")},
	umbreon  = {primary = vectors.hexToRGB("32373E")},
	leafeon  = {primary = vectors.hexToRGB("2A9057")},
	glaceon  = {primary = vectors.hexToRGB("278596")},
	sylveon  = {primary = vectors.hexToRGB("F999B0")}
	
}

function events.RENDER(delta, context)
	
	-- Avatar color
	avatar:color(c.typeColors[typeData.curString].primary)
	
	-- Glowing outline
	renderer:outlineColor(c.typeColors[typeData.curString].primary)
	
end

-- Host only instructions
if not host:isHost() then return c end

-- Secondary colors
c.typeColors.eevee.secondary    = vectors.hexToRGB("F0E3B0")
c.typeColors.vaporeon.secondary = vectors.hexToRGB("E5E2A5")
c.typeColors.jolteon.secondary  = vectors.hexToRGB("DBDBE0")
c.typeColors.flareon.secondary  = vectors.hexToRGB("E3CB71")
c.typeColors.espeon.secondary   = vectors.hexToRGB("C04053")
c.typeColors.umbreon.secondary  = vectors.hexToRGB("F1CA5B")
c.typeColors.leafeon.secondary  = vectors.hexToRGB("E4D48D")
c.typeColors.glaceon.secondary  = vectors.hexToRGB("89CDD4")
c.typeColors.sylveon.secondary  = vectors.hexToRGB("85C6EC")

function events.RENDER(delta, context)
	
	-- Action variables
	c.hover     = c.typeColors[typeData.curString].secondary
	c.active    = c.typeColors[typeData.curString].primary
	c.primary   = "#"..vectors.rgbToHex(c.typeColors[typeData.curString].primary)
	c.secondary = "#"..vectors.rgbToHex(c.typeColors[typeData.curString].secondary)
	
end

-- Return variables
return c