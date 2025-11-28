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
local sprintLerp = lerp:new(1)

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
	local vel = player:getVelocity()
	local yaw = player:getBodyYaw()
	local dir = vec(math.sin(math.rad(-yaw)), 0, math.cos(math.rad(-yaw)))
	
	-- Directional velocity
	local fbVel = vel:dot((dir.x_z):normalized())
	local lrVel = vel:crossed(dir.x_z:normalized()).y
	local udVel = vel.y
	
	-- Animation speeds
	-- Ground Walk
	local walkSpeed = math.clamp((pose.climb and udVel or fbVel) * 6, -3, 3)
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
	
	-- Spyglass rotations
	local headRot = vanilla_model.HEAD:getOriginRot()
	headRot.x = math.clamp(headRot.x, -90, 30)
	parts.group.Spyglass:offsetRot(headRot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
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

-- Required scripts
local s, wheel, itemCheck, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Accessories") -- Tries to find script, not required

-- Check for if page already exists
local pageExists = action_wheel:getPage("Anims")

-- Pages
local parentPage = action_wheel:getPage("Main")
local animsPage  = pageExists or action_wheel:newPage("Anims")

-- Actions table setup
local a = {}

-- Actions
if not pageExists then
	a.pageAct = parentPage:newAction()
		:item(itemCheck("jukebox"))
		:onLeftClick(function() wheel:descend(animsPage) end)
end

a.sitAct = animsPage:newAction()
	:item(itemCheck("scaffolding"))
	:toggleItem(itemCheck("saddle"))
	:onToggle(pings.setAnimToggleSit)

a.lieAct = animsPage:newAction()
	:item(itemCheck("red_bed"))
	:toggleItem(itemCheck("saddle"))
	:onToggle(pings.setAnimToggleLying)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if a.pageAct then
			a.pageAct
				:title(toJson(
					{text = "Animation Settings", bold = true, color = c.primary}
				))
		end
		
		a.sitAct
			:title(toJson(
				{text = "Play Sit animation", bold = true, color = c.primary}
			))
			:toggled(anims.sit:isPlaying())
		
		a.lieAct
			:title(toJson(
				{text = "Play Lie Down animation", bold = true, color = c.primary}
			))
			:toggled(anims.lying:isPlaying())
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end