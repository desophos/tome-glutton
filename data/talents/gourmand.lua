newTalent{
    name = "Cast-Iron Stomach",
    type = {"gluttony/gourmand", 1},
    require = lvl_req1,
    points = 5,
    mode = "passive",

    resist = function(self, t) return 8 * self:getTalentLevel(t) end,

    passives = function(self, t, p)
        self:talentTemporaryValue(p, "disease_immune", t.resist(self, t) / 100)
        self:talentTemporaryValue(p, "resists", {[DamageType.POISON] = t.resist(self, t)})
    end,

    info = function(self, t)
        return ([[
Your growing experience with unsavory meals has improved your gastrointestinal constitution.
Your poison and disease resistances are increased by %0.1f%%.]]):
                format(t.resist(self, t))
    end
}

newTalent{
    name = "Open Mind",
    type = {"gluttony/gourmand", 2},
    require = lvl_req2,
    points = 5,
    mode = "passive",

    num_increase = function(self, t) return 1 * self:getTalentLevel(t) end,
    levels_increase = function(self, t) return 2 * self:getTalentLevel(t) end,

    passives = function(self, t, p)
        self:talentTemporaryValue(p, "max_talents", t.num_increase(self, t))
        self:talentTemporaryValue(p, "max_total_talent_level", t.levels_increase(self, t))
    end,

    info = function(self, t)
        return ([[
As you embrace your affliction and continue to absorb the abilities of others, you begin to open up to your true potential.
The maximum number of talents you can learn is increased by %d.
The maximum number of talent levels you can learn is increased by %d.]]):
                format(t.num_increase(self, t), t.levels_increase(self, t))
    end
}

newTalent{
    name = "Endure Starvation",
    type = {"gluttony/gourmand", 3},
    require = lvl_req3,
    points = 5,
    mode = "passive",

    regen_change = function(self, t) return 0.02 * self:getTalentLevel(t) end,

    passives = function(self, t, p)
        self:talentTemporaryValue(p, "hunger_regen", -t.regen_change(self, t))
    end,

    info = function(self, t)
        return ([[
You have learned to withstand your constant gnawing hunger to an extent.
Your Hunger regeneration rate is decreased by %0.2f.]]):
                format(t.regen_change(self, t))
    end
}

newTalent{
    name = "Devouring Enthusiasm",
    type = {"gluttony/gourmand", 4},
    require = lvl_req4,
    points = 5,
    mode = "passive",

    resource_gain_percent = function(self, t) return 4 * self:getTalentLevel(t) end,

    passives = function(self, t, p)
        self:talentTemporaryValue(p, "devour_resource_gain", t.resource_gain_percent(self, t))
    end,

    info = function(self, t)
        return ([[
You have grown accustomed to your affliction to the point that you constantly look forward to your next meal.
Upon Devouring an enemy, you gain %0.2f%% of their current resources.]]):
                format(t.resource_gain_percent(self, t))
    end
}