newBirthDescriptor{
    type = "subclass",
    name = "Glutton",
    desc = {
        "Gluttons are those who, through some hedonistic overindulgence, have been cursed to suffer eternally from insatiable hunger.",
        "They wander, attempting in vain to satiate the gnawing sensation within them.",
        "Their Hunger increases constantly, satiated only by Devouring those in their path.",
        "As they hunger more intensely, they become weaker. As their hunger is satiated, their power increases.",
        "They become physically ill as they starve, decreasing their life regeneration and even causing their body to deteriorate.",
        "When they Devour powerful enemies, they absorb some of that power, gaining new abilities.",
        "Their Constitution is vital to their continued survival.",
        "#GOLD#Stat modifiers:",
        "#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +5 Constitution",
        "#LIGHT_BLUE# * +0 Magic, +0 Willpower, +0 Cunning",
        "#GOLD#Life per level:#LIGHT_BLUE# +3",
    },
    not_on_random_boss = true,
    getStatDesc = function(stat, actor)
        if stat == actor.STAT_CON then
            local num_digested_talents = 0
            local total_talent_level = 0
            if actor.digested_talents then
                for id, level in pairs(actor.digested_talents) do
                    num_digested_talents = num_digested_talents + 1
                    total_talent_level = total_talent_level + level
                end
            end

            -- make sure these match Actor.lua
            return ([[Current number of Digested talents: %d
Maximum number of Digested talents: %d
Current total level of Digested talents: %d
Maximum total level of Digested talents: %d]]):
            format (num_digested_talents,
                    math.ceil(actor:getCon()/4),
                    total_talent_level,
                    math.ceil(actor:getCon())
                    )
        end
    end,
    stats = { con=5 },
    talents_types = {
        ["gluttony/famine"]={true, 0.3},
        ["gluttony/digestion"]={true, 0.3},
        ["gluttony/feast"]={true, 0.3},
        ["gluttony/pica"]={true, 0.3},
        ["cursed/endless-hunt"]={true, 0.0},
        ["cursed/predator"]={true, 0.0},
        ["cursed/cursed-form"]={true, 0.0},
        ["technique/combat-training"]={true, 0.0},
    },
    talents = {
        T_DEVOUR = 1,
        T_DIGEST = 1,
    },
    copy = {
        max_life = 120,
        --unused_stats = 10,
        resolvers.equip{
            id=true,
            {type="weapon", subtype="waraxe", name="iron waraxe", autoreq=true, ego_chance=-1000},
            {type="armor", subtype="light", name="rough leather armour", autoreq=true,ego_chance=-1000},
        },
        chooseCursedAuraTree = true,
        --[[ removed in 0.0.7
        no_points_on_levelup = function(self)
            self.unused_stats = self.unused_stats + 0
            self.unused_talents = self.unused_talents + 1
            self.unused_generics = self.unused_generics + 1
            if self.level % 5 == 0 then
                self.unused_talents = self.unused_talents + 1
                self.unused_generics = self.unused_generics - 1
            end
            if self.level == 10 or self.level == 20 or self.level == 36 then
                self.unused_talents_types = self.unused_talents_types + 1
            end
            if self.level == 30 or self.level == 42 then
                self.unused_prodigies = self.unused_prodigies + 1
            end
        end,
        --]]
    },
    copy_add = {
        life_rating = 3,
    },
}

-- Add to Afflicted
getBirthDescriptor("class", "Afflicted").descriptor_choices.subclass["Glutton"] = "allow"
