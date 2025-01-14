-- Config setup
config:name("EeveelutionTaur")

-- Variable setup
local typeData = {
	setType = config:load("EeveeType") or 1,
	curType = config:load("EeveeType") or 1,
	types = {
		"eevee",
		"vaporeon",
		"jolteon",
		"flareon",
		"espeon",
		"umbreon",
		"leafeon",
		"glaceon",
		"sylveon"
	},
	textures = {
		primary = {},
		secondary = {},
		primaryShiny = {},
		secondaryShiny = {}
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
		
		if primaryShinyTex then
			
			-- Store primary shiny texture
			typeData.textures.primaryShiny[curType] = primaryShinyTex
			
			-- Variable
			local secondaryShinyTex = textures["textures."..curType.."_shiny_e"] or textures["Eevee."..curType.."_shiny_e"]
			
			if secondaryShinyTex then
				
				-- Store secondary shiny texture
				typeData.textures.secondaryShiny[curType] = secondaryShinyTex
				
			end
			
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

-- Find capitalized version of type
function typeData:upperCase(s)
	
	return s:gsub("^%l", string.upper)
	
end

-- Return typeData
return typeData