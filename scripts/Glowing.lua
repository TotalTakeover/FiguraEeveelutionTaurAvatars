-- Required scripts
local parts    = require("lib.PartsAPI")
local typeData = require("scripts.TypeControl")
local lerp     = require("lib.LerpAPI")
local sync     = require("lib.LetThatSyncFig")
local origins  = require("lib.OriginsAPI")

-- Synced variables setup
local toggle  = sync.new("GlowToggle", true):config()
local special = sync.new("GlowSpecial", true):config()

-- Glow Parts
local glowParts = parts:createTable(function(part) return part:getName():find("_[gG]low") end)

-- Glow lerp
local glowLerp = lerp.new(toggle.curr and 1 or 0, 0.1)

function events.TICK()
	
	-- Set glow target
	-- Toggle check
	if toggle.curr then
		
		-- Set target
		glowLerp.target = 1
		
		-- Kill event if not using special characteristics
		if not special.curr then return end
		
		-- Variables
		local currStr = typeData.getString()
		local pos = player:getPos()
		local sky = world.getSkyLightLevel(pos)
		local time = world.getDayTime()
		local moon = world.getMoonPhase()
		
		if currStr == "espeon" then
			
			-- Strengths
			local skyStr = sky / 15
			local timeStr = math.max(1 - math.abs((time - 6000) / 6000), 0)
			
			-- Set target
			glowLerp.target = math.max(origins.getPowerData(player)["eeveelutiontaurs:sixth_sense_toggle"] or 0, skyStr * timeStr)
			
		elseif currStr == "umbreon" then
			
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

-- Apply sound function
toggle:applyFunc(function()
	if player:isLoaded() and toggle.curr then
		sounds:playSound("entity.glow_squid.ambient", player:getPos(), 0.75)
	end
end)

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local s, pageNav, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Pokeball") -- Tries to find script, not required

-- Pages
local parentPage = action_wheel:getPage("Main")
local glowPage   = action_wheel:newPage("Glow")

-- Actions table setup
local a = {}

-- Actions
a.pageAct = parentPage:newAction()
	:item("glow_ink_sac")
	:onLeftClick(function() pageNav.descend(glowPage) end)

a.toggleAct = glowPage:newAction()
	:item("ink_sac")
	:toggleItem("glow_ink_sac")
	:onToggle(function(bool)
		toggle:update(bool)
	end)
	:toggled(toggle.curr)

a.specialAct = glowPage:newAction()
	:item("amethyst_shard")
	:toggleItem("amethyst_cluster")
	:onToggle(function(bool)
		special:update(bool)
	end)
	:toggled(special.curr)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		a.pageAct
			:title(toJson(
				{text = "Glowing Settings", bold = true, color = c.primary}
			))
		
		a.toggleAct
			:title(toJson(
				{
					"",
					{text = "Toggle Glowing\n\n", bold = true, color = c.primary},
					{text = "Toggles glowing for specific parts, mainly those related to Espeon and Umbreon.\n\n", color = c.secondary},
					{text = "WARNING: ", bold = true, color = "dark_red"},
					{text = "This feature has a tendency to not work correctly.\nDue to the rendering properties of emissives, parts may not glow.\nIf it does not work, please reload the avatar. Rinse and Repeat.\nThis is the only fix, I have tried everything.\n\n- Total", color = "red"}
				}
			))
		
		a.specialAct
			:title(toJson(
				{
					"",
					{text = "Toggle Special Glowing\n\n", bold = true, color = c.primary},
					{text = "Toggles glowing to have special properties.\nGlowing will react to specific situations!", color = c.secondary}
				}
			))
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end