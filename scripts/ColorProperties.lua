-- Required script
local typeData = require("scripts.TypeControl")

-- Table setup
local colors = {}

-- Color table
-- If Shiny.lua is present, it will provide additional colors to use, and modify these to show the changes
colors.typeColors = {
	
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
	
	-- Current type
	local currCol = colors.typeColors[typeData.getString()]
	
	-- Avatar color
	avatar:color(currCol.primary)
	
	-- Glowing outline
	renderer:outlineColor(currCol.primary)
	
end

-- Host only instructions
if not host:isHost() then return colors end

-- Secondary colors
colors.typeColors.eevee.secondary    = vectors.hexToRGB("F0E3B0")
colors.typeColors.vaporeon.secondary = vectors.hexToRGB("E5E2A5")
colors.typeColors.jolteon.secondary  = vectors.hexToRGB("DBDBE0")
colors.typeColors.flareon.secondary  = vectors.hexToRGB("E3CB71")
colors.typeColors.espeon.secondary   = vectors.hexToRGB("C04053")
colors.typeColors.umbreon.secondary  = vectors.hexToRGB("F1CA5B")
colors.typeColors.leafeon.secondary  = vectors.hexToRGB("E4D48D")
colors.typeColors.glaceon.secondary  = vectors.hexToRGB("89CDD4")
colors.typeColors.sylveon.secondary  = vectors.hexToRGB("85C6EC")

function events.RENDER(delta, context)
	
	-- Current type
	local currCol = colors.typeColors[typeData.getString()]
	
	-- Action variables
	colors.hover     = currCol.secondary
	colors.active    = currCol.primary
	colors.primary   = "#"..vectors.rgbToHex(currCol.primary)
	colors.secondary = "#"..vectors.rgbToHex(currCol.secondary)
	
end

-- Return variables
return colors