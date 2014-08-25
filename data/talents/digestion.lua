newTalent{
    name = "Excrete",
    type = {"base/class", 1},
    no_unlearn_last = true,
    on_pre_use = function(self, t, silent) if not (self.creatures_devoured and #self.creatures_devoured > 0) then if not silent then game.logPlayer(self, "Your stomach is empty.") end return false end return true end,

    next_creature_to_excrete = function(self, t)
        if self.creatures_devoured and #self.creatures_devoured > 0 then
            return self.creatures_devoured[1].name
        end
        return "None"
    end,

    action = function(self, t)
        if self.creatures_devoured and #self.creatures_devoured > 0 then
            local c = table.remove(self.creatures_devoured, 1)
            game.logSeen(self, ("%s excreted %s."):format(self.name, c.name))
            return true
        end
        game.logSeen(self, "Your stomach is empty.")
        return false
    end,

    info = function(self, t)
        return ([[Hasten a creature's departure through your bowels, removing it from your stomach.
                Next creature to Excrete: %s]]):
                format(t.next_creature_to_excrete(self, t))
    end,
}

newTalent{
    name = "Digest",
    type = {"gluttony/digestion", 1},
    require = lvl_req1,
    points = 5,
    no_energy = true,
    cooldown = function(self, t) return math.ceil(100 / (1 + 0.2 * self:getTalentLevel(t))) end, -- about 100 to 40
    on_pre_use = function(self, t, silent) if not (self.creatures_devoured and #self.creatures_devoured > 0) then if not silent then game.logPlayer(self, "Your stomach is empty.") end return false end return true end,

    on_learn = function(self, t)
        self:learnTalent(self.T_EXCRETE, true)
    end,

    on_unlearn = function(self, t)
        self:unlearnTalent(self.T_EXCRETE)
    end,

    next_creature_to_digest = function(self, t)
        if self.creatures_devoured and #self.creatures_devoured > 0 then
            return self.creatures_devoured[1].name
        end
        return "None"
    end,

    action = function(self, t)
        if self.creatures_devoured and #self.creatures_devoured > 0 then
            self:setEffect(self.EFF_DIGESTING, t.cooldown(self, t), {})
            return true
        end
        game.logSeen(self, "Your stomach is empty.")
        return false
    end,

    info = function(self, t)
        return ([[Digest a creature you have Devoured to gain permanent bonuses depending on the creature's rank. Takes %d turns.
                Digesting any creature permanently grants you one of that creature's talents up to the level at which the creature knows the talent, to a maximum of Digest's effective level.
                Next creature to Digest: %s]]):
                format(t.cooldown(self, t), t.next_creature_to_digest(self, t))
    end,
}

newTalent{
    name = "Catabolize",
    type = {"gluttony/digestion", 2},
    require = lvl_req2,
    points = 5,
    cooldown = function(self, t) return 30 - 4*self:getTalentLevel(t) end,
    no_energy = true,
    no_message = true,
    requires_target = false,
    no_npc_use = true,
    on_pre_use = function(self, t, silent) if not (self.creatures_devoured and #self.creatures_devoured > 0) then if not silent then game.logPlayer(self, "Your stomach is empty.") end return false end return true end,

    next_creature_to_catabolize_name = function(self, t)
        if self.creatures_devoured and #self.creatures_devoured > 0 then
            return self.creatures_devoured[1].name
        end
        return "None"
    end,

    next_creature_to_catabolize_rank = function(self, t)
        if self.creatures_devoured and #self.creatures_devoured > 0 then
            return self.creatures_devoured[1].rank
        end
        return 0
    end,

    num_stats = function(self, t, e_rank)
        return math.ceil((e_rank * self:getTalentLevel(t)) / 5)
    end,

    stat_amount = function(self, t, e_rank)
        return math.ceil(e_rank * self:getTalentLevel(t))
    end,

    stat_duration = function(self, t, e_rank)
        return math.ceil(e_rank * 2 * self:getTalentLevel(t))
    end,

    action = function(self, t)
        if self.creatures_devoured and #self.creatures_devoured > 0 then
            local digested_creature = table.remove(self.creatures_devoured, 1) -- FIFO
            local rank = digested_creature.rank

            game.logSeen(self, "%s has been digested.", digested_creature.name:capitalize())

            local stats = {"STR", "DEX", "CON", "MAG", "WIL", "CUN"}

            for i = 1, t.num_stats(self, t, rank) do
                if #stats == 0 then break end
                self:setEffect(self.EFF_NUTRITION, t.stat_duration(self, t, rank), {creature_name=digested_creature.name, stat=rng.tableRemove(stats), amt=t.stat_amount(self, t, rank)})
            end
        else
            game.logSeen(self, "Your stomach is empty.")
            return false
        end
        return true
    end,

    info = function(self, t)
        e_rank = t.next_creature_to_catabolize_rank(self, t)
        return ([[You catalyze your digestive processes, temporarily increasing your rate of digestion so that you immediately digest a Devoured creature.
                You gain temporary stat bonuses depending on talent level and the creature's rank.
                Next creature to Catabolize: %s, which will grant you %d of %d stats for %d turns.]]):
                format(
                    t.next_creature_to_catabolize_name(self, t),
                    t.stat_amount(self, t, e_rank),
                    t.num_stats(self, t, e_rank),
                    t.stat_duration(self, t, e_rank)
                )
    end,
}

--[[ may return later
newTalent{
    name = "Gastric Acid",
    type = {"gluttony/digestion", 2},
    require = lvl_req2,
    points = 5,
    mode = "passive",

    info = function(self, t)
        return (Increases the power of Regurgitate.
                Regurgitate bonuses:
                Duration: +%d turns
                Stat scaling factor: +%d%%
                ):
                format(
                    self:getTalentLevel(t),
                    self:getTalentLevel(t) * 0.05 * 100
                )
    end,
}
--]]

newTalent{
    name = "Anabolism",
    type = {"gluttony/digestion", 3},
    require = lvl_req3,
    points = 5,
    mode = "passive",

    speed_mod = function(self, t)
        return self:getTalentLevel(t) * 0.001
    end,

    power_mod = function(self, t)
        return self:getTalentLevel(t) * 0.02
    end,

    life_regen_mod = function(self, t)
        return self:getTalentLevel(t) * 0.0005
    end,

    info = function(self, t)
        local t_hunger = self:getTalentFromId(self.T_HUNGER_POOL)
        --Global speed: %f per point above starvation threshold
        return ([[Increases the bonuses and decreases the penalties of Hunger.
                You begin starving above %d Hunger.
                Current Hunger modifiers:
                Power: %f per point below starvation threshold
                Life regen: %f per point below starvation threshold]]):
                format(
                    t_hunger.calculateStarvationThreshold(self),
                    --t_hunger.base_speed_mod + t.speed_mod(self, t),
                    t_hunger.base_power_mod + t.power_mod(self, t),
                    t_hunger.base_life_regen_mod + t.life_regen_mod(self, t)
                )
    end,
}

newTalent{
    name = "Regurgitate",
    type = {"gluttony/digestion", 4},
    require = lvl_req4,
    points = 5,
    hunger = -10,
    cooldown = 15,
    range = function(self, t) return math.ceil(1.5 * self:getTalentLevel(t)) end,
    radius = function(self, t) return math.ceil(self:getTalentLevel(t) / 3) end,
    requires_target = true,
    is_summon = true,
    on_pre_use = function(self, t, silent) if not (self.creatures_devoured and #self.creatures_devoured > 0) then if not silent then game.logPlayer(self, "Your stomach is empty.") end return false end return true end,

    next_creature_to_regurgitate = function(self, t)
        if self.creatures_devoured and #self.creatures_devoured > 0 then
            return self.creatures_devoured[#self.creatures_devoured].name
        end
        return "None"
    end,

    duration = function(self, t)
        local add_amt = 0
        local t_gastric_acid = self:getTalentFromId(self.T_GASTRIC_ACID)
        if self:knowTalent(t_gastric_acid) then add_amt = self:getTalentLevel(t_gastric_acid) end
        return math.ceil(self:getTalentLevel(t) + 5 + add_amt)
    end,

    stat_scaling_factor = function(self, t)
        local add_amt = 0
        local t_gastric_acid = self:getTalentFromId(self.T_GASTRIC_ACID)
        if self:knowTalent(t_gastric_acid) then add_amt = self:getTalentLevel(t_gastric_acid) end
        return 0.7 + (0.05 * (self:getTalentLevel(t) + add_amt))
    end,

    physical_damage = function(self, t, e)
        if e then
            return e.size_category * self:getStat("con") * self:getTalentLevel(t)
        else -- so we can use this in the info
            return self:getStat("con") * self:getTalentLevel(t)
        end
    end,

    acid_ball_damage = function(self, t)
        return self:getStat("con") * self:getTalentLevel(t)
    end,

    action = function(self, t)
        if (not self.creatures_devoured) or (#self.creatures_devoured < 1) then
            game.logPlayer(self, "Your stomach is empty.")
            return
        end

        local tg = {type="ball", range=self:getTalentRange(t), radius=t.radius(self, t), talent=t}
        local tx, ty, target = self:getTarget(tg)
        if not tx or not ty then return nil end
        local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
        target = game.level.map(tx, ty, Map.ACTOR)

        -- do acid ball damage
        self:project(tg, tx, ty, DamageType.ACID, t.acid_ball_damage(self, t))

        local tg2 = {type="ball", range=self:getTalentRange(t), radius=0, talent=t}

        -- do physical damage
        self:project(tg2, tx, ty, DamageType.PHYSICAL, t.physical_damage(self, t))

        -- Find space
        local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
        if not x then
            game.logPlayer(self, "Not enough space!")
            return
        end

        -- get regurgitated creature
        e = table.remove(self.creatures_devoured, #self.creatures_devoured) -- LIFO

        game.logPlayer(self, ("%s regurgitates %s!"):format(self.name, e.name))

        e:addTemporaryValue("regurgitated", 1)
        setupSummon(self, t, e, x, y)

        return true
    end,

    info = function(self, t)
        return ([[Regurgitate the last creature you devoured.
                You spit out the creature at a target, doing (%d * the creature's size category) physical damage (scales with CON) to the target and %d acid damage in radius %d.
                The creature will fight by your side until it decays from your stomach acid.
                Its stats (scaled to %d%%) and duration (%d turns) increase with talent level.
                Next creature to Regurgitate: %s]]):
                format(
                    t.physical_damage(self, t),
                    t.acid_ball_damage(self, t),
                    t.radius(self, t),
                    100*t.stat_scaling_factor(self, t),
                    t.duration(self, t),
                    t.next_creature_to_regurgitate(self, t)
                )
    end,
}

function setupSummon(self, t, e, x, y)
    local effs = {}

    -- Go through all spell effects
    for eff_id, p in pairs(e.tmp) do
        local eff = e.tempeffect_def[eff_id]
        effs[#effs+1] = {"effect", eff_id}
    end

    -- Go through all sustained spells
    for tid, act in pairs(e.sustain_talents) do
        if act then
            effs[#effs+1] = {"talent", tid}
        end
    end

    while #effs > 0 do
        local eff = rng.tableRemove(effs)

        if eff[1] == "effect" then
            e:removeEffect(eff[2])
        else
            e:forceUseTalent(eff[2], {ignore_energy=true})
        end
    end
    e.life = e.max_life
    e.mana = e.max_mana
    e.stamina = e.max_stamina
    e.equilibrium = 0
    e.air = e.max_air

    e.dead = false
    e.died = (e.died or 0) + 1

    e.faction = self.faction
    e.summoner = self
    e.summoner_gain_exp=true
    e.summon_time = t.duration(self, t)

    -- scale stats
    for _,stat in ipairs({"str", "dex", "con", "mag", "wil", "cun"}) do
        e:incStat(stat, (t.stat_scaling_factor(self, t) * e:getStat(stat)) - e:getStat(stat))
    end

    e.no_points_on_levelup = true
    e.unused_stats = 0
    e.unused_talents = 0
    e.unused_generics = 0
    e.unused_talents_types = 0

    e.ai = "summoned"
    e.ai_real = "tactical"

    if game.party:hasMember(self) then
        e.remove_from_party_on_death = true
        game.party:addMember(e, {
            control=false,
            type="summon",
            title=("Regurgitated %s"):format(e.name),
            orders = {target=false, leash=false, anchor=false, talents=false},
        })
    end
    e:resolve(nil, true)
    game.zone:addEntity(game.level, e, "actor", x, y)
end
