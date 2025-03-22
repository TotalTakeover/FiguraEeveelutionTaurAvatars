-- Required scripts
local parts    = require("lib.PartsAPI")
local origins  = require("lib.OriginsAPI")
local typeData = require("scripts.TypeControl")
local lerp     = require("lib.LerpAPI")
local effects  = require("scripts.SyncedVariables")

-- Config setup
config:name("EeveelutionTaur")
local toggle      = config:load("EyesToggle") or false
local power       = config:load("EyesPower") or false
local nightVision = config:load("EyesNightVision") or false

-- Glow Parts
local glowParts = parts:createTable(function(part) return part:getName():find("_[eE]ye[gG]low") end)

-- Eyes lerp
local eyesLerp = lerp:new(0.1, toggle and 1 or 0)

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
	
	for t, p in pairs(powers) do
		for k in pairs(p.active or {}) do
			local v = origins.getPowerData(player, k) or 0
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
	if toggle then
		
		-- Set target
		eyesLerp.target = 1
		
		-- Origins check
		if power then
			
			-- Variables
			local curType = typeData.curString
			local passive = 0
			local active = timer ~= 0 and 1 or 0
			local bar = 0
			
			if powers[curType] then
				
				-- Passives
				for k, v in pairs(powers[curType].passive or {}) do
					if v == "origins:water_vision" and not player:isUnderwater() then goto water end
					local value = origins.getPowerData(player, v) or 0
					if value == 1 then
						passive = 1
						goto stop
					end
					::water::
				end
				
				-- Actives
				for k, v in pairs(powers[curType].active or {}) do
					prevActives[k] = v
					powers[curType].active[k] = origins.getPowerData(player, k) or 0
					if powers[curType].active[k] ~= prevActives[k] then
						timer = 60
						goto stop
					end
				end
				
				-- Bar
				for k, v in pairs(powers[curType].bar or {}) do
					local data = origins.getPowerData(player, k) or 0
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
		if nightVision then
			eyesLerp.target = effects.nV and 1 or eyesLerp.target
		end
		
	else
		
		-- Set target
		eyesLerp.target = 0
		
	end
	
end

function events.RENDER(delta, context)
	
	-- Check render type
	local renderType = context == "RENDER" and "EMISSIVE" or "EYES"
	
	for _, part in ipairs(glowParts) do
		
		-- Apply
		part
			:secondaryColor(eyesLerp.currPos)
			:secondaryRenderType(renderType)
		
	end
	
end

-- Glowing eyes toggle
function pings.setEyesToggle(boolean)
	
	toggle = boolean
	config:save("EyesToggle", toggle)
	if player:isLoaded() and toggle then
		sounds:playSound("entity.glow_squid.ambient", player:getPos(), 0.75)
	end
	
end

-- Power toggle
function pings.setEyesPower(boolean)
	
	power = boolean
	config:save("EyesPower", power)
	if host:isHost() and player:isLoaded() and power then
		sounds:playSound("block.amethyst_block.chime", player:getPos())
	end
	
end

-- Night vision toggle
function pings.setEyesNightVision(boolean)
	
	nightVision = boolean
	config:save("EyesNightVision", nightVision)
	if host:isHost() and player:isLoaded() and nightVision then
		sounds:playSound("entity.generic.drink", player:getPos(), 0.35)
	end
	
end

-- Sync variable
function pings.syncEyes(a, b, c)
	
	toggle      = a
	power       = b
	nightVision = c
	
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
		pings.syncEyes(toggle, power, nightVision)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.toggleAct = action_wheel:newAction()
	:item(itemCheck("ender_pearl"))
	:toggleItem(itemCheck("ender_eye"))
	:onToggle(pings.setEyesToggle)

t.powerAct = action_wheel:newAction()
	:item(itemCheck("terracotta"))
	:onToggle(pings.setEyesPower)
	:toggled(power)

t.nightVisionAct = action_wheel:newAction()
	:item(itemCheck("glass_bottle"))
	:toggleItem(itemCheck("potion{CustomPotionColor:" .. tostring(0x96C54F) .. "}"))
	:onToggle(pings.setEyesNightVision)
	:toggled(nightVision)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.toggleAct
			:title(toJson
				{"",
				{text = "Toggle Glowing Eyes\n\n", bold = true, color = c.primary},
				{text = "Toggles the glowing of the eyes.\n\n", color = c.secondary},
				{text = "WARNING: ", bold = true, color = "dark_red"},
				{text = "This feature has a tendency to not work correctly.\nDue to the rendering properties of emissives, the eyes may not glow.\nIf it does not work, please reload the avatar. Rinse and Repeat.\nThis is the only fix, I have tried everything.\n\n- Total", color = "red"}}
			)
			:toggled(toggle)
		
		t.powerAct
			:title(toJson
				{"",
				{text = "Origins Power Toggle\n\n", bold = true, color = c.primary},
				{text = "Toggles the glowing based on various Origin powers.\nThe eyes will only glow when powers are activated.", color = c.secondary}}
			)
			:toggleItem(typeData.data[typeData.tarString].stone)
		
		t.nightVisionAct
			:title(toJson
				{"",
				{text = "Night Vision Toggle\n\n", bold = true, color = c.primary},
				{text = "Toggles the glowing based on having the Night Vision effect.\nThis setting will ", color = c.secondary},
				{text = "OVERRIDE ", bold = true, color = c.secondary},
				{text = "the other subsettings.", color = c.secondary}}
			)
		
		for _, act in pairs(t) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end

-- Return actions
return t