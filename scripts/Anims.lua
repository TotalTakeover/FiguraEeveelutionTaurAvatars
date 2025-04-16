-- Required scripts
require("lib.GSAnimBlend")
require("lib.Molang")
local typeData = require("scripts.TypeControl")
local parts    = require("lib.PartsAPI")
local ground   = require("lib.GroundCheck")
local lerp     = require("lib.LerpAPI")
local pose     = require("scripts.Posing")
local effects  = require("scripts.SyncedVariables")

-- Variable
local _type  = nil
local canAct = false
local canSit = false
local canLie = false

-- Sprint lerp
local sprintLerp = lerp:new(0.2, 1)

-- Animations setup
local anims = animations.EeveeTaur

-- Animation types
local typeAnims = {}
typeAnims.groundIdles   = {}
typeAnims.groundWalks   = {}
typeAnims.groundSprints = {}
for _, v in ipairs(typeData.types) do
	
	-- Store anims
	typeAnims.groundIdles[v]   = anims["groundIdle_"..v]
	typeAnims.groundWalks[v]   = anims["groundWalk_"..v]
	typeAnims.groundSprints[v] = anims["groundSprint_"..v]
	
end

-- Parrot pivots
local parrots = {
	
	parts.group.LeftParrotPivot,
	parts.group.RightParrotPivot
	
}

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getTrueRot()
	end
	return calculateParentRot(parent) + m:getTrueRot()
	
end

function events.TICK()
	
	-- Variables
	local vel       = player:getVelocity()
	local sprinting = player:isSprinting()
	local onGround  = ground()
	
	-- Check for type change
	if _type ~= typeData.curType then
		
		-- Stop all anims
		for _, animType in pairs(typeAnims) do
			for _, anim in pairs(animType) do
				anim:stop()
			end
		end
		
	end
	
	-- Animation states
	local vaporeonIdle = typeData.curString == "vaporeon" and player:isInWater() and not (onGround or pose.swim or pose.crawl)
	local vaporeonSwim = typeData.curString == "vaporeon" and pose.swim and not pose.crawl
	local groundIdle = not ((sprinting and not pose.swim) or vaporeonIdle or vaporeonSwim)
	local groundWalk = groundIdle and (vel.xz:length() ~= 0 or (pose.climb and vel:length() ~= 0)) and (onGround or pose.swim or pose.climb or effects.cF) and not (sprinting and not pose.swim or player:getVehicle())
	local groundSprint = sprinting and not (pose.swim or player:getVehicle())
	local isAct = anims.sit:isPlaying() or anims.lying:isPlaying()
	local ride  = player:getVehicle()
	local sleep = pose.sleep
	
	-- Animation actions
	canAct = pose.stand and not(vel:length() ~= 0 or player:getVehicle())
	canSit = canAct and (not isAct or anims.sit:isPlaying())
	canLie = canAct and (not isAct or anims.lying:isPlaying())
	
	-- Stop Sit animation
	if not canSit then
		anims.sit:stop()
	end
	
	-- Stop Lying animation
	if not canLie then
		anims.lying:stop()
	end
	
	-- Animations
	-- Ground Idle
	anims.groundIdle:playing(groundIdle)
	if typeAnims.groundIdles[typeData.curString] then
		typeAnims.groundIdles[typeData.curString]:playing(groundIdle):setTime(anims.groundIdle:getTime())
	end
	
	-- Ground Walk
	anims.groundWalk:playing(groundWalk)
	if typeAnims.groundWalks[typeData.curString] then
		typeAnims.groundWalks[typeData.curString]:playing(groundWalk):setTime(anims.groundWalk:getTime())
	end
	
	-- Ground Sprint
	anims.groundSprint:playing(groundSprint)
	if typeAnims.groundSprints[typeData.curString] then
		typeAnims.groundSprints[typeData.curString]:playing(groundSprint):setTime(anims.groundSprint:getTime())
	end
	
	if typeData.data["vaporeon"] then
		anims.waterIdle:playing(vaporeonIdle)
		anims.waterSwim:playing(vaporeonSwim)
	end
	
	anims.ride:playing(ride)
	anims.sleep:playing(sleep)
	
	-- Set targets
	sprintLerp.target = (onGround or effects.cF) and 1 or 0
	
	-- Store data
	_type = typeData.curType
	
end

