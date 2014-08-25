newTalent{
	name = "Inhale",
	type = {"gluttony/feast", 1},
	require = lvl_req1,
	points = 5,
	cooldown = 12,
	message = "@Source@ inhales!",
	range  = function(self, t) return 1 + self:getTalentLevelRaw(t) end,
	radius = function(self, t) return 3 + self:getTalentLevelRaw(t) end,
	direct_hit = true, -- no one seems to have a clue what this does
	requires_target = true,

	action = function(self, t)
		local tg = {type="cone", range=0, radius=self:getTalentRadius(t), selffire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PULL, {dist=self:getTalentRange(t)})
		return true
	end,

	info = function(self, t)
		return ([[You inhale powerfully, drawing in enemies for %d distance in a frontal cone of radius %d.]]):
		format(self:getTalentRange(t), self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Whet Appetite",
	type = {"gluttony/feast", 2},
	require = lvl_req2,
	points = 5,
	cooldown = 25,
	no_message = true,
	range = 1,
	requires_target = true,

	buffs_consumed = function(self, t)
		return self:getTalentLevelRaw(t)
	end,

	devour_bonus = function(self, t)
		return math.ceil(self:getTalentLevel(t))
	end,

	bonus_duration = function(self, t)
		return math.ceil(1.5*self:getTalentLevel(t))
	end,

	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		game.logSeen(self, ("%s whets their appetite on the positivity surrounding %s!"):format(self.name, target.name))
		self:project(tg, x, y, DamageType.WHET_APPETITE, {buffs_consumed=t.buffs_consumed(self, t), bonus=t.devour_bonus(self, t), dur=t.bonus_duration(self, t)})
		return true
	end,

	info = function(self, t)
		return ([[You consume %d positive effects on the target, increasing your Devour chance by %d%% for %d turns.]]):
		format(t.buffs_consumed(self, t), t.devour_bonus(self, t), t.bonus_duration(self, t))
	end,
}

newTalent{
	name = "Predation",
	type = {"gluttony/feast", 3},
	require = lvl_req3,
	points = 5,
	cooldown = 50,
	mode = "sustained",
	requires_target = false,
	on_pre_use = function(self, t, silent) if self.hunger == self.max_hunger then if not silent then game.logPlayer(self, "You are too starved.") end return false end return true end,

	chance = function(self, t) return math.floor(3 + self:getTalentLevel(t) ^ 0.65) / 100 end, -- about 3%->6%

	cost = function(self, t) return math.ceil(6 / (0.1 * self:getTalentLevelRaw(t) + 1)) end, -- about 6->4

	activate = function(self, t)
		local ret = {
			on_hit_hunger_cost = self:addTemporaryValue("on_hit_hunger_cost", t.cost(self, t)),
			on_hit_devour_chance = self:addTemporaryValue("on_hit_devour_chance", t.chance(self, t)),
		}
		return ret
	end,

	deactivate = function(self, t, p)
		self:removeTemporaryValue("on_hit_hunger_cost", p.on_hit_hunger_cost)
		self:removeTemporaryValue("on_hit_devour_chance", p.on_hit_devour_chance)
		return true
	end,

	info = function(self, t)
		return ([[Your focus in combat is intensified by your gnawing appetite.
				This allows you to prey on enemies' temporary weaknesses, granting you a %d%% chance to Devour your targets, but increasing your Hunger by %d with each attack.]]):
				format(100*t.chance(self, t), t.cost(self, t))
	end,
}

newTalent{
	name = "Gorge",
	type = {"gluttony/feast", 4},
	require = lvl_req4,
	points = 5,
	cooldown = 30,
	message = "@Source@ feasts on surrounding enemies!",
	range = 0,
	radius = 1,
	requires_target = false,

	damage = function(self, t)
		local min_dmg = 19
		local max_dmg = 120
		local min_physpwr = 30  -- physpwr at level 12
		local max_physpwr = 120 -- physpwr at level 50
		return min_dmg + math.max( 1, self:getTalentLevel(t)/2 * (max_dmg-min_dmg) * (self:combatPhysicalpower()-min_physpwr) / (max_physpwr-min_physpwr) )
	end,

	action = function(self, t)
        local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, friendlyfire=false, talent=t}
        self:project(tg, self.x, self.y,
            function(x, y)
                local Map = require "engine.Map"
                local target = game.level.map(x, y, Map.ACTOR)
                if target then
                    -- temporarily disable the target's die function
                    -- so that we can manipulate it after the physical damage
                    local old_die = rawget(target, "die")
                    target.die = function() end
                    -- do our extra physical damage
                    DamageType:get(DamageType.PHYSICAL).projector(self, x, y, DamageType.PHYSICAL, t.damage(self, t))
                    target.die = old_die
                    -- now devour
                    local level = self:knowTalent(self.T_DEVOUR) and self:getTalentLevel(self:getTalentFromId(self.T_DEVOUR)) or 1
                    self:forceUseTalent(self.T_DEVOUR, {force_target=target, force_level=level, ignore_energy=true, ignore_ressources=true, ignore_cd=true, no_confirm=true})
                end
            end
        )
        return true
	end,

	info = function(self, t)
		return ([[You attack each enemy in melee range for %.2f extra physical damage (in addition to Devour's damage) and attempt to Devour each of those enemies.]]):
		format(t.damage(self, t))
	end,
}
