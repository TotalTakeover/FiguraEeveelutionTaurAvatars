-- Disables code if not avatar host
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")

local s, _, type = pcall(require, "scripts.EeveeType")
if not s then type = {} end

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
	
	main  = action_wheel:newPage("Main"),
	eevee = action_wheel:newPage("Eevee"),
	type  = action_wheel:newPage("Type"),
	
}

-- Page actions
local pageActs = {
	
	eevee = action_wheel:newAction()
		:item(itemCheck("cobblemon:everstone", "rabbit_spawn_egg"))
		:onLeftClick(function() descend(pages.eevee) end),
	
	type = action_wheel:newAction()
		:item(itemCheck("cobblemon:eviolite", "rabbit_hide"))
		:onLeftClick(function() descend(pages.type) end)
	
}

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		pageActs.eevee
			:title(toJson(
				{text = "Pokemon Settings", bold = true, color = c.primary}
			))
		
		pageActs.type
			:title(toJson(
				{text = "Eeveelution Type", bold = true, color = c.primary}
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
	:action( -1, pageActs.eevee)

-- Eevee actions
pages.eevee
	:action( -1, pageActs.type)
	:action( -1, backAct)

-- Type actions
pages.type
	:action( -1, type.vaporeonAct)
	:action( -1, type.jolteonAct)
	:action( -1, type.flareonAct)
	:action( -1, type.espeonAct)
	:action( -1, type.umbreonAct)
	:action( -1, type.leafeonAct)
	:action( -1, type.glaceonAct)
	:action( -1, type.sylveonAct)

-- Allow back action for all `pages.type` actions
for _, action in ipairs(pages.type:getActions()) do
	action:onRightClick(function() ascend() end)
end