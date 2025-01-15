-- Required scripts
local typeData = require("scripts.TypeData")

-- Table setup
local c = {}

-- Color table
-- If Shiny.lua is present, it will provide additional colors to use, and modify these to show the changes
c.typeColors = {
	
	eevee = {
		primary = vectors.hexToRGB("FFFFFF"),
		secondary = vectors.hexToRGB("FFFFFF")
	},
	vaporeon = {
		primary = vectors.hexToRGB("61A5C5"),
		secondary = vectors.hexToRGB("E5E2A5")
	},
	jolteon = {
		primary = vectors.hexToRGB("E5BC41"),
		secondary = vectors.hexToRGB("DBDBE0")
	},
	flareon = {
		primary = vectors.hexToRGB("DE5F37"),
		secondary = vectors.hexToRGB("E3CB71")
	},
	espeon = {
		primary = vectors.hexToRGB("C5A7C8"),
		secondary = vectors.hexToRGB("C04053")
	},
	umbreon = {
		primary = vectors.hexToRGB("32373E"),
		secondary = vectors.hexToRGB("F1CA5B")
	},
	leafeon = {
		primary = vectors.hexToRGB("2A9057"),
		secondary = vectors.hexToRGB("E4D48D")
	},
	glaceon = {
		primary = vectors.hexToRGB("278596"),
		secondary = vectors.hexToRGB("89CDD4")
	},
	sylveon = {
		primary = vectors.hexToRGB("F999B0"),
		secondary = vectors.hexToRGB("85C6EC")
	}
	
}

function events.RENDER(delta, context)
	
	-- Variables
	local typeString = typeData.types[typeData.curType]
	
	-- Avatar color
	avatar:color(c.typeColors[typeString].primary)
	
	-- Glowing outline
	renderer:outlineColor(c.typeColors[typeString].primary)
	
end

-- Host only instructions
if not host:isHost() then return end

function events.RENDER(delta, context)
	
	-- Variables
	local typeString = typeData.types[typeData.curType]
	
	-- Action variables
	c.hover     = c.typeColors[typeString].secondary
	c.active    = c.typeColors[typeString].primary
	c.primary   = "#"..vectors.rgbToHex(c.typeColors[typeString].primary)
	c.secondary = "#"..vectors.rgbToHex(c.typeColors[typeString].secondary)
	
end

-- Return variables
return c