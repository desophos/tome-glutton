newTalent{
    name = "Eat Walls",
    type = {"gluttony/pica", 1},
    require = lvl_req1,
    points = 5,
    cooldown = 30,
    action = function(self, t)
        self:setEffect(self.EFF_EAT_WALLS, math.ceil(self:getTalentLevel(t)), { satiation=math.ceil(self:getTalentLevel(t)) })
        return true
    end,
    info = function(self, t)
        return ([[
Allows you to gnaw through walls for %d turns.
Each movement through a wall satiates %d Hunger.]]):
                format(math.ceil(self:getTalentLevel(t)), self:getTalentLevel(t))
    end,
}

newTalent{
    name = "Consume Item",
    type = {"gluttony/pica", 2},
    require = lvl_req2,
    points = 5,

    duration = function(self, t) return math.ceil(20 + 5 * math.sqrt(self:getTalentLevel(t))) end,

    allowed_tier = function(self, t) return self:getTalentLevelRaw(t) end,

    action = function(self, t)
        local inven = self:getInven("INVEN")
        self:showInventory("Select an item to consume.", inven, function(o) return not o.unique and not o.plot and o.type ~= "gem" and o.type ~= "scroll" and o.material_level and o.material_level <= t.allowed_tier(self, t) end, function(o, item)
            o = self:removeObject(inven, item)

            game.logSeen(self, "%s consumes %s.", self.name:capitalize(), o.name)

            if o.power_source then
                for source, is_source in pairs(o.power_source) do
                    if is_source then
                        if source == "arcane" then
                            self:setEffect(self.EFF_ARCANE_NUTRITION, t.duration(self, t), {item_name=o.name, item_tier=o.material_level})
                        elseif source == "nature" then
                            self:setEffect(self.EFF_NATURE_NUTRITION, t.duration(self, t), {item_name=o.name, item_tier=o.material_level})
                        elseif source == "technique" then
                            self:setEffect(self.EFF_TECHNIQUE_NUTRITION, t.duration(self, t), {item_name=o.name, item_tier=o.material_level})
                        elseif source == "psionic" then
                            self:setEffect(self.EFF_PSIONIC_NUTRITION, t.duration(self, t), {item_name=o.name, item_tier=o.material_level})
                        elseif source == "antimagic" then
                            self:setEffect(self.EFF_ANTIMAGIC_NUTRITION, t.duration(self, t), {item_name=o.name, item_tier=o.material_level})
                        elseif source == "unknown" then
                            self:setEffect(self.EFF_UNKNOWN_NUTRITION, t.duration(self, t), {item_name=o.name, item_tier=o.material_level})
                        end
                    end
                end
            end

            self:sortInven()
            return true
        end)
    end,

    info = function(self, t)
        return ([[You eat an item up to tier %d, gaining temporary bonuses based on the item's tier and power source(s) for %d turns.]]):
                format(t.allowed_tier(self, t), t.duration(self, t))
    end,
}

newTalent{
    name = "Excrete Gem",
    type = {"base/class", 1},
    no_unlearn_last = true,
    on_pre_use = function(self, t, silent)
        local gems = self:getInven("SWALLOWED_GEMS")
        if not (gems and #gems > 0) then
            if not silent then game.logPlayer(self, "There are no gems in your stomach.") end
            return false
        end
        return true
    end,

    next_gem_to_excrete = function(self, t)
        local gems = self:getInven("SWALLOWED_GEMS")
        if gems and #gems > 0 then
            return gems[1]:getName{do_color=true}:a_an()
        end
        return "None"
    end,

    action = function(self, t)
        local gems = self:getInven("SWALLOWED_GEMS")
        if gems and #gems > 0 then
            local g = table.remove(gems, 1)
            game.logSeen(self, ("%s excreted %s."):format(self.name, g:getName{do_color=true}:a_an()))
            return true
        end
        game.logSeen(self, "There are no gems in your stomach.")
        return false
    end,

    info = function(self, t)
        return ([[
Hasten a gem's departure through your bowels, removing it from your stomach.
Next gem to Excrete: %s]]):
                format(t.next_gem_to_excrete(self, t))
    end,
}

newTalent{
    name = "Swallow Gem",
    type = {"gluttony/pica", 3},
    require = lvl_req3,
    points = 5,
    on_pre_use = function(self, t, silent)
        if not self:canAddToInven("SWALLOWED_GEMS") then
            if not silent then game.logSeen(self, "Your stomach can hold no more gems.") end
            return false
        end
        return true
    end,

    allowed_tier = function(self, t) return self:getTalentLevelRaw(t) end,

    on_learn = function(self, t)
        self:learnTalent(self.T_EXCRETE_GEM, true)
        -- init inventory
        self.body = self.body or {}
        self.body.SWALLOWED_GEMS = 1
        self:initBody()
    end,

    on_unlearn = function(self, t)
        self:unlearnTalent(self.T_EXCRETE_GEM)
    end,

    action = function(self, t)
        local gems = self:getInven("SWALLOWED_GEMS")

        if self:getTalentLevelRaw(t) == 5 and gems.max ~= 2 then -- change max if we're at level 5
            gems.max = 2
        end

        if not self:canAddToInven("SWALLOWED_GEMS") then
            game.logSeen(self, "Your stomach can hold no more gems.")
            return false
        end

        local inven = self:getInven("INVEN")

        self:showInventory("Select a gem to swallow.", inven, function(o) return o.type == "gem" and o.material_level and o.material_level <= t.allowed_tier(self, t) end, function(o, item)
            if self:canAddToInven("SWALLOWED_GEMS") then
                o = self:removeObject(inven, item)

                -- Force "wield"
                self:addObject(gems, o)
                game.logSeen(self, "%s swallows %s.", self.name:capitalize(), o:getName{do_color=true}:a_an())

                self:sortInven()
                return true
            else
                game.logSeen(self, "Your stomach can hold no more gems.")
                return false
            end
        end)
    end,

    info = function(self, t)
        return ([[You swallow a gem up to tier %d and keep it in your stomach, deriving power from it just as an alchemist's golem would. At level 5, you can keep two gems in your stomach simultaneously.]]):
                format(t.allowed_tier(self, t))
    end,
}

newTalent{
    name = "Consume Artifact",
    type = {"gluttony/pica", 4},
    require = lvl_req4,
    points = 5,

    allowed_tier = function(self, t) return self:getTalentLevelRaw(t) end,

    action = function(self, t)
        local inven = self:getInven("INVEN")
        self:showInventory("Select an artifact to consume.", inven, function(o) return o.unique and not o.plot and o.material_level and o.material_level <= t.allowed_tier(self, t) end, function(o, item)
            o = self:removeObject(inven, item)

            game.logSeen(self, "%s consumes %s.", self.name:capitalize(), o.name)

            if o.power_source then
                for source, is_source in pairs(o.power_source) do
                    if is_source then
                        if source == "arcane" then
                            local spellpower_gain = 1*o.material_level
                            self.combat_spellpower = self.combat_spellpower + spellpower_gain
                            game.logSeen(self, ("%s gained %d spellpower."):format(self.name, spellpower_gain))
                        elseif source == "nature" then
                            local resist_gain = 1*o.material_level
                            local resist = rng.table({"ACID", "NATURE", "BLIGHT"})
                            self.resists[DamageType[resist]] = (self.resists[DamageType[resist]] or 0) + 1*o.material_level
                            game.logSeen(self, ("%s gained %d %s resistance."):format(self.name, resist_gain, string.lower(resist)))
                        elseif source == "technique" then
                            local physpower_gain = 1*o.material_level
                            self.combat_dam = self.combat_dam + physpower_gain
                            game.logSeen(self, ("%s gained %d physical power."):format(self.name, physpower_gain))
                        elseif source == "psionic" then
                            local mindpower_gain = 1*o.material_level
                            local mental_save_gain = 1*o.material_level
                            self.combat_mindpower = self.combat_mindpower + mindpower_gain
                            self.combat_mentalresist = self.combat_mentalresist + mental_save_gain
                            game.logSeen(self, ("%s gained %d mindpower and %d mental save."):format(self.name, mindpower_gain, mental_save_gain))
                        elseif source == "antimagic" then
                            local resist_gain = 1*o.material_level
                            local spell_save_gain = 1*o.material_level
                            self.resists[DamageType.ARCANE] = (self.resists[DamageType.ARCANE] or 0) + resist_gain
                            self.combat_spellresist = self.combat_spellresist + spell_save_gain
                            game.logSeen(self, ("%s gained %d arcane resistance and %d spell save."):format(self.name, resist_gain, spell_save_gain))
                        elseif source == "unknown" then
                            local resist_gain = 1*o.material_level
                            self.resists.all = self.resists.all + resist_gain
                            game.logSeen(self, ("%s gained +%d to all resistances."):format(self.name, resist_gain))
                        end
                    end
                end
            end

            self:sortInven()
            return true
        end)
    end,

    info = function(self, t)
        return ([[You eat an artifact item up to tier %d, gaining permanent bonuses based on the artifact's tier and power source(s).]]):
                format(t.allowed_tier(self, t))
    end,
}
