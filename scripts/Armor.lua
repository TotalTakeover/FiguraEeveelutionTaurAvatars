-- Required scripts
local parts      = require("lib.PartsAPI")
local eeveeArmor = require("lib.KattArmor")()

-- Setting the leggings to layer 1
eeveeArmor.Armor.Leggings:setLayer(1)

-- Armor parts
eeveeArmor.Armor.Leggings
	:addParts(table.unpack(parts:createTable(function(part) return part:getName() == "Leggings" end)))
	:addTrimParts(table.unpack(parts:createTable(function(part) return part:getName() == "LeggingsTrim" end)))
eeveeArmor.Armor.Boots
	:addParts(table.unpack(parts:createTable(function(part) return part:getName() == "Boot" end)))
	:addTrimParts(table.unpack(parts:createTable(function(part) return part:getName() == "BootTrim" end)))

-- Leather armor
eeveeArmor.Materials.leather
	:setTexture(textures["textures.armor.leatherArmor"] or textures["EeveeTaur.leatherArmor"])
	:addParts(eeveeArmor.Armor.Leggings, table.unpack(parts:createTable(function(part) return part:getName() == "LeggingsLeather" end)))
	:addParts(eeveeArmor.Armor.Boots,    table.unpack(parts:createTable(function(part) return part:getName() == "BootLeather" end)))

-- Chainmail armor
eeveeArmor.Materials.chainmail
	:setTexture(textures["textures.armor.chainmailArmor"] or textures["EeveeTaur.chainmailArmor"])

-- Iron armor
eeveeArmor.Materials.iron
	:setTexture(textures["textures.armor.ironArmor"] or textures["EeveeTaur.ironArmor"])

-- Golden armor
eeveeArmor.Materials.golden
	:setTexture(textures["textures.armor.goldenArmor"] or textures["EeveeTaur.goldenArmor"])

-- Diamond armor
eeveeArmor.Materials.diamond
	:setTexture(textures["textures.armor.diamondArmor"] or textures["EeveeTaur.diamondArmor"])

-- Netherite armor
eeveeArmor.Materials.netherite
	:setTexture(textures["textures.armor.netheriteArmor"] or textures["EeveeTaur.netheriteArmor"])

-- Trims
local trims = {
	"bolt",
	"coast",
	"dune",
	"eye",
	"flow",
	"host",
	"raiser",
	"rib",
	"sentry",
	"shaper",
	"silence",
	"snout",
	"spire",
	"tide",
	"vex",
	"ward",
	"wayfinder",
	"wild"
}

-- Apply trims
for _, trim in ipairs(trims) do
	local tex = textures["textures.armor.trims."..trim.."Trim"] or textures["EeveeTaur."..trim.."Trim"] or false
	if tex then
		eeveeArmor.TrimPatterns[trim]:setTexture(tex)
	end
end

-- Config setup
config:name("EeveelutionTaur")
local helmet     = config:load("ArmorHelmet")
local chestplate = config:load("ArmorChestplate")
local leggings   = config:load("ArmorLeggings")
local boots      = config:load("ArmorBoots")
if helmet     == nil then helmet     = true end
if chestplate == nil then chestplate = true end
if leggings   == nil then leggings   = true end
if boots      == nil then boots      = true end

-- Helmet parts
local helmetGroups = {
	
	vanilla_model.HELMET
	
}

-- Chestplate parts
local chestplateGroups = {
	
	vanilla_model.CHESTPLATE
	
}

-- Leggings parts
local leggingsGroups = {
	
	table.unpack(parts:createTable(function(part) return part:getName():find("ArmorLeggings") end))
	
}

-- Boots parts
local bootsGroups = {
	
	table.unpack(parts:createTable(function(part) return part:getName():find("ArmorBoot") end))
	
}

-- Parts hidden by helmet
local helmetHides = {
	
	parts.group.Ears,
	parts.group.headAccs
	
}

-- Parts hidden by leggings
local leggingsHides = {
	
	parts.group.LowerTorsoAccs
	
}

-- Gets vaporeon tail fins
for _, part in pairs(parts.group) do
	if part:getName():find("VaporeonTail") then
		for _, child in ipairs(part:getChildren()) do
			if child:getName():find("Fin") then
				table.insert(leggingsHides, child)
			end
		end
	end
end

-- Parts hidden by boots
local bootsHides = {
	
	parts.group.FrontLeftLeg2Accs,
	parts.group.FrontRightLeg2Accs,
	parts.group.BackLeftLeg2Accs,
	parts.group.BackRightLeg2Accs
	
}

