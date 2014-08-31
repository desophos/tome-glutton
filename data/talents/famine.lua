newTalent{
    name = "Devour",
    type = {"gluttony/famine", 1},
    require = lvl_req1,
    points = 5,
    cooldown = 3,
    range = 1,
    requires_target = true,
    no_npc_use = true,

    damage = function(self, t)
        local min_dmg = 9
        local max_dmg = 60
        local min_physpwr = 8  -- physpwr at level 1
        local max_physpwr = 120 -- physpwr at level 50
        return min_dmg + math.max( 1, self:getStat("con")/30 * (max_dmg-min_dmg) * (self:combatPhysicalpower()-min_physpwr) / (max_physpwr-min_physpwr) )
    end,

    power = function(self, t)
        local bonus = 0
        local eff = self:hasEffect(self.EFF_WHET_APPETITE)
        if eff then bonus = eff.bonus end
        return (30 / (2.5 - 0.125 * self:getTalentLevel(t))) + bonus -- around 13 to 25
    end,

    action = function(self, t)
        local tg = {type="hit", range=self:getTalentRange(t)}
        local x, y, target = self:getTarget(tg)
        if not x or not y or not target then return nil end
        if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

        if target.regurgitated then
            game.logSeen(self, "You cannot Devour a Regurgitated creature.")
            return false
        end

        if target == game.player then
            game.logSeen(self, "You cannot Devour yourself.")
            return false
        end

        -- temporarily disable the target's die function
        -- so that we can manipulate it after the physical damage
        local old_die = rawget(target, "die")
        target.die = function() end
        -- do our physical damage
        self:project(tg, x, y, DamageType.PHYSICAL, t.damage(self, t))
        target.die = old_die

        -- force display of physical damage messages before devour messages
        game:displayDelayedLogDamage()

        -- now try to devour target
        game.logSeen(self, "%s tries to devour %s.", self.name:capitalize(), target.name)
        self:project(tg, x, y, DamageType.DEVOUR, { ["power"] = t.power(self, t) })

        return true
    end,

    info = function(self, t)
        return ([[
Attack for %.2f damage and attempt to devour the target.
If the target is below %d%% life, you kill it automatically, storing it in your stomach and satiating a small amount of hunger.]]):
                format(t.damage(self, t), t.power(self, t))
    end,
}

newTalent{
    name = "Salivate",
    type = {"gluttony/famine", 2},
    require = lvl_req2,
    points = 5,
    cooldown = 10,
    range = 1,
    hunger = -1,
    no_message = true,
    requires_target = true,
    no_npc_use = true,

    daze_duration = function(self, t)
        return math.ceil(self:getTalentLevel(t))
    end,

    daze_power = function(self, t)
        return self:getStat("con") + self:combatMindpower()
    end,

    bonus_duration = function(self, t)
        return math.ceil(2 * self:getTalentLevel(t))
    end,

    devour_bonus = function(self, t)
        return math.ceil(self:getTalentLevel(t))
    end,

    action = function(self, t)
        local tg = {type="hit", range=self:getTalentRange(t)}
        local x, y, target = self:getTarget(tg)
        if not x or not y or not target then return nil end
        if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

        game.logSeen(self, ("%s salivates upon %s."):format(self.name, target.name))
        self:project(tg, x, y, DamageType.SALIVATE, {daze_duration=t.daze_duration(self, t), bonus_duration=t.bonus_duration(self, t), bonus=t.devour_bonus(self, t)})
        return true
    end,

    info = function(self, t)
        return ([[
You focus your gnawing hunger on a target, increasing your chance to Devour it by %d%% for %d turns.
Your saliva spatters the target, dazing it for %d turns.]]):
                format(t.devour_bonus(self, t), t.bonus_duration(self, t), t.daze_duration(self, t))
    end,
}

newTalent{
    name = "Voracity",
    type = {"gluttony/famine", 3},
    require = lvl_req3,
    points = 5,
    cooldown = 60,
    no_message = true,
    no_energy = true,
    requires_target = false,
    mode = "sustained",
    on_pre_use = function(self, t, silent) if self.hunger == self.max_hunger then if not silent then game.logPlayer(self, "You are too starved.") end return false end return true end,

    get_boost = function(self, t) return math.floor(6 - 0.5 * self:getTalentLevelRaw(t)) end,

    activate = function(self, t)
        local ret = {
            boost = self:addTemporaryValue("hunger_regen", t.get_boost(self, t)),
        }
        return ret
    end,

    deactivate = function(self, t, p)
        self:removeTemporaryValue("hunger_regen", p.boost)
        return true
    end,

    info = function(self, t)
        return([[
You focus on your gnawing appetite, intensifying your hunger and sending you into a voracious frenzy.
Your Hunger increases by %d each turn, but you automatically Devour each enemy you kill.]]):
                format(t.get_boost(self, t))
    end,
}

newTalent{
    name = "Famish",
    type = {"gluttony/famine", 4},
    require = lvl_req4,
    points = 5,
    cooldown = 50,
    range = 0,
    radius = function(self, t) return math.ceil(1.5 * self:getTalentLevel(t)) end,
    message = "@Source@ unleashes a famishing plague!",
    requires_target = false,
    no_npc_use = false,

    drain_percent = function(self, t)
        return 2 / (2*7.5 - self:getTalentLevel(t))
    end,

    action = function(self, t)
        tg = {type="ball", range=0, radius=self:getTalentRadius(t), friendlyfire=true, selffire=false, talent=t}
        self:project(tg, self.x, self.y, DamageType.EAT_RESOURCES, self:getHunger() * t.drain_percent(self, t))
        return true
    end,

    info = function(self, t)
        return([[
Drain resources from all those around you in a radius of %d, satiating your own hunger.
Drains resources from each creature equal to %d%% of your current Hunger.]]):
                format(self:getTalentRadius(t), math.ceil(100*t.drain_percent(self, t)))
    end,
}
