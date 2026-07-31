-- Required scripts
local parts    = require("lib.PartsAPI")
local typeData = require("scripts.TypeControl")
local lerp     = require("lib.LerpAPI")
local sync     = require("lib.LetThatSyncFig")
local origins  = require("lib.OriginsAPI")
local effects  = require("scripts.SyncedVariables")

-- Synced variables setup
local toggle      = sync.new("EyesToggle", false):config()
local power       = sync.new("EyesPower", false):config()
local nightVision = sync.new("EyesNightVision", false):config()

-- Glow Parts
local glowParts = parts:createTable(function(part) return part:getName():find("_[eE]ye[gG]low") end)

-- Eyes lerp
local eyesLerp = lerp.new(toggle.curr and 1 or 0, 0.1)

--[[
	Power tables:
	This is a list of powers that can control glowing eyes if allowed:
	"passive" refers to powers that toggle glowing (can have multiple)
	"active" refers to powers that activate glowing for 3 seconds (can have multiple)
	"bar" refers to how full the guage is for the origin (ONLY ONE)
--]]
local powers = {
	vaporeon = {
		passive = {"origins:water_vision"},
		active = {["eeveelutiontaurs:aqua_ring"] = 0}
		-- bar felt too "significant" to include, want other powers to shine :)
	},
	jolteon = {
		active = {["eeveelutiontaurs:thunder_wave"] = 0},
		bar = {["eeveelutiontaurs:static_bar"] = 350}
	},
	flareon = {
		active = {["eeveelutiontaurs:flame_pouch_breathe_fire"] = 0},
		bar = {["eeveelutiontaurs:flame_pouch_bar"] = 100}
	},
	espeon = {
		passive = {"eeveelutiontaurs:sixth_sense_toggle"}
	},
	umbreon = {
		passive = {"eeveelutiontaurs:piercing_vision_toggle"}
	},
	leafeon = {
		active = {["eeveelutiontaurs:leech_seed"] = 0}
	},
	glaceon = {
		passive = {"eeveelutiontaurs:cold_feet_toggle"},
		active = {["eeveelutiontaurs:triple_axel"] = 0}
	},
	sylveon = {
		active = {["eeveelutiontaurs:moonblast"] = 0}
	}
}

-- Store previous origins data
local prevActives = {}
function events.ENTITY_INIT()
	
	-- Power data
	local powerData = origins.getPowerData(player)
	
	for t, p in pairs(powers) do
		for k in pairs(p.active or {}) do
			local v = powerData[k] or 0
			powers[t].active[k] = v
			prevActives[k] = v
		end
	end
	
end

-- Variable
local timer = 0

function events.TICK()
	
	-- Set glow target
	-- Toggle check
	if toggle.curr then
		
		-- Set target
		eyesLerp.target = 1
		
		-- Origins check
		if power.curr then
			
			-- Variables
			local currStr = typeData.getString()
			local powerData = origins.getPowerData(player)
			local passive = 0
			local active = timer ~= 0 and 1 or 0
			local bar = 0
			
			if powers[currStr] then
				
				-- Passives
				for k, v in pairs(powers[currStr].passive or {}) do
					if v == "origins:water_vision" and not player:isUnderwater() then goto water end
					local value = powerData[v] or 0
					if value == 1 then
						passive = 1
						goto stop
					end
					::water::
				end
				
				-- Actives
				for k, v in pairs(powers[currStr].active or {}) do
					prevActives[k] = v
					powers[currStr].active[k] = powerData[k] or 0
					if powers[currStr].active[k] ~= prevActives[k] then
						timer = 60
						goto stop
					end
				end
				
				-- Bar
				for k, v in pairs(powers[currStr].bar or {}) do
					local data = powerData[k] or 0
					bar = data / v
				end
				
			end
			
			-- Skip instructions if checking is no longer needed
			::stop::
			
			-- Count down timer
			if timer > 0 then
				timer = timer - 1
			end
			
			-- Set target
			eyesLerp.target = math.max(passive, active, bar)
			
		end
		
		-- Night Vision check
		if nightVision.curr then
			eyesLerp.target = effects.nV and 1 or eyesLerp.target
		end
		
	else
		
		eyesLerp.target = 0
		
	end
	
