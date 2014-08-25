-- with thanks to natev, who graciously allowed me to use his code structure for stat change on resource change

newTalent{
    name = "Hunger Pool",
    type = {"base/class", 1},
    info = [[Allows you to have a hunger pool, which is equal to 100 + CON.
            As you starve (increasing Hunger), your power and life regen decrease.
            As you satiate yourself (decreasing Hunger), your power and life regen increase.]],
    mode = "passive",
    hide = "always",
    no_unlearn_last = true,
    base_power_mod = 0.2,
    base_life_regen_mod = 0.008,

    get_mod = function(self, mod_type, positive_when_starving)
        local base_factor = self:getTalentFromId(self.T_HUNGER_POOL)["base_"..mod_type.."_mod"]
        local t = self:getTalentFromId(self.T_ANABOLISM)
        local add_factor = 0
        if self:knowTalent(t) then add_factor = t[mod_type.."_mod"](self, t) end

        local m = (self.starvation_threshold - self:getHunger())
        if positive_when_starving then m = (self:getHunger() - self.starvation_threshold) end

        if    m <= 0 then return m * (base_factor - add_factor)
        elseif m > 0 then return m * (base_factor + add_factor)
        end
    end,

    on_learn = function(self, t)
        self.on_act = function(self)
            if self:isTalentActive(self.T_VORACITY) and self.hunger >= self.max_hunger then
                self:useTalent(self.T_VORACITY)
            end
            if self:isTalentActive(self.T_PREDATION) and self.hunger >= self.max_hunger then
                self:useTalent(self.T_PREDATION)
            end
        end

        self.hunger_cost_mod = 1
        self.hunger_regen = 0.25
        t.onStatChange(self)
    end,

    calculateStarvationThreshold = function(self)
        return self.max_hunger - 30
    end,

    onStatChange = function(self)
        if not self.tmpIds then self.tmpIds = {} end
        if self.tmpIds.tempMaxHungerId then
            self:removeTemporaryValue("max_hunger", self.tmpIds.tempMaxHungerId)
        end

        local added_max_hunger = self:getStat("con")
        self.tmpIds.tempMaxHungerId = self:addTemporaryValue("max_hunger", added_max_hunger)

        self.starvation_threshold = self:getTalentFromId(self.T_HUNGER_POOL).calculateStarvationThreshold(self)

        self:getTalentFromId(self.T_HUNGER_POOL).onChangingHunger(self)
    end,

    customIncHunger = function(self, amt)
        self:incHunger(amt * (self.hunger_cost_mod or 1))
        self:getTalentFromId(self.T_HUNGER_POOL).onChangingHunger(self)
    end,

    onChangingHunger = function(self)
    --really our workhorse function, this keeps track of all of our bonuses from Hunger driven passives
    --and should be called anytime our hunger changes
    --actor.tmpIds[n] are all being saved properly, should be valid between sessions
        if not self.tmpIds then self.tmpIds = {} end

        local t = self:getTalentFromId(self.T_HUNGER_POOL)

        --self:removeTemporaryValue("global_speed_add", self.tmpIds.speed)
        self:removeTemporaryValue("combat_dam", self.tmpIds.phys)
        self:removeTemporaryValue("combat_mindpower", self.tmpIds.mind)
        self:removeTemporaryValue("combat_spellpower", self.tmpIds.spell)
        self:removeTemporaryValue("life_regen", self.tmpIds.life_regen)

        --self.tmpIds.speed         = self:addTemporaryValue("global_speed_add",    t.get_mod(self, "speed", true))
        self.tmpIds.phys        = self:addTemporaryValue("combat_dam",          t.get_mod(self, "power", false))
        self.tmpIds.mind        = self:addTemporaryValue("combat_mindpower",    t.get_mod(self, "power", false))
        self.tmpIds.spell       = self:addTemporaryValue("combat_spellpower",   t.get_mod(self, "power", false))
        self.tmpIds.life_regen  = self:addTemporaryValue("life_regen",          t.get_mod(self, "life_regen", false))
    end,
}
