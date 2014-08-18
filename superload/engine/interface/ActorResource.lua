_M = loadPrevious(...)
base_regenResources = _M.regenResources

function _M:regenResources()
	base_regenResources(self)
	
	-- if we regen'd hunger, we have to call onChangingHunger
	if self:knowTalent(self.T_HUNGER_POOL) then
		self:getTalentFromId(self.T_HUNGER_POOL).onChangingHunger(self)
	end
end

return _M
