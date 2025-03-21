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
	
	if typeData.tarString == "umbreon" then
		
		-- Variables
		local pos = player:getPos()
		local sky = world.getSkyLightLevel(pos)
		local time = world.getDayTime()
		local moon = world.getMoonPhase()
		
		-- Strengths
		local skyStr = sky / 15
		local timeStr = math.max(1 - math.abs((time - 18000) / 6000), 0)
		local moonStr = math.abs(1 - moon / 4)
		
		-- Set target
		glow.target = skyStr * timeStr * moonStr
		
	else
		
		-- Set target
		glow.target = 1
		
	end
	
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