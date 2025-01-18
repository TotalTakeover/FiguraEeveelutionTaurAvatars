-- Disables code if not avatar host
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")

local s, avatar = pcall(require, "scripts.Player")
if not s then avatar = {} end

local s, typeSwap = pcall(require, "scripts.TypePicker")
if not s then typeSwap = {} end

local s, stone = pcall(require, "scripts.ElementalStones")
if not s then stone = {} end

local s, squapi = pcall(require, "scripts.SquishyAnims")
if not s then squapi = {} end

local s, c = pcall(require, "scripts.ColorProperties")
if not s then c = {} end

-- Logs pages for navigation
local navigation = {}

-- Go forward a page
local function descend(page)
	
	navigation[#navigation + 1] = action_wheel:getCurrentPage() 
	action_wheel:setPage(page)
	
end

-- Go back a page
local function ascend()
	
	action_wheel:setPage(table.remove(navigation, #navigation))
	
end

-- Page setups
local pages = {
	
	main   = action_wheel:newPage("Main"),
	avatar = action_wheel:newPage("Avatar"),
	eevee  = action_wheel:newPage("Eevee"),
	anims  = action_wheel:newPage("Anims"),
	types  = action_wheel:newPage("Types")
	
}

-- Page actions
local pageActs = {
	
	avatar = action_wheel:newAction()
		:item(itemCheck("armor_stand"))
		:onLeftClick(function() descend(pages.avatar) end),
	
	eevee = action_wheel:newAction()
		:item(itemCheck("rabbit_foot"))
		:onLeftClick(function() descend(pages.eevee) end),
	
	anims = action_wheel:newAction()
		:item(itemCheck("jukebox"))
		:onLeftClick(function() descend(pages.anims) end),
	
	types = action_wheel:newAction()
		:item(itemCheck("cobblemon:everstone", "rabbit_spawn_egg"))
		:onLeftClick(function() descend(pages.types) end)
	
}

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		pageActs.avatar
			:title(toJson(
				{text = "Avatar Settings", bold = true, color = c.primary}
			))
		
		pageActs.eevee
			:title(toJson(
				{text = "Pokemon Settings", bold = true, color = c.primary}
			))
		
		pageActs.anims
			:title(toJson(
				{text = "Animations", bold = true, color = c.primary}
			))
		
		pageActs.types
			:title(toJson(
				{text = "Eevee Types", bold = true, color = c.primary}
			))
		
		for _, page in pairs(pageActs) do
			page:hoverColor(c.hover)
		end
		
	end
	
end

-- Action back to previous page
local backAct = action_wheel:newAction()
	:title(toJson(
		{text = "Go Back?", bold = true, color = "red"}
	))
	:hoverColor(vectors.hexToRGB("FF5555"))
	:item(itemCheck("barrier"))
	:onLeftClick(function() ascend() end)

-- Set starting page to main page
action_wheel:setPage(pages.main)

-- Main actions
pages.main
	:action( -1, pageActs.avatar)
	:action( -1, pageActs.eevee)
	:action( -1, pageActs.anims)

-- Avatar actions
pages.avatar
	:action( -1, avatar.vanillaSkinAct)
	:action( -1, avatar.modelAct)
	:action( -1, backAct)

-- Eevee actions
pages.eevee
	:action( -1, pageActs.types)
	:action( -1, backAct)

-- Type actions
pages.types
	:action( -1, typeSwap.setTypeAct)
	:action( -1, stone.stoneAct)
	:action( -1, backAct)

-- Animation actions
pages.anims
	:action( -1, squapi.earsAct)
	:action( -1, squapi.armsAct)
	:action( -1, backAct)