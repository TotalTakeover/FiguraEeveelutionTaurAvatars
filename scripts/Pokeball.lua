-- Required scripts
local parts    = require("lib.PartsAPI")
local typeData = require("scripts.TypeControl")
local sync     = require("lib.LetThatSyncFig")

-- Pokeball part
local pokeBall = parts.group.PokeBall

-- Kills script if it cannot find pokeBall
if not pokeBall then return {} end

-- Animation setup
local anims = animations.EeveeTaur
local openAnim  = anims.pokeballOpen
local closeAnim = anims.pokeballClose

-- Synced variables setup
local toggle   = sync.new("PokeballToggle", false):config()
local typeHide = sync.new("PokeballTypeHide", true):config()

-- Variables
local isInBall  = toggle.curr
local wasInBall = toggle.curr
local staticYaw = 0

-- Play pokeball sound
local function pokeballSound(state)
	
	if player:isLoaded() then
		sounds:playSound("cobblemon:poke_ball."..(state and "recall" or "send_out"), player:getPos(), 0.25)
	end
	
end

-- Deep copy
local function deepCopy(model)
	local copy = model:copy(model:getName().."Copy")
	for _, child in pairs(copy:getChildren()) do
		copy:removeChild(child):addChild(deepCopy(child))
	end
	return copy
end

-- Deep copy animations
local function deepAnim(model, original)
	local pos, rot, scale = original:getAnimPos(), original:getAnimRot(), original:getAnimScale()
	model:pos(pos):offsetRot(rot):scale(scale)
	for i, child in pairs(model:getChildren()) do
		if child:getType() == "GROUP" then
			deepAnim(child, original:getChildren()[i])
		end
	end
end

-- Play an animation based on toggle
do
	
	-- Start with an animation
	local startAnim = toggle.curr and closeAnim or openAnim
	startAnim:play()
	
	-- Set each pokeball animation to be at the end of their length
	openAnim:time(openAnim:getLength())
	closeAnim:time(closeAnim:getLength())
	
end

-- Model variables
local worldPart = models:newPart("world", "WORLD")
local worldBall = deepCopy(parts.group.PokeBall)

-- Set pokeball copy to world
worldPart:addChild(worldBall)

function events.ENTITY_INIT()
	
	staticYaw = -player:getBodyYaw() + 180
	
end

function events.RENDER(delta, context)
	
	-- Variables
	local hasRider = #player:getPassengers() > 0
	local menu = context == "FIGURA_GUI" or context == "MINECRAFT_GUI" or context == "PAPERDOLL"
	
	-- Pokeball state
	isInBall = (typeData.swapping or toggle.curr) and not hasRider
	
	-- Activate pokeball
	if isInBall ~= wasInBall then
		
		openAnim:playing(not isInBall)
		closeAnim:playing(isInBall)
		
		pokeballSound(isInBall)
		
		-- Set pokeball rotation
		if isInBall then 
			staticYaw = -player:getBodyYaw(delta) + 180
		end
		
	end
	
	-- Copy animations from original
	deepAnim(worldBall, parts.group.PokeBall)
	
	-- Apply
	parts.group.PokeBall
		:visible(menu)
		:offsetRot(0, 0, 0)
	worldBall
		:pos(worldBall:getPos() + player:getPos(delta) * 16)
		:offsetRot(worldBall:getOffsetRot() + vec(0, staticYaw, 0))
		:visible(not renderer:isFirstPerson())
		:light(world.getLightLevel(player:getPos(delta) + vec(0, 0.5, 0)))
	
	-- Determine color based on player scale
	local pokeColor = parts.group.Player:getAnimScale():lengthSquared() / 3
	
	-- Apply Color
	parts.group.Player:color(1, pokeColor, pokeColor)
	
	-- Store last state
	wasInBall = isInBall
	
end

-- Modifies the update function to allow the player to enter their pokeball before changing types
local prevUpdateAll = typeData.updateAll
function typeData.updateAll()
	
	if typeHide.curr then
		
		-- Check if player is already in the ball, and do a fast swap in place
		if toggle.curr and parts.group.Player:getAnimScale():length() == 0 then
			
			prevUpdateAll()
			return
			
		end
		
		-- Variables
		local timer = 0
		local _type = typeData.type.curr
		typeData.swapping = true
		
		-- Create new tick event
		events.TICK:register(function()
			
			if _type ~= typeData.type.curr then
				
				timer = 0
				
			elseif parts.group.Player:getAnimScale():length() == 0 then
				
				timer = timer + 1
				
			end
			
			if timer >= 10 then
				
				prevUpdateAll()
				typeData.swapping = false
				events.TICK:remove("PokeballTypeHide")
				
			end
			
			-- Store last state
			_type = typeData.type.curr
			
		end, "PokeballTypeHide")
		
	else
		
		prevUpdateAll()
		
	end
	
end

-- Bob animations
local bobs = {}
for _, child in ipairs(animations:getAnimations()) do
	if child:getName():find("pokeballBob") then
		table.insert(bobs, child)
	end
end

-- Pokeball bob
function pings.playPokeballBob(x)
	
	bobs[x]:play()
	
	if player:isLoaded() then
		sounds:playSound("cobblemon:poke_ball.shake", player:getPos(), 0.35)
	end
	
end

-- Pokeball bounce
function pings.playPokeballBounce()
	
	anims.pokeballBounce:play()
	
	if player:isLoaded() then
		sounds:playSound("cobblemon:poke_ball.shake", player:getPos(), 0.35)
	end
	
end

-- Pokeball interact
function pings.playPokeballInteract()
	
	anims.pokeballInteract:restart()
	
	if player:isLoaded() then
		sounds:playSound("cobblemon:poke_ball.capture_succeeded", player:getPos(), 0.35)
	end
	
