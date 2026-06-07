-- Required script
local typeData = require("scripts.TypeControl")

-- Play sound
function pings.playPokemonCry()
	
	if player:isLoaded() then
		sounds:playSound("cobblemon:pokemon."..typeData.getString()..".cry", player:getPos(), 0.5, math.random()*0.35+0.85)
	end
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required script
local keybound = require("lib.Keybound")

-- Variable
local cooldown = 0

-- Cooldown event
local function createCooldown()
	
	-- Set cooldown
	cooldown = 30
	
	-- Create event
	events.TICK:register(function()
		
		-- Decrease cooldown
		cooldown = math.max(cooldown - 1, 0)
		
		-- Remove tick event
		if cooldown == 0 then
			events.TICK:remove("CryCooldown")
		end
		
	end, "CryCooldown")
	
end

-- Setup keybind
local cryKeybind = keybound.new(
	keybinds
		:newKeybind("Pokemon Cry", "key.keyboard.keypad.2")
		:onPress(function()
			
			-- If player is dead, return early
			if player:getDeathTime() ~= 0 then return end
			
			-- If no cooldown, preform functions
			if cooldown == 0 then
				pings.playPokemonCry()
				createCooldown()
			end
			
		end),
	"CryKeybind"
)