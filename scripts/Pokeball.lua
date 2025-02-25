-- Required scripts
local parts = require("lib.PartsAPI")
local typeData = require("scripts.TypeControl")

-- Pokeball part
local pokeBall = parts.group.PokeBall

-- Kills script if it cannot find pokeBall
if not pokeBall then return {} end

-- Animation setup
local anims = animations.EeveeTaur
local openAnim  = anims.pokeballOpen
local closeAnim = anims.pokeballClose

-- Config setup
config:name("EeveelutionTaur")
local toggle   = config:load("PokeballToggle") or false
local typeHide = config:load("PokeballTypeHide")
if typeHide == nil then typeHide = true end

-- Variables
local swapping = false
local isInBall  = toggle
local wasInBall = toggle
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
	local startAnim = toggle and closeAnim or openAnim
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
	isInBall = (swapping or toggle) and not hasRider
	
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
function typeData:updateAll()
	
	if typeHide then
		
		if not swapping then
			
			-- Check if player is already in the ball, and do a fast swap in place
			if toggle and parts.group.Player:getAnimScale():length() == 0 then
				
				prevUpdateAll()
				return
				
			end
			
			-- Variables
			local timer = 0
			local _type = typeData.tarType
			swapping = true
			
			-- Create new tick event
			events.TICK:register(function(delta, context)
				
				if _type ~= typeData.tarType then
					
					timer = 0
					
				elseif parts.group.Player:getAnimScale():length() == 0 then
					
					timer = timer + 1
					
				end
				
				if timer >= 10 then
					
					prevUpdateAll()
					swapping = false
					events.TICK:remove("PokeballTypeHide")
					
				end
				
				-- Store last state
				_type = typeData.tarType
				
			end, "PokeballTypeHide")
			
		end
		
	else
		
		prevUpdateAll()
		
	end
	
end

-- Pokeball toggle
function pings.setPokeball(boolean)
	
	-- If animations both animations are done playing, allow the switching of animations
	local canToggle = openAnim:getTime() == openAnim:getLength() and closeAnim:getTime() == closeAnim:getLength()
	
	if canToggle then
		toggle = boolean
		config:save("PokeballToggle", toggle)
	end
	
end

-- Type hide toggle
function pings.setPokeballTypeHide(boolean)
	
	typeHide = boolean
	config:save("PokeballTypeHide", typeHide)
	
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

-- Pokeball bounce
function pings.playPokeballInteract()
	
	anims.pokeballInteract:restart()
	
	if player:isLoaded() then
		sounds:playSound("cobblemon:poke_ball.capture_succeeded", player:getPos(), 0.35)
	end
	
end

-- Sync variable
function pings.syncPokeball(a, b)
	
	toggle = a
	typeHide = b
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local s, c = pcall(require, "scripts.ColorProperties")
if not s then c = {} end

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

-- Pokeball Keybind
local toggleBind   = config:load("PokeballToggleKeybind") or "key.keyboard.keypad.1"
local setToggleKey = keybinds:newKeybind("Pokeball Toggle"):onPress(function() pings.setPokeball(not toggle) end):key(toggleBind)

-- Movement/Action keybinds
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
	
	local toggleKey = setToggleKey:getKey()
	if toggleKey ~= toggleBind then
		toggleBind = toggleKey
		config:save("PokeballToggleKeybind", toggleKey)
	end
	
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

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncPokeball(toggle, typeHide)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.toggleAct = action_wheel:newAction()
	:item(itemCheck("cobblemon:poke_ball", "ender_pearl"))
	:onToggle(pings.setPokeball)

t.typeHideAct = action_wheel:newAction()
	:item(itemCheck("player_head{SkullOwner:"..avatar:getEntityName().."}"))
	:toggleItem(itemCheck("cobblemon:poke_ball", "snowball"))
	:onToggle(pings.setPokeballTypeHide)
	:toggled(typeHide)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.toggleAct
			:title(toJson(
				{
					"",
					{text = "Toggle Pokeball\n\n", bold = true, color = c.primary},
					{text = "Toggle the usage of your pokeball.\n\n", color = c.secondary},
					{text = swapping and "Currently swapping types, please wait!\n\n" or "", color = "gold"},
					{text = "Notice:\n", bold = true, color = "gold"},
					{text = "Various factors can prevent this feature from being active.\nAdditionally, when inside your pokeball, you are unable to move or preform actions.", color = "yellow"}
				}
			))
			:toggled(toggle)
		
		t.typeHideAct
			:title(toJson(
				{
					"",
					{text = "Toggle Pokeball Hiding\n\n", bold = true, color = c.primary},
					{text = "Hide inside your pokeball before swapping types.", color = c.secondary}
				}
			))
		
		for _, act in pairs(t) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end

-- Return actions
return t