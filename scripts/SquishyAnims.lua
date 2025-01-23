-- Kills script if squAPI cannot be found
local s, squapi = pcall(require, "lib.SquAPI")
if not s then return {} end

-- Required scripts
local parts    = require("lib.PartsAPI")
local typeData = require("scripts.TypeControl")
local lerp     = require("lib.LerpAPI")
local pose     = require("scripts.Posing")

-- Config setup
config:name("EeveelutionTaur")
local earFlick = config:load("SquapiEarFlick")
local armsMove = config:load("SquapiArmsMove") or false
if earFlick == nil then earFlick = true end

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getOffsetRot()
	end
	return calculateParentRot(parent) + m:getOffsetRot()
	
end

-- Match group to type
local function matchType(n)
	
	local m = nil
	
	for _, t in ipairs(typeData.types) do
		local u = t:gsub("^%l", string.upper)
		if n:find(u) then
			m = t
			break
		end
	end
	
	return m
	
end

-- Lerp tables
local leftArmLerp  = lerp:new(0.5, armsMove and 1 or 0)
local rightArmLerp = lerp:new(0.5, armsMove and 1 or 0)

-- Find ears
local ears = {}
ears.left = {}
ears.right = {}
if parts.group.Ears then
	
	for _, group in ipairs(parts.group.Ears:getChildren()) do
		local dir = group:getName():find("Left") and "left" or "right"
		for _, v in ipairs(group:getChildren()) do
			local match = matchType(v:getName())
			if match then
				ears[dir][match] = v
			end
		end
	end
	
end

-- Setup squishy ears
-- Setup is based on left ear; if it's not found, it will not set it up
local squishyEars = {}
for k, ear in pairs(ears.left) do
	squishyEars[k] = squapi.ear:new(
		ear,
		ears.right[k],
		0.25, --(1) rangeMultiplier
		k == "vaporeon" or
		k == "espeon", --(false) horizontalEars
		2,    --(2) bendStrength
		earFlick, --(true) doEarFlick
		400,  --(400) earFlickChance
		0.1,  --(0.1) earStiffness
		0.9   --(0.8) earBounce
	)
end

-- Find tails
local tails = {}
if parts.group.Tails then
	
	for _, v in ipairs(parts.group.Tails:getChildren()) do
		local name = v:getName()
		local match = matchType(name)
		if match then
			tails[match] = parts:createChain(name)
		end
	end
	
end

-- Setup squishy tails
local squishyTails = {}
for k, tail in pairs(tails) do
	squishyTails[k] = squapi.tail:new(tail,
		10,   --(15) idleXMovement
		10,   --(5) idleYMovement
		0.8,  --(1.2) idleXSpeed
		1,    --(2) idleYSpeed
		2,    --(2) bendStrength
		0,    --(0) velocityPush
		0,    --(0) initialMovementOffset
		1,    --(1) offsetBetweenSegments
		0.01, --(.005) stiffness
		0.9,  --(.9) bounce
		nil,  --(90) flyingOffset
		nil,  --(-90) downLimit
		nil   --(45) upLimit
	)
end

-- Head table
local headParts = {
	
	parts.group.UpperBody
	
}

-- Squishy smooth torso
local head = squapi.smoothHead:new(
	headParts,
	0.3,  -- Strength (0.3)
	0.4,  -- Tilt (0.4)
	1,    -- Speed (1)
	false -- Keep Original Head Pos (false)
)

-- Squishy vanilla arms
local leftArm = squapi.arm:new(
	parts.group.LeftArm,
	1,     -- Strength (1)
	false, -- Right Arm (false)
	true   -- Keep Position (false)
)

local rightArm = squapi.arm:new(
	parts.group.RightArm,
	1,    -- Strength (1)
	true, -- Right Arm (true)
	true  -- Keep Position (false)
)

-- Arm strength variables
local leftArmStrength  = leftArm.strength
local rightArmStrength = rightArm.strength

function events.TICK()
	
	-- Arm variables
	local handedness  = player:isLeftHanded()
	local activeness  = player:getActiveHand()
	local leftActive  = not handedness and "OFF_HAND" or "MAIN_HAND"
	local rightActive = handedness and "OFF_HAND" or "MAIN_HAND"
	local leftSwing   = player:getSwingArm() == leftActive
	local rightSwing  = player:getSwingArm() == rightActive
	local leftItem    = player:getHeldItem(not handedness)
	local rightItem   = player:getHeldItem(handedness)
	local using       = player:isUsingItem()
	local usingL      = activeness == leftActive and leftItem:getUseAction() or "NONE"
	local usingR      = activeness == rightActive and rightItem:getUseAction() or "NONE"
	local bow         = using and (usingL == "BOW" or usingR == "BOW")
	local crossL      = leftItem.tag and leftItem.tag["Charged"] == 1
	local crossR      = rightItem.tag and rightItem.tag["Charged"] == 1
	
	-- Arm movement overrides
	local armShouldMove = pose.swim or pose.elytra or pose.crawl or pose.climb
	
	-- Control targets based on variables
	leftArmLerp.target  = (armsMove or armShouldMove or leftSwing  or bow or ((crossL or crossR) or (using and usingL ~= "NONE"))) and 1 or 0
	rightArmLerp.target = (armsMove or armShouldMove or rightSwing or bow or ((crossL or crossR) or (using and usingR ~= "NONE"))) and 1 or 0
	
