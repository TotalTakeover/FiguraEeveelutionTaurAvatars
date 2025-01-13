-- Required scripts
local parts    = require("lib.PartsAPI")
local typeData = require("scripts.EeveeType")

-- Variables
local _type = nil

-- Texture Swap Parts
local mainParts = parts:createTable(function(part) return part:getName():find("_Type") end)

-- Eevee Parts
local eeveeParts = {}
for _, v in ipairs(typeData.types) do
	eeveeParts[v] = parts:createTable(function(part) return part:getName():find(typeData:upperCase(v)) end)
end

function events.RENDER(delta, context)
	
	-- Enable parts based on type
	if _type ~= typeData.setType then
		
		-- Variables
		local primaryTex = textures["textures."..typeData.types[typeData.setType]] or textures["Eevee."..typeData.types[typeData.setType]]
		local secondaryTex = textures["textures."..typeData.types[typeData.setType].."_e"] or textures["Eevee."..typeData.types[typeData.setType].."_e"]
		
		for _, part in ipairs(mainParts) do
			
			-- Set Primary
			part:primaryTexture("CUSTOM", primaryTex)
			
			-- Set Secondary
			if secondaryTex then
				part:secondaryTexture("CUSTOM", secondaryTex)
			else
				part:secondaryTexture("SECONDARY")
			end
			
		end
		
		for k, v in pairs(eeveeParts) do
			
			local isVisible = typeData.types[typeData.setType] == k
			for _, part in ipairs(v) do
				
				part:visible(isVisible)
				
			end
			
		end
		
	end
	
	-- Store data
	_type = typeData.setType
	
end

-- Host only instructions
if not host:isHost() then return end