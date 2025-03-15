-- Required scripts
local typeData = require("scripts.TypeControl")
local lerp     = require("lib.LerpAPI")

-- Kills script early if Umbreon couldnt be found in the types table
if not typeData.data["umbreon"] then return {} end

-- Glow lerp
local glow = lerp:new(0.1)

-- Glow Parts
local glowParts = {table.unpack(typeData.mainParts), table.unpack(typeData.data.umbreon.parts)}

-- Remove skull parts from table
for i = #glowParts, 1, -1 do
	if glowParts[i]:getName():find("Skull") then
		table.remove(glowParts, i)
	end
end

function events.TICK()
	
	glow.target = typeData.tarString == "umbreon" and math.map(world.getLightLevel(player:getPos()), 0, 15, 1, 0) or 1
	
end

function events.RENDER(delta, context)
	
	-- Check render type
	local renderType = context == "RENDER" and "EMISSIVE" or "EYES"
	
	for _, part in ipairs(glowParts) do
		
		-- Apply
		part
			:secondaryColor(glow.currPos)
			:secondaryRenderType(renderType)
		
	end
	
end