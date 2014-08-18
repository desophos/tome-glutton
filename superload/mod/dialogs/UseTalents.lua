_M = loadPrevious(...)

local Dialog = require "engine.ui.Dialog"
local confirmMark = require("engine.Entity").new({image="ui/chat-icon.png"})
local autoMark = require("engine.Entity").new({image = "/ui/hotkeys/mainmenu.png"})

-- add an "unlearn" option

function _M:use(item, button)
	if not item or not item.talent then return end
	local t = self.actor:getTalentFromId(item.talent)
	--if t.mode == "passive" then return end
	if button == "right" then
		local list = {
			{name="Unbind", what="unbind"},
			{name="Bind to left mouse click (on a target)", what="left"},
			{name="Bind to middle mouse click (on a target)", what="middle"},
		}
--
		if self.actor.digested_talents and self.actor.digested_talents[item.talent] then
			table.insert(list, 1, {name="Permanently unlearn", what="unlearn"})
		end
--
		if self.actor:isTalentConfirmable(t) then
			table.insert(list, 1, {name="#YELLOW#Disable talent confirmation", what="unset-confirm"})
		else
			table.insert(list, 1, {name=confirmMark:getDisplayString().."Request confirmation before using this talent", what="set-confirm"})
		end
		local automode = self.actor:isTalentAuto(t)
		local ds = "#YELLOW#Disable "
		table.insert(list, 2, {name=autoMark:getDisplayString()..(automode==1 and ds or "").."Auto-use when available", what=(automode==1 and "auto-dis" or "auto-en-1")})
		table.insert(list, 2, {name=autoMark:getDisplayString()..(automode==2 and ds or "").."Auto-use when no enemies are visible", what=(automode==2 and "auto-dis" or "auto-en-2")})
		table.insert(list, 2, {name=autoMark:getDisplayString()..(automode==3 and ds or "").."Auto-use when enemies are visible", what=(automode==3 and "auto-dis" or "auto-en-3")})
		table.insert(list, 2, {name=autoMark:getDisplayString()..(automode==4 and ds or "").."Auto-use when enemies are visible and adjacent", what=(automode==4 and "auto-dis" or "auto-en-4")})

		for i = 1, 12 * self.actor.nb_hotkey_pages do list[#list+1] = {name="Hotkey "..i, what=i} end
		Dialog:listPopup("Bind talent: "..item.name:toString(), "How do you want to bind this talent?", list, 400, 500, function(b)
			if not b then return end
			if type(b.what) == "number" then
				for i = 1, 12 * self.actor.nb_hotkey_pages do
					if self.actor.hotkey[i] and self.actor.hotkey[i][1] == "talent" and self.actor.hotkey[i][2] == item.talent then self.actor.hotkey[i] = nil end
				end
				self.actor.hotkey[b.what] = {"talent", item.talent}
				self:simplePopup("Hotkey "..b.what.." assigned", self.actor:getTalentFromId(item.talent).name:capitalize().." assigned to hotkey "..b.what)
--
			elseif b.what == "unlearn" then
				self.actor:unlearnTalent(item.talent, self.actor.digested_talents[item.talent]) -- unlearn the number of levels we have digested
				self:simplePopup("Talent unlearned", "All levels of "..self.actor:getTalentFromId(item.talent).name:capitalize().." learned from Digestion have been forgotten.")
				self.actor.digested_talents[item.talent] = nil
--
			elseif b.what == "middle" then
				self.actor.auto_shoot_midclick_talent = item.talent
				self:simplePopup("Middle mouse click assigned", self.actor:getTalentFromId(item.talent).name:capitalize().." assigned to middle mouse click on an hostile target.")
			elseif b.what == "left" then
				self.actor.auto_shoot_talent = item.talent
				self:simplePopup("Left mouse click assigned", self.actor:getTalentFromId(item.talent).name:capitalize().." assigned to left mouse click on an hostile target.")
			elseif b.what == "unbind" then
				if self.actor.auto_shoot_talent == item.talent then self.actor.auto_shoot_talent = nil end
				if self.actor.auto_shoot_midclick_talent == item.talent then self.actor.auto_shoot_midclick_talent = nil end
				for i = 1, 12 * self.actor.nb_hotkey_pages do
					if self.actor.hotkey[i] and self.actor.hotkey[i][1] == "talent" and self.actor.hotkey[i][2] == item.talent then self.actor.hotkey[i] = nil end
				end
			elseif b.what == "set-confirm" then
				self.actor:setTalentConfirmable(item.talent, true)
			elseif b.what == "unset-confirm" then
				self.actor:setTalentConfirmable(item.talent, false)
			elseif b.what == "auto-en-1" then
				self.actor:checkSetTalentAuto(item.talent, true, 1)
			elseif b.what == "auto-en-2" then
				self.actor:checkSetTalentAuto(item.talent, true, 2)
			elseif b.what == "auto-en-3" then
				self.actor:checkSetTalentAuto(item.talent, true, 3)
			elseif b.what == "auto-en-4" then
				self.actor:checkSetTalentAuto(item.talent, true, 4)
			elseif b.what == "auto-dis" then
				self.actor:checkSetTalentAuto(item.talent, false)
			end
			self.c_list:drawTree()
			self.actor.changed = true
		end)
		self.c_list:drawTree()
		return
	end

	game:unregisterDialog(self)
	self.actor:useTalent(item.talent)
end

return _M
