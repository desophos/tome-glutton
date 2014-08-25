local ActorTalents = require "engine.interface.ActorTalents"
local Birther = require "engine.Birther"
local Effects = require "engine.interface.ActorTemporaryEffects"
local DamageType = require "engine.DamageType"
local ActorResource = require "engine.interface.ActorResource"
local ActorInventory = require "engine.interface.ActorInventory"

ActorResource:defineResource("Hunger", "hunger", ActorTalents.T_HUNGER_POOL, "hunger_regen", "Hunger is your level of starvation. It increases over time.")
ActorInventory:defineInventory("SWALLOWED_GEMS", "Swallowed Gems", true, "Swallowed gems.")

class:bindHook("ToME:load", function(self, data)
    ActorTalents:loadDefinition("/data-glutton/talents/gluttony.lua")
    Birther:loadDefinition("/data-glutton/birth/glutton.lua")
    Effects:loadDefinition("/data-glutton/effects.lua")
    DamageType:loadDefinition("/data-glutton/damage_types.lua")
end)

class:bindHook("DamageProjector:final", function(self, data)
    local actor = data.src
    local x, y = data.x, data.y

    if actor.on_hit_hunger_cost then
        actor:getTalentFromId(actor.T_HUNGER_POOL).customIncHunger(actor, actor.on_hit_hunger_cost)
    end

    if actor.on_hit_devour_chance and math.random() < actor.on_hit_devour_chance then
        DamageType:get(DamageType.DEVOUR).projector(actor, x, y, DamageType.DEVOUR) -- actor devours target
    end
end)

class:bindHook("Actor:postUseTalent", function(self, data)
    local hunger = data.t.hunger
    local t = self:getTalentFromId(self.T_HUNGER_POOL)
    if hunger and t then
        t.customIncHunger(self, -hunger) -- so positive hunger in a talent means hunger decrease; this is the way all resources work in talents
    end
end)

-- yes, 'resources' is spelled incorrectly
class:bindHook("Actor:getTalentFullDescription:ressources", function(self, data)
    local t = data.t
    local str = data.str
    if t.hunger then str:add({"color",0x6f,0xff,0x83}, "Satiation: ", {"color",0x8B,0x69,0x14}, ""..(t.hunger * (self.hunger_cost_mod or 1)), true) end
end)

class:bindHook("UISet:Classic:display", function(self, data)
    local player = game.player
    local h = data.h
    local x = data.x
    if not x or not h then return end
    if player:knowTalent(player.T_HUNGER_POOL) then
        self:mouseTooltip(self.TOOLTIP_HUNGER, self:makeTextureBar("#7fffd4#Hunger:", nil, player:getHunger(), player.max_hunger, player.hunger_regen or 0, x, h, 255, 255, 255,
            {r=colors.UMBER.r / 2, g=colors.UMBER.g / 2, b=colors.UMBER.b / 2},
            {r=colors.UMBER.r / 5, g=colors.UMBER.g / 5, b=colors.UMBER.b / 5}
        )) data.h = h + self.font_h
    end
    return true
end)

local Shader = require "engine.Shader"

local hunger_c = {0x77/255, 0x55/255, 0x33/255} -- hexadecimal RGB values
local hunger_sha = Shader.new("resources", {require_shader=4, delay_load=true, color=hunger_c, speed=1000, distort={0.4,0.4}})

local fshat_hunger = {core.display.loadImage("/data/gfx/ui/resources/front_vim.png"):glTexture()}
local fshat_hunger_dark = {core.display.loadImage("/data/gfx/ui/resources/front_vim_dark.png"):glTexture()}

class:bindHook("UISet:Minimalist:Resources", function(self, data)
    local player = data.player
    -----------------------------------------------------------------------------------
    -- Hunger
    if player:knowTalent(player.T_HUNGER_POOL) and not player._hide_resource_hunger then
        local a = data.a
        local scale = data.scale
        local x, y = data.x, data.y
        local bx, by = data.bx, data.by

        self.sshat[1]:toScreenFull(x-6, y+8, self.sshat[6], self.sshat[7], self.sshat[2], self.sshat[3], 1, 1, 1, a)
        self.bshat[1]:toScreenFull(x, y, self.bshat[6], self.bshat[7], self.bshat[2], self.bshat[3], 1, 1, 1, a)
        if hunger_sha.shad then hunger_sha:setUniform("a", a) hunger_sha.shad:use(true) end
        local p = player:getHunger() / player.max_hunger
        self.shat[1]:toScreenPrecise(x+49, y+10, self.shat[6] * p, self.shat[7], 0, p * 1/self.shat[4], 0, 1/self.shat[5], hunger_c[1], hunger_c[2], hunger_c[3], a)
        if hunger_sha.shad then hunger_sha.shad:use(false) end

        if not self.res.hunger or self.res.hunger.vc ~= player.hunger or self.res.hunger.vm ~= player.max_hunger or self.res.hunger.vr ~= player.hunger_regen then
            self.res.hunger = {
                hidable = "Hunger",
                vc = player.hunger, vm = player.max_hunger, vr = player.hunger_regen,
                cur = {core.display.drawStringBlendedNewSurface(self.font_sha, ("%d/%d"):format(player.hunger, player.max_hunger), 255, 255, 255):glTexture()},
                regen={core.display.drawStringBlendedNewSurface(self.sfont_sha, ("%+0.2f"):format(player.hunger_regen), 255, 255, 255):glTexture()},
            }
        end
        local dt = self.res.hunger.cur
        dt[1]:toScreenFull(2+x+64, 2+y+10 + (self.shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7 * a)
        dt[1]:toScreenFull(x+64, y+10 + (self.shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 1, 1, 1, a)
        dt = self.res.hunger.regen
        dt[1]:toScreenFull(2+x+144, 2+y+10 + (self.shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 0, 0, 0, 0.7 * a)
        dt[1]:toScreenFull(x+144, y+10 + (self.shat[7]-dt[7])/2, dt[6], dt[7], dt[2], dt[3], 1, 1, 1, a)

        local front = fshat_hunger_dark
        if player.hunger >= player.max_hunger then front = fshat_hunger end
        front[1]:toScreenFull(x, y, front[6], front[7], front[2], front[3], 1, 1, 1, a)

        TOOLTIP_HUNGER = [[#GOLD#Hunger#LAST#
Hunger represents your level of starvation. It increases over time.
As you starve (increasing Hunger), your power and life regen decrease.
As you satiate yourself (decreasing Hunger), your power and life regen increase.
]]

        self:showResourceTooltip(bx+x*scale, by+y*scale, self.fshat[6], self.fshat[7], "res:hunger", self.TOOLTIP_HUNGER)
        data.x, data.y = self:resourceOrientStep(data.orient, data.bx, data.by, data.scale, data.x, data.y, front[6], front[7])
    elseif game.mouse:getZone("res:hunger") then
        game.mouse:unregisterZone("res:hunger")
    end
    return true
end)
