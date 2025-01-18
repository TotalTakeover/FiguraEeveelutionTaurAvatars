-- Required scripts
local parts = require("lib.PartsAPI")
local typeData = require("scripts.TypeControl")

function events.ON_PLAY_SOUND(id, pos, vol, pitch, loop, cat, path)
	
	-- Don't trigger if the sound was played by Figura (prevent potential infinite loop)
	if not path then return end
	
	-- Don't do anything if the user isn't loaded
	if not player:isLoaded() then return end
	
	-- Make sure the sound is (most likely) played by the user
	if (player:getPos() - pos):length() > 0.05 then return end
	
	-- If sound contains ".hurt", play an additional hurt sound along side it
	if id:find(".hurt") then
		local scale = parts.group.Player:getAnimScale():lengthSquared() / 3
		return sounds:playSound("cobblemon:"..(scale > 0.5 and "pokemon."..typeData.curString..".cry" or "poke_ball.open"), pos, 0.6)
	end
	
end