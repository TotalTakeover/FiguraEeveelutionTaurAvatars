-- Table setup
local t = {
	nV = false,
	cF = false
}

-- Night vision check
local wasNV = t.nV
function pings.nVPing(boolean)
	
	t.nV = boolean
	
end

if host:isHost() then
	function events.TICK()
		
		t.nV = false
		for _, effect in ipairs(host:getStatusEffects()) do
			if effect.name == "effect.minecraft.night_vision" then
				t.nV = true
			end
		end
		if t.nV ~= wasNV then
			pings.nVPing(t.nV)
		end
		wasNV = t.nV
		
	end
end

-- Creative flight check
local wasCF = t.cF
function pings.cFPing(boolean)
	
	t.cF = boolean
	
end

if host:isHost() then
	function events.TICK()
		
		t.cF = host:isFlying()
		if t.cF ~= wasCF then
			pings.cFPing(t.cF)
		end
		wasCF = t.cF
		
	end
end

-- Returns variables
return t