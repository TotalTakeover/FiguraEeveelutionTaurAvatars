-- Kills script if squAPI cannot be found
local s, squapi = pcall(require, "lib.SquAPI")
if not s then return {} end

-- Required scripts
local parts    = require("lib.PartsAPI")
local typeData = require("scripts.TypeControl")
local lerp     = require("lib.LerpAPI")
local sync     = require("lib.LetThatSyncFig")
local ground   = require("lib.GroundCheck")
local pose     = require("scripts.Posing")
local effects  = require("scripts.SyncedVariables")

-- Synced variables setup
local earFlick = sync.new("AnimsEarFlicks", true):config()

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

-- Lerp table
local taurLerp = lerp.new(1)

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
	-- This is checking for espeons fur specifically
	if typeData.data.espeon and parts.group.EspeonHeadAccs then
		for _, v in ipairs(parts.group.EspeonHeadAccs:getChildren()) do
			if v:getName():find("Fur") then
				ears[v:getName():find("Left") and "left" or "right"].espeonFur = v
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
		0,                -- Range Multiplier (0)
		k:find("vaporeon") or
		k:find("espeon"), -- Horizontal (Based on type)
		2,                -- Bend Strength (2)
		earFlick.curr and not
		k:find("Fur"),    -- Do Flick (earFlick)
		400,              -- Flick Chance (400)
		0.1,              -- Stiffness (0.1)
		0.9               -- Bounce (0.9)
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
		0,    -- Intensity X (0)
		0,    -- Intensity Y (0)
		0,    -- Speed X (0)
		0,    -- Speed Y (0)
		2,    -- Bend (2)
		0,    -- Velocity Push (0)
		0,    -- Initial Offset (0)
		1,    -- Seg Offset (1)
		0.01, -- Stiffness (0.01)
		0.9,  -- Bounce (0.9)
		0,    -- Fly Offset (0)
		-25,  -- Down Limit (-25)
		25    -- Up Limit (25)
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

-- Squishy taur
local taur = squapi.taur:new(
	parts.group.LowerBody,
	parts.group.FrontLegs,
	parts.group.BackLegs
)

function events.TICK()
	
	-- Variable
	local onGround = ground()
	
	taur.target     = (onGround or player:getVehicle() or effects.cF) and 0 or taur.target
	taurLerp.target = not (typeData.getString() == "vaporeon" and player:isInWater() and (not onGround or pose.swim) and not pose.elytra) and 1 or 0
	
end

function events.RENDER(delta, context)
	
	-- Current type
	local currStr = typeData.getString()
	
	-- Offset smooth torso in various parts
	-- Note: acts strangely with `parts.group.body`
	for _, group in ipairs(parts.group.UpperBody:getChildren()) do
		if group ~= parts.group.Body then
			group:rot(-calculateParentRot(group:getParent()))
		end
	end
	
	-- Control tail activity
	for k, tail in pairs(squishyTails) do
		tail.enabled = k:find(currStr) and true or false
	end
	
	-- Control ear activity
	for k, ear in pairs(squishyEars) do
		ear.enabled = k:find(currStr) and true or false
		ear.doEarFlick = earFlick.curr and not k:find("Fur")
	end
	
	-- Control taur activity
	if taur.taurBody then
		taur.taurBody:rot(taur.taurBody:getRot() * taurLerp.currPos)
	end
	if taur.frontLegs then
		taur.frontLegs:rot(taur.frontLegs:getRot() * taurLerp.currPos)
	end
	if taur.backLegs then
		taur.backLegs:rot(taur.backLegs:getRot() * taurLerp.currPos)
	end
	
	-- Set upperbody to offset rot
	parts.group.UpperBody:rot(-parts.group.LowerBody:getRot())
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local s, wheel, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Anims") -- Tries to find script, not required

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
		:item("jukebox")
		:onLeftClick(function() wheel:descend(animsPage) end)
end

a.earsAct = animsPage:newAction()
	:item("bone")
	:toggleItem("feather")
	:onToggle(function(bool)
		earFlick:update(bool)
	end)
	:toggled(earFlick.curr)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if a.pageAct then
			a.pageAct
				:title(toJson(
					{text = "Animation Settings", bold = true, color = c.primary}
				))
		end
		
		a.earsAct
			:title(toJson(
				{
					"",
					{text = "Ear Flick Toggle\n\n", bold = true, color = c.primary},
					{text = "Toggles the ability for the ears to flick.", color = c.secondary}
				}
			))
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end