end

-- Host only instructions
if not host:isHost() then return end

-- Check if any bob animations are playing
local function checkBob()
	
	local playing = false
	
	if #bobs == 0 then return true end
	
	for _, bob in ipairs(bobs) do
		if bob:isPlaying() then
			playing = true
			break
		end
	end
	
	return playing
	
end

-- If animations both animations are done playing, allow the switching of animations
local function checkToggle()
	return openAnim:getTime() == openAnim:getLength() and closeAnim:getTime() == closeAnim:getLength()
end

-- Required script
local keybound = require("lib.Keybound")

-- Setup keybind
local toggleKeybind = keybound.new(
	keybinds
		:newKeybind("Pokeball Toggle", "key.keyboard.keypad.1")
		:onPress(function() if checkToggle() then toggle:update(not toggle.curr) end end),
	"PokeballToggleKeybind"
)

-- Movement/Action keybinds
--[[
	This section is old code I'm afraid to touch, I plan on swapping it out for something better eventually.
	For now, admire the foundation of what will eventually be not.
--]]
local setForwardKey = keybinds:newKeybind("Pokeball Forward Animation"):onPress(function() if not checkBob() then pings.playPokeballBob(math.random(1,#bobs)) end return true end)
local setBackKey    = keybinds:newKeybind("Pokeball Back Animation")   :onPress(function() if not checkBob() then pings.playPokeballBob(math.random(1,#bobs)) end return true end)
local setLeftKey    = keybinds:newKeybind("Pokeball Left Animation")   :onPress(function() if not checkBob() then pings.playPokeballBob(math.random(1,#bobs)) end return true end)
local setRightKey   = keybinds:newKeybind("Pokeball Right Animation")  :onPress(function() if not checkBob() then pings.playPokeballBob(math.random(1,#bobs)) end return true end)
local setJumpKey    = keybinds:newKeybind("Pokeball Jump Animation")   :onPress(function() if not anims.pokeballBounce:isPlaying() then pings.playPokeballBounce() end return true end)
local setCrouchKey  = keybinds:newKeybind("Pokeball Crouch Animation") :onPress(function() return true end)
local setAttackKey  = keybinds:newKeybind("Pokeball Attack Animation") :onPress(function() if not action_wheel:isEnabled() then pings.playPokeballInteract() end return true end)
local setUseKey     = keybinds:newKeybind("Pokeball Use Animation")    :onPress(function() if not action_wheel:isEnabled() then pings.playPokeballInteract() end return true end)

-- Keybind updaters
function events.TICK()
	
	-- Force keybinds
	setForwardKey:key(keybinds:getVanillaKey("key.forward")):enabled(isInBall)
	setBackKey   :key(keybinds:getVanillaKey("key.back"))   :enabled(isInBall)
	setLeftKey   :key(keybinds:getVanillaKey("key.left"))   :enabled(isInBall)
	setRightKey  :key(keybinds:getVanillaKey("key.right"))  :enabled(isInBall)
	setJumpKey   :key(keybinds:getVanillaKey("key.jump"))   :enabled(isInBall)
	setCrouchKey :key(keybinds:getVanillaKey("key.sneak"))  :enabled(isInBall)
	setAttackKey :key(keybinds:getVanillaKey("key.attack")) :enabled(isInBall)
	setUseKey    :key(keybinds:getVanillaKey("key.use"))    :enabled(isInBall)
	
end

-- Required script
local s, pageNav, acts, colors = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found

-- Check for if page already exists
local pageExists = action_wheel:getPage("Eeveelution")

-- Pages
local parentPage      = action_wheel:getPage("Main")
local eeveelutionPage = pageExists or action_wheel:newPage("Eeveelution")

-- Actions
if not pageExists then
	acts.eeveePage = parentPage:newAction()
		:item("cobblemon:everstone", "rabbit_spawn_egg")
		:onLeftClick(function() pageNav.descend(eeveelutionPage) end)
end

acts.pokeballToggle = eeveelutionPage:newAction()
	:item("cobblemon:poke_ball", "ender_pearl")
	:onToggle(function(bool)
		if checkToggle() then toggle:update(bool) end
	end)

acts.pokeballTypeHide = eeveelutionPage:newAction()
	:item("player_head{SkullOwner:"..avatar:getEntityName().."}")
	:toggleItem("cobblemon:poke_ball", "snowball")
	:onToggle(function(bool)
		typeHide:update(bool)
	end)
	:toggled(typeHide.curr)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if acts.eeveePage then
			acts.eeveePage
				:title(toJson(
					{text = "Eeveelutions Settings", bold = true, color = colors.primary}
				))
				:hoverColor(colors.hover)
		end
		
		acts.pokeballToggle
			:title(toJson(
				{
					"",
					{text = "Toggle Pokeball\n\n", bold = true, color = colors.primary},
					{text = "Toggle the usage of your pokeball.\n\n", color = colors.secondary},
					{text = swapping and "Currently swapping types, please wait!\n\n" or "", color = "gold"},
					{text = "Notice:\n", bold = true, color = "gold"},
					{text = "Various factors can prevent this feature from being active.\nAdditionally, when inside your pokeball, you are unable to move or preform actions.", color = "yellow"}
				}
			))
			:toggled(toggle.curr)
			:hoverColor(colors.hover)
			:toggleColor(colors.active)
		
		acts.pokeballTypeHide
			:title(toJson(
				{
					"",
					{text = "Toggle Pokeball Hiding\n\n", bold = true, color = colors.primary},
					{text = "Hide inside your pokeball before swapping types.", color = colors.secondary}
				}
			))
			:hoverColor(colors.hover)
			:toggleColor(colors.active)
		
	end
	
end