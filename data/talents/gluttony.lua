newTalentType {
   allow_random = false,
   type = "gluttony/famine",
   name = "famine",
   description = "Indulge your hunger.",
}

newTalentType {
   allow_random = false,
   type = "gluttony/digestion",
   name = "digestion",
   description = "Digest your prey.",
}

newTalentType {
   allow_random = false,
   type = "gluttony/feast",
   name = "feast",
   description = "Feast upon your enemies.",
}

newTalentType {
	allow_random = false,
	type = "gluttony/pica",
	name = "pica",
	description = "Consume inorganic material.",
}

lvl_req1 = {
	level = function(level) return 0 + (level-1) end,
}
lvl_req2 = {
	level = function(level) return 4 + (level-1) end,
}
lvl_req3 = {
	level = function(level) return 8 + (level-1) end,
}
lvl_req4 = {
	level = function(level) return 12 + (level-1) end,
}

load("/data-glutton/talents/hunger.lua")
load("/data-glutton/talents/famine.lua")
load("/data-glutton/talents/digestion.lua")
load("/data-glutton/talents/feast.lua")
load("/data-glutton/talents/pica.lua")
