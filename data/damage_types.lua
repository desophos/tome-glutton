-- pull; --checks for attack power against physical resistance
newDamageType{
    name = "pull", type = "PULL",
    projector = function(src, x, y, type, dam, tmp)
        local target = game.level.map(x, y, Map.ACTOR)
        tmp = tmp or {}
        if _G.type(dam) ~= "table" then dam = {dam=dam, dist=3} end
        if target and not tmp[target] then
            tmp[target] = true
            --if target:checkHit(src:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
            if target:canBe("knockback") then
                target:pull(dam.x or src.x, dam.y or src.y, dam.dist)
                target:crossTierEffect(target.EFF_OFFBALANCE, src:combatPhysicalpower())
                game.logSeen(target, "%s is pulled in!", target.name:capitalize())
            else
                game.logSeen(target, "%s resists the pull!", target.name:capitalize())
            end
        end
    end,
}

newDamageType{
    name = "eat_walls", type = "EAT_WALLS",
    projector = function(src, x, y, typ, dam)
        local feat = game.level.map(x, y, Map.TERRAIN)
        if feat then
            if feat.dig then
                local newfeat_name, newfeat, silence = feat.dig, nil, false
                if type(feat.dig) == "function" then newfeat_name, newfeat, silence = feat.dig(src, x, y, feat) end
                game.level.map(x, y, Map.TERRAIN, newfeat or game.zone.grid_list[newfeat_name])
                src.dug_times = (src.dug_times or 0) + 1
                game.nicer_tiles:updateAround(game.level, x, y)
                if not silence then
                    game.logSeen({x=x,y=y}, "%s turns into %s.", feat.name:capitalize(), (newfeat or game.zone.grid_list[newfeat_name]).name)
                end

                local eff = src:hasEffect(src.EFF_EAT_WALLS)
                if eff then
                    src:getTalentFromId(src.T_HUNGER_POOL).customIncHunger(src, -eff.satiation)
                end
            end
        end
    end,
}

newDamageType{
    name = "eat_resources", type = "EAT_RESOURCES", text_color = "#GREY#",
    projector = function(src, x, y, type, dam)
        local target = game.level.map(x, y, Map.ACTOR)
        if target then
            local inc = function(actor, res, amt)
                if actor:knowTalent(actor["T_"..(res):upper().."_POOL"]) then
                    oldres = actor[res]
                    actor[res] = actor[res] + amt
                    return math.abs(actor[res] - oldres)
                else return 0
                end
            end

            local resource_shortnames = {"stamina", "mana", "vim", "positive", "negative", "hate", "psi"}
            local resource_longnames = {"stamina", "mana", "vim", "positive energy", "negative energy", "hate", "psi"}
            local total = 0

            for i, resource in ipairs(resource_shortnames) do
                local amt = inc(target, resource, -dam)
                if amt ~= 0 then
                    game.logSeen(game.player, ("%s devoured %d of %s's %s!"):format(src.name, amt, target.name, resource_longnames[i]))
                    total = total + amt
                end
            end

            src:getTalentFromId(src.T_HUNGER_POOL).customIncHunger(src, -total)
        end
        return 0
    end,
}

newDamageType{
    name = "absorb_resources", type = "ABSORB_RESOURCES",
    projector = function(src, x, y, type, absorb_percent)
        local target = game.level.map(x, y, Map.ACTOR)
        if target then
            local inc = function(actor, res, percent)
                if actor:knowTalent(actor["T_"..(res):upper().."_POOL"]) then
                    oldres = actor[res]
                    actor[res] = actor[res] + ((percent/100) * actor[res])
                    return math.abs(actor[res] - oldres)
                else return 0
                end
            end

            local resource_shortnames = {"stamina", "mana", "vim", "positive", "negative", "hate", "psi"}
            local resource_longnames = {"stamina", "mana", "vim", "positive energy", "negative energy", "hate", "psi"}

            for i, resource in ipairs(resource_shortnames) do
                local amt = inc(target, resource, -absorb_percent)
                if amt ~= 0 and src:knowTalent(src["T_"..(resource):upper().."_POOL"]) then
                    game.logSeen(game.player, ("%s absorbed %d of %s's %s!"):format(src.name, amt, target.name, resource_longnames[i]))
                    src[resource] = src[resource] + amt
                end
            end
        end
    end
}

newDamageType{
    name = "salivate", type = "SALIVATE",
    projector = function(src, x, y, type, dam)
        local target = game.level.map(x, y, Map.ACTOR)
        if target then
            target:setEffect(target.EFF_SALIVATED, math.ceil(dam.bonus_duration), {bonus=dam.bonus})
            if target:canBe("stun") then
                target:setEffect(target.EFF_DAZED, math.ceil(dam.daze_duration), {apply_power=dam.daze_power})
            end
        end
    end,
}

newDamageType{
    name = "whet appetite", type = "WHET_APPETITE",
    projector = function(src, x, y, type, dam)
        local target = game.level.map(x, y, Map.ACTOR)
        if target then
            target:setEffect(target.EFF_APPETIZER, math.ceil(dam.dur), {bonus=dam.bonus})

            -- remove positive effects, this is stolen straight from the wild infusion code
            effs = {}
            -- iterate through positive effects
            for eff_id, p in pairs(target.tmp) do
                local e = target.tempeffect_def[eff_id]
                if e.status == "beneficial" then
                    effs[#effs+1] = {"effect", eff_id}
                end
            end
            -- remove dam.buffs_consumed positive effects
            for _ = 1, dam.buffs_consumed do
                if #effs == 0 then break end
                local eff = rng.tableRemove(effs)

                if eff[1] == "effect" then
                    target:removeEffect(eff[2])
                end
            end
        end
    end,
}

newDamageType{
    name = "devour", type = "DEVOUR",
    projector = function(src, x, y, type, dam)
        local target = game.level.map(x, y, Map.ACTOR)
        if target then
            if (target.life*100 / target.max_life) > dam.power then
                game.logSeen(target, "%s resists %s's Devour attempt.", target.name:capitalize(), src.name)
            elseif --[[target:canBe("instakill") and ]]not target:attr("self_resurrect") then
                local DamageType = require "engine.DamageType"
                local satiation = 2 * target.size_category

                game.logSeen(src, "%s devours %s!", src.name:capitalize(), target.name)
                src:getTalentFromId(src.T_HUNGER_POOL).customIncHunger(src, -satiation)

                -- "Devouring Enthusiasm" from Gourmand tree
                if src.devour_resource_gain then
                    DamageType:get(DamageType.ABSORB_RESOURCES).projector(src, x, y, DamageType.ABSORB_RESOURCES, src.devour_resource_gain)
                end

                if not src.creatures_devoured then src.creatures_devoured = {} end
                table.insert(src.creatures_devoured, target:clone())

                -- instakill target; dam.dying is a hack for when we call from die()
                if not target.dead and not dam.dying then target:die(src) end
            else
                game.logSeen(target, "%s cannot be Devoured!", target.name:capitalize())
            end
        end
    end,
}