function events.RENDER(delta, context)
	
	-- Variables
	local vel = player:getVelocity(delta)
	local dir = player:getLookDir()
	
	-- Directional velocity
	local fbVel = player:getVelocity():dot((dir.x_z):normalize())
	local lrVel = player:getVelocity():cross(dir.x_z:normalize()).y
	
	-- Animation speeds
	-- Ground Walk
	local walkSpeed = math.clamp(pose.climb and vel:length() * 6 or fbVel < -0.05 and math.min(fbVel, math.abs(lrVel)) * 6 or math.max(fbVel, math.abs(lrVel)) * 6, -3, 3)
	anims.groundWalk:speed(walkSpeed)
	if typeAnims.groundWalks[typeData.curString] then
		typeAnims.groundWalks[typeData.curString]:speed(walkSpeed)
	end
	-- Ground Sprint
	local sprintSpeed = math.min(vel.xz:length() + 1, 2)
	anims.groundSprint:speed(sprintSpeed)
	if typeAnims.groundSprints[typeData.curString] then
		typeAnims.groundSprints[typeData.curString]:speed(sprintSpeed)
	end
	-- Swim
	if typeData.curString == "vaporeon" then
		anims.waterIdle:speed(math.min(1 + vel:length() * 3, 1.5))
		anims.waterSwim:speed(math.min(vel:length() * 3, 2))
	end
	
	-- Animation blending
	anims.groundSprint:blend(sprintLerp.currPos)
	
	-- Parrot rot offset
	for _, parrot in pairs(parrots) do
		parrot:rot(-calculateParentRot(parrot:getParent()) - vanilla_model.BODY:getOriginRot())
	end
	
	-- Crouch offset
	local bodyRot = vanilla_model.BODY:getOriginRot(delta)
	local crouchPos = vec(0, -math.sin(math.rad(bodyRot.x)) * 2, -math.sin(math.rad(bodyRot.x)) * 12)
	parts.group.UpperBody:offsetPivot(crouchPos):pos(crouchPos.xy_ * 2)
	parts.group.LowerTorso:pos(crouchPos)
	
end

-- GS Blending Setup
local blendAnims = {
	{ anim = anims.groundIdle,        ticks = {7,7}  },
	{ anim = typeAnims.groundIdles,   ticks = {7,7}  },
	{ anim = anims.groundWalk,        ticks = {3,7}  },
	{ anim = typeAnims.groundWalks,   ticks = {3,7}  },
	{ anim = anims.groundSprint,      ticks = {3,7}  },
	{ anim = typeAnims.groundSprints, ticks = {3,7}  },
	{ anim = anims.waterIdle,         ticks = {7,7}  },
	{ anim = anims.waterSwim,         ticks = {7,7}  },
	{ anim = anims.ride,              ticks = {7,7}  },
	{ anim = anims.sit,               ticks = {14,7} },
	{ anim = anims.lying,             ticks = {14,7} }
}

-- Apply GS Blending
for _, blend in ipairs(blendAnims) do
	if blend.anim ~= nil then
		if type(blend.anim) ~= "table" then
			blend.anim = {blend.anim}
		end
		for _, anim in pairs(blend.anim) do
			anim:blendTime(table.unpack(blend.ticks)):blendCurve("easeOutQuad")
		end
	end
end

-- Fixing spyglass jank
function events.RENDER(delta, context)
	
	local rot = vanilla_model.HEAD:getOriginRot()
	rot.x = math.clamp(rot.x, -90, 30)
	parts.group.Spyglass:offsetRot(rot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
end

-- Play sit anim
function pings.setAnimToggleSit(boolean)
	
	anims.sit:playing(canSit and boolean)
	
end

-- Play lying anim
function pings.setAnimToggleLying(boolean)
	
	anims.lying:playing(canLie and boolean)
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local s, c = pcall(require, "scripts.ColorProperties")
if not s then c = {} end

-- Sit keybind
local sitBind   = config:load("AnimSitKeybind") or "key.keyboard.keypad.3"
local setSitKey = keybinds:newKeybind("Sit Animation"):onPress(function() pings.setAnimToggleSit(not anims.sit:isPlaying()) end):key(sitBind)

-- Lie keybind
local lieBind   = config:load("AnimLieKeybind") or "key.keyboard.keypad.4"
local setLieKey = keybinds:newKeybind("Lie Down Animation"):onPress(function() pings.setAnimToggleLying(not anims.lying:isPlaying()) end):key(lieBind)

-- Keybind updaters
function events.TICK()
	
	local sitKey = setSitKey:getKey()
	local lieKey = setLieKey:getKey()
	if sitKey ~= sitBind then
		sitBind = sitKey
		config:save("AnimSitKeybind", sitKey)
	end
	if lieKey ~= lieBind then
		lieBind = lieKey
		config:save("AnimLieKeybind", lieKey)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.sitAct = action_wheel:newAction()
	:item(itemCheck("scaffolding"))
	:toggleItem(itemCheck("saddle"))
	:onToggle(pings.setAnimToggleSit)

t.lieAct = action_wheel:newAction()
	:item(itemCheck("red_bed"))
	:toggleItem(itemCheck("saddle"))
	:onToggle(pings.setAnimToggleLying)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.sitAct
			:title(toJson(
				{text = "Play Sit animation", bold = true, color = c.primary}
			))
			:toggled(anims.sit:isPlaying())
		
		t.lieAct
			:title(toJson(
				{text = "Play Lie Down animation", bold = true, color = c.primary}
			))
			:toggled(anims.lying:isPlaying())
		
		for _, act in pairs(t) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end

-- Returns actions
return t