end

function events.RENDER(delta, context)
	
	-- Variables
	local idleTimer   = world.getTime(delta)
	local idleRot     = vec(math.deg(math.sin(idleTimer * 0.067) * 0.05), 0, math.deg(math.cos(idleTimer * 0.09) * 0.05 + 0.05))
	local firstPerson = context == "FIRST_PERSON"
	
	-- Adjust arm strengths
	leftArm.strength  = leftArmStrength  * leftArmLerp.currPos
	rightArm.strength = rightArmStrength * rightArmLerp.currPos
	
	-- Adjust arm characteristics after applied by squapi
	parts.group.LeftArm
		:offsetRot(
			parts.group.LeftArm:getOffsetRot()
			+ ((-idleRot + (vanilla_model.BODY:getOriginRot() * 0.75)) * math.map(leftArmLerp.currPos, 0, 1, 1, 0))
			+ (parts.group.LeftArm:getAnimRot() * math.map(leftArmLerp.currPos, 0, 1, 0, -2))
		)
		:pos(parts.group.LeftArm:getPos() * vec(1, 1, -1))
		--:visible(not firstPerson)
	
	parts.group.RightArm
		:offsetRot(
			parts.group.RightArm:getOffsetRot()
			+ ((idleRot + (vanilla_model.BODY:getOriginRot() * 0.75)) * math.map(rightArmLerp.currPos, 0, 1, 1, 0))
			+ (parts.group.RightArm:getAnimRot() * math.map(rightArmLerp.currPos, 0, 1, 0, -2))
		)
		:pos(parts.group.RightArm:getPos() * vec(1, 1, -1))
		--:visible(not firstPerson)
	
	-- Set visible if in first person
	--parts.group.LeftArmFP:visible(firstPerson)
	--parts.group.RightArmFP:visible(firstPerson)
	
	-- Set upperbody to offset rot and crouching pivot point
	parts.group.UpperBody
		:rot(-parts.group.LowerBody:getRot())
		--:offsetPivot(anims.crouch:isPlaying() and -parts.group.UpperBody:getAnimPos() or 0)
	
	-- Offset smooth torso in various parts
	-- Note: acts strangely with `parts.group.body`
	for _, group in ipairs(parts.group.UpperBody:getChildren()) do
		if group ~= parts.group.Body then
			group:rot(-calculateParentRot(group:getParent()))
		end
	end
	
	-- Control tail activity
	for k, tail in pairs(squishyTails) do
		tail.enabled = k == typeData.curString
	end
	
	-- Control ear activity
	for k, ear in pairs(squishyEars) do
		ear.enabled = k == typeData.curString
		ear.doEarFlick = earFlick
	end
	
end

-- Ear flick toggle
function pings.setSquapiEarFlick(boolean)
	
	earFlick = boolean
	config:save("SquapiEarFlick", earFlick)
	
end

-- Arm movement toggle
function pings.setSquapiArmsMove(boolean)
	
	armsMove = boolean
	config:save("SquapiArmsMove", armsMove)
	
end

-- Sync variables
function pings.syncSquapi(a, b)
	
	earFlick = a
	armsMove = b
	
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
		pings.syncSquapi(earFlick, armsMove)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.earsAct = action_wheel:newAction()
	:item(itemCheck("bone"))
	:toggleItem(itemCheck("feather"))
	:onToggle(pings.setSquapiEarFlick)
	:toggled(earFlick)

t.armsAct = action_wheel:newAction()
	:item(itemCheck("red_dye"))
	:toggleItem(itemCheck("rabbit_foot"))
	:onToggle(pings.setSquapiArmsMove)
	:toggled(armsMove)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.earsAct
			:title(toJson(
				{
					"",
					{text = "Ear Flick Toggle\n\n", bold = true, color = c.primary},
					{text = "Toggles the ability for the ears to flick.", color = c.secondary}
				}
			))
		
		t.armsAct
			:title(toJson(
				{
					"",
					{text = "Arm Movement Toggle\n\n", bold = true, color = c.primary},
					{text = "Toggles the movement swing movement of the arms.\nActions are not effected.", color = c.secondary}
				}
			))
		
		for _, act in pairs(t) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end

-- Return actions
return t