function events.RENDER(delta, context)
	
	-- Apply
	for _, part in ipairs(helmetGroups) do
		part:visible(helmet)
	end
	
	for _, part in ipairs(chestplateGroups) do
		part:visible(chestplate)
	end
	
	for _, part in ipairs(leggingsGroups) do
		part:visible(leggings)
	end
	
	for _, part in ipairs(bootsGroups) do
		part:visible(boots)
	end
	
	-- Hide head parts when wearing helmet
	local helmetHide = not (helmet and player:getItem(6).id ~= "minecraft:air")
	for _, part in ipairs(helmetHides) do
		part:visible(helmetHide)
	end
	
	-- Hide lower body parts when wearing leggings
	local leggingsHide = not (leggings and player:getItem(4).id ~= "minecraft:air")
	for _, part in ipairs(leggingsHides) do
		part:visible(leggingsHide)
	end
	
	-- Hide leg parts when wearing boots
	local bootsHide = not (boots and player:getItem(3).id ~= "minecraft:air")
	for _, part in ipairs(bootsHides) do
		part:visible(bootsHide)
	end
	
end

-- All toggle
function pings.setArmorAll(boolean)
	
	helmet     = boolean
	chestplate = boolean
	leggings   = boolean
	boots      = boolean
	config:save("ArmorHelmet", helmet)
	config:save("ArmorChestplate", chestplate)
	config:save("ArmorLeggings", leggings)
	config:save("ArmorBoots", boots)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Helmet toggle
function pings.setArmorHelmet(boolean)
	
	helmet = boolean
	config:save("ArmorHelmet", helmet)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Chestplate toggle
function pings.setArmorChestplate(boolean)
	
	chestplate = boolean
	config:save("ArmorChestplate", chestplate)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Leggings toggle
function pings.setArmorLeggings(boolean)
	
	leggings = boolean
	config:save("ArmorLeggings", leggings)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Boots toggle
function pings.setArmorBoots(boolean)
	
	boots = boolean
	config:save("ArmorBoots", boots)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Sync variables
function pings.syncArmor(...)
	
	helmet, chestplate, leggings, boots = ...
	
end

-- Host only instructions
if not host:isHost() then return end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncArmor(helmet, chestplate, leggings, boots)
	end
	
end

-- Required scripts
local s, wheel, itemCheck, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Player") -- Tries to find script, not required

-- Pages
local parentPage = action_wheel:getPage("Player") or action_wheel:getPage("Main")
local armorPage  = action_wheel:newPage("Armor")

-- Actions table setup
local a = {}

-- Actions
a.pageAct = parentPage:newAction()
	:item(itemCheck("iron_chestplate"))
	:onLeftClick(function() wheel:descend(armorPage) end)

a.allAct = armorPage:newAction()
	:item(itemCheck("armor_stand"))
	:toggleItem(itemCheck("netherite_chestplate"))
	:onToggle(pings.setArmorAll)

a.helmetAct = armorPage:newAction()
	:item(itemCheck("iron_helmet"))
	:toggleItem(itemCheck("diamond_helmet"))
	:onToggle(pings.setArmorHelmet)

a.chestplateAct = armorPage:newAction()
	:item(itemCheck("iron_chestplate"))
	:toggleItem(itemCheck("diamond_chestplate"))
	:onToggle(pings.setArmorChestplate)

a.leggingsAct = armorPage:newAction()
	:item(itemCheck("iron_leggings"))
	:toggleItem(itemCheck("diamond_leggings"))
	:onToggle(pings.setArmorLeggings)

a.bootsAct = armorPage:newAction()
	:item(itemCheck("iron_boots"))
	:toggleItem(itemCheck("diamond_boots"))
	:onToggle(pings.setArmorBoots)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		a.pageAct
			:title(toJson(
				{text = "Armor Settings", bold = true, color = c.primary}
			))
		
		a.allAct
			:title(toJson(
				{
					"",
					{text = "Toggle All Armor\n\n", bold = true, color = c.primary},
					{text = "Toggles visibility of all armor parts.", color = c.secondary}
				}
			))
			:toggled(helmet and chestplate and leggings and boots)
		
		a.helmetAct
			:title(toJson(
				{
					"",
					{text = "Toggle Helmet\n\n", bold = true, color = c.primary},
					{text = "Toggles visibility of helmet parts.", color = c.secondary}
				}
			))
			:toggled(helmet)
		
		a.chestplateAct
			:title(toJson(
				{
					"",
					{text = "Toggle Chestplate\n\n", bold = true, color = c.primary},
					{text = "Toggles visibility of chestplate parts.", color = c.secondary}
				}
			))
			:toggled(chestplate)
		
		a.leggingsAct
			:title(toJson(
				{
					"",
					{text = "Toggle Leggings\n\n", bold = true, color = c.primary},
					{text = "Toggles visibility of leggings parts.", color = c.secondary}
				}
			))
			:toggled(leggings)
		
		a.bootsAct
			:title(toJson(
				{
					"",
					{text = "Toggle Boots\n\n", bold = true, color = c.primary},
					{text = "Toggles visibility of boots.", color = c.secondary}
				}
			))
			:toggled(boots)
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end