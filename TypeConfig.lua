--[[
	
	Notice:
	Below is a list of all the eevee types this avatar will attempt to use, by name.
	If you do not wish to include a specific type to toggle to, you can delete it from this table, or delete its primary texture.
	TypeSwap.lua will find accessories under the same name (uppercase), and toggle their visibility if the curType matches.
	Be sure to delete any accessories from the model that you no longer need! You don't need to, but it helps save space!
	
	If you wish to add a type to toggle to, all you need to do is add it to the table, and add its primary texture to the model under the same name, lowercase.
	To add accessories to a specific type, add its name (uppercase) to the group name.
	
--]]
local types = {
	"eevee",
	"vaporeon",
	"jolteon",
	"flareon",
	"espeon",
	"umbreon",
	"leafeon",
	"glaceon",
	"sylveon"
}

-- Return types
return types