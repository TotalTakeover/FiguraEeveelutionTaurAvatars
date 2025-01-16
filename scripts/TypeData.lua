-- Config setup
config:name("EeveelutionTaur")
local types = require("TypeConfig")

-- Init variable
local initType = config:load("EeveeType") or 1

-- Variable setup
local typeData = {
	types = types,
	setType = initType,
	curType = initType,
	textures = {
		-- If Shiny.lua is present, it will provide shiny textures to use if it is able, and modify these to show the changes
		primary = {},
		secondary = {}
	}
}

-- Store textures
-- Deletes type if texture cannot be found
for i = #typeData.types, 1, -1 do
	
	-- Variables
	local curType = typeData.types[i]
	local primaryTex = textures["textures."..curType] or textures["Eevee."..curType]
	
	if primaryTex then
		
		-- Store primary texture
		typeData.textures.primary[curType] = primaryTex
		
		-- Variables
		local secondaryTex = textures["textures."..curType.."_e"] or textures["Eevee."..curType.."_e"]
		local primaryShinyTex = textures["textures."..curType.."_shiny"] or textures["Eevee."..curType.."_shiny"]
		
		if secondaryTex then
			
			-- Store secondary texture
			typeData.textures.secondary[curType] = secondaryTex
			
		end
		
	else
		
		-- Remove type if primary is not found
		table.remove(typeData.types, i)
		
	end
	
end

-- Reset if type is out of bounds
if typeData.setType > #typeData.types then
	
	typeData.setType = 1
	typeData.curType = 1
	
end

-- Types as strings
typeData.setString = typeData.types[typeData.setType]
typeData.curString = typeData.types[typeData.curType]

-- Find capitalized version of type
function typeData:upperCase(s)
	
	return s:gsub("^%l", string.upper)
	
end

-- Return typeData
return typeData