end

function events.RENDER(delta, context)
	
	-- Apply
	local renderType = context == "RENDER" and "EMISSIVE" or "EYES"
	for _, part in ipairs(glowParts) do
		part
			:secondaryColor(eyesLerp.currPos)
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

-- Apply sound functions
power:applyFunc(function()
	if player:isLoaded() and power.curr then
		sounds:playSound("block.amethyst_block.chime", player:getPos())
	end
end)
nightVision:applyFunc(function()
	if player:isLoaded() and nightVision.curr then
		sounds:playSound("entity.generic.drink", player:getPos(), 0.35)
	end
end)

-- Required script
local keybound = require("lib.Keybound")

-- Setup keybind
local toggleKeybind = keybound.new(
	keybinds
		:newKeybind("Glowing Eyes Toggle", "key.keyboard.keypad.5")
		:onPress(function() toggle:update(not toggle.curr) end),
	"EyesToggleKeybind"
)

-- Required scripts
local s, pageNav, acts, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Glowing") -- Tries to find script, not required

-- Pages
local parentPage = action_wheel:getPage("Glow") or action_wheel:getPage("Main")
local glowEyesPage = action_wheel:newPage("GlowEyes")

-- Actions
acts.glowEyesPage = parentPage:newAction()
	:item("ender_eye")
	:onLeftClick(function() pageNav.descend(glowEyesPage) end)

acts.glowEyesToggle = glowEyesPage:newAction()
	:item("ender_pearl")
	:toggleItem("ender_eye")
	:onToggle(function(bool)
		toggle:update(bool)
	end)

acts.glowEyesPower = glowEyesPage:newAction()
	:item("terracotta")
	:onToggle(function(bool)
		power:update(bool)
	end)
	:toggled(power.curr)

acts.glowEyesNightVision = glowEyesPage:newAction()
	:item("glass_bottle")
	:toggleItem("potion{CustomPotionColor:" .. tostring(0x96C54F) .. "}")
	:onToggle(function(bool)
		nightVision:update(bool)
	end)
	:toggled(nightVision.curr)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		acts.glowEyesPage
			:title(toJson(
				{text = "Glowing Eyes Settings", bold = true, color = c.primary}
			))
			:hoverColor(c.hover)
		
		acts.glowEyesToggle
			:title(toJson(
				{
					"",
					{text = "Toggle Glowing Eyes\n\n", bold = true, color = c.primary},
					{text = "Toggles the glowing of the eyes.\n\n", color = c.secondary},
					{text = "WARNING: ", bold = true, color = "dark_red"},
					{text = "This feature has a tendency to not work correctly.\nDue to the rendering properties of emissives, the eyes may not glow.\nIf it does not work, please reload the avatar. Rinse and Repeat.\nThis is the only fix, I have tried everything.\n\n- Total", color = "red"}
				}
			))
			:toggled(toggle.curr)
			:hoverColor(c.hover)
			:toggleColor(c.active)
		
		acts.glowEyesPower
			:title(toJson(
				{
					"",
					{text = "Origins Power Toggle\n\n", bold = true, color = c.primary},
					{text = "Toggles the glowing based on various Origin powers.\nThe eyes will only glow when powers are activated.", color = c.secondary}
				}
			))
			:toggleItem(typeData.data[typeData.getString()].stone)
			:hoverColor(c.hover)
			:toggleColor(c.active)
		
		acts.glowEyesNightVision
			:title(toJson(
				{
					"",
					{text = "Night Vision Toggle\n\n", bold = true, color = c.primary},
					{text = "Toggles the glowing based on having the Night Vision effect.\nThis setting will ", color = c.secondary},
					{text = "OVERRIDE ", bold = true, color = c.secondary},
					{text = "the other subsettings.", color = c.secondary}
				}
			))
			:hoverColor(c.hover)
			:toggleColor(c.active)
		
	end
	
end