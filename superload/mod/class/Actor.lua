_M = loadPrevious(...)
base_learnPool = _M.learnPool
base_onStatChange = _M.onStatChange
base_die = _M.die

function _M:learnPool(t)
	if t.type[1]:find("^gluttony/") --[[and not self:knowTalent(self.T_HUNGER_POOL)]] then
		self:checkPool(t.id, self.T_HUNGER_POOL)
		--self:learnTalent(self.T_HUNGER_POOL, true)
		--self.resource_pool_refs[self.T_HUNGER_POOL] = (self.resource_pool_refs[self.T_HUNGER_POOL] or 0) + 1
	end

	base_learnPool(self, t)
end

function _M:onStatChange(stat, v)
	base_onStatChange(self, stat, v)

	if stat == self.STAT_CON then
		-- hunger
		if self:knowTalent(self.T_HUNGER_POOL) then
			self:getTalentFromId(self.T_HUNGER_POOL).onStatChange(self)
		end

		-- make sure these match glutton.lua
		self.max_talents = math.ceil(self:getCon()/4) -- max number of talents learned from Digestion
		self.max_total_talent_level = math.ceil(self:getCon()) -- max total level of talents learned from Digestion
	end
end

function _M:die(src, death_note)
    if src and src.knowTalent and src.T_VORACITY and src:knowTalent(src.T_VORACITY) and src:isTalentActive(src.T_VORACITY) then
        local DamageType = require "engine.DamageType"
        DamageType:get(DamageType.DEVOUR).projector(src, self.x, self.y, DamageType.DEVOUR, {["power"] = 100, ["dying"] = true}) -- "src" devours "self"
    end

    base_die(self, src, death_note)
end

return _M
