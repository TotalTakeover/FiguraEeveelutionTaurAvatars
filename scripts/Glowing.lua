-- Required scripts
local parts     = require("lib.PartsAPI")
local originAPI = require("lib.OriginsAPI")
local typeData  = require("scripts.TypeControl")
local lerp      = require("lib.LerpAPI")

-- Config setup
config:name("EeveelutionTaur")
local toggle  = config:load("GlowToggle")
local special = config:load("GlowSpecial")
if toggle  == nil then toggle  = true end
if special == nil then special = true end

-- Glow Parts
local glowParts = parts:createTable(function(part) return part:getName():find("_[gG]low") end)

-- Glow lerp
local glowLerp = lerp:new(0.1)

function events.TICK()
	
	-- Set glow target
	-- Toggle check
	if toggle then
		
		-- Set target
		glowLerp.target = 1
		
		-- Kill event if not using special characteristics
		if not special then return end
		
		-- Variables
		local curType = typeData.curString
		local pos = player:getPos()
		local sky = world.getSkyLightLevel(pos)
		local time = world.getDayTime()
		local moon = world.getMoonPhase()
		
		if curType == "espeon" then
			
			-- Strengths
			local skyStr = sky / 15
			local timeStr = math.max(1 - math.abs((time - 6000) / 6000), 0)
			
			-- Set target
			glowLerp.target = math.max(originAPI.getPowerData(player, "eeveelutiontaurs:sixth_sense_toggle") or 0, skyStr * timeStr)
			
		elseif curType == "umbreon" then
			
			-- Strengths
			local skyStr = sky / 15
			local timeStr = math.max(1 - math.abs((time - 18000) / 6000), 0)
			local moonStr = math.abs(1 - moon / 4)
			
			-- Set target
			glowLerp.target = skyStr * timeStr * moonStr
			
		end
		
	else
		
		-- Set target
		glowLerp.target = 0
		
	end
	
end

function events.RENDER(delta, context)
	
	-- Check render type
	local renderType = context == "RENDER" and "EMISSIVE" or "EYES"
	
	for _, part in ipairs(glowParts) do
		
		-- Apply
		part
			:secondaryColor(glowLerp.currPos)
			:secondaryRenderType(renderType)
		
	end
	
end

-- Glow toggle
function pings.setGlowToggle(boolean)
	
	toggle = boolean
	config:save("GlowToggle", toggle)
	if player:isLoaded() and toggle then
		sounds:playSound("entity.glow_squid.ambient", player:getPos(), 0.75)
	end
	
end

-- Special toggle
function pings.setGlowSpecial(boolean)
	
	special = boolean
	config:save("GlowSpecial", special)
	
end

-- Sync variables
function pings.syncGlow(a, b)
	
	toggle  = a
	special = b
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local s, c = pcall(require, "scripts.ColorProperties")
if not s then c = {} end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncGlow(toggle, special)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.toggleAct = action_wheel:newAction()
	:item(itemCheck("ink_sac"))
	:toggleItem(itemCheck("glow_ink_sac"))
	:onToggle(pings.setGlowToggle)
	:toggled(toggle)

t.specialAct = action_wheel:newAction()
	:item(itemCheck("amethyst_shard"))
	:toggleItem(itemCheck("amethyst_cluster"))
	:onToggle(pings.setGlowSpecial)
	:toggled(special)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.toggleAct
			:title(toJson(
				{
					"",
					{text = "Toggle Glowing\n\n", bold = true, color = c.primary},
					{text = "Toggles glowing for specific parts, mainly those related to Espeon and Umbreon.\n\n", color = c.secondary},
					{text = "WARNING: ", bold = true, color = "dark_red"},
					{text = "This feature has a tendency to not work correctly.\nDue to the rendering properties of emissives, parts may not glow.\nIf it does not work, please reload the avatar. Rinse and Repeat.\nThis is the only fix, I have tried everything.\n\n- Total", color = "red"}
				}
			))
			:toggled(toggle)
		
		t.specialAct
			:title(toJson(
				{
					"",
					{text = "Toggle Special Glowing\n\n", bold = true, color = c.primary},
					{text = "Toggles glowing to have special properties.\nGlowing will react to specific situations!", color = c.secondary}
				}
			))
		
		for _, act in pairs(t) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end

-- Return actions
return t