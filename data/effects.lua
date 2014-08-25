newEffect{
	name = "EAT_WALLS", image = "talents/eat_walls.png",
	desc = "Eat Walls",
	long_desc = function(self, eff) return "The target is able to eat through walls." end,
	type = "physical",
	subtype = { earth=true },
	status = "beneficial",
	parameters = { satiation=1 },
	activate = function(self, eff)
		eff.pass = self:addTemporaryValue("can_pass", {pass_wall=1, pass_tree=1})
		eff.dig = self:addTemporaryValue("move_project", {[DamageType.EAT_WALLS]=1})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("can_pass", eff.pass)
		self:removeTemporaryValue("move_project", eff.dig)
	end,
}

newEffect{
	name = "DIGESTING", image = "talents/digest.png",
	desc = "Digesting",
	long_desc = function(self, eff) return ("You are digesting %s."):format(eff.digested_creature.name) end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "detrimental",
	no_stop_enter_worlmap = true,
	parameters = {},
	
	activate = function(self, eff)
		eff.digested_creature = table.remove(self.creatures_devoured, 1) -- FIFO
	end,

	deactivate = function(self, eff)
		local contains = function(t, value)
			for k,v in pairs(t) do
				if v==value then return v end
			end
			return nil
		end
		
		local copy = function(t)
			local t2 = {}
				for k,v in pairs(t) do
					t2[k] = v
				end
			return t2
		end
		
		game.logSeen(self, "%s has been digested.", eff.digested_creature.name:capitalize())
		
		--[[ removed in 0.0.7
		
		-- stat point gain

		local rank = eff.digested_creature.rank
		local stat_pts = 0 -- # of stat points to gain
		
		if rank == 1 then -- critter
		elseif rank == 2 then -- normal
		elseif rank == 3 then -- elite
		elseif rank == 3.2 then -- rare
			if math.random() < 0.4 then stat_pts = 1 end -- 2/5 chance of getting a stat point
		elseif rank == 3.5 then -- randbosses and uniques
			stat_pts = 2
		elseif rank == 4 then -- boss
			stat_pts = 3
		elseif rank == 5 then -- elite boss
			stat_pts = 3
		end
		
		if stat_pts > 0 then
			self.unused_stats = self.unused_stats + stat_pts
			game.logSeen(self, ("%s gained %d stat points."):format(self.name, stat_pts))
		end
		
		-- end stat point gain
		
		--]]
		
		-- talent gain
		
		-- talents we shouldn't learn
		local talents_to_exclude = {
			"T_TELEKINETIC_GRASP", -- requires Beyond the Flesh
			-- we can still learn these (if they're not here) for some reason
			"T_SHOOT",
			"T_RELOAD",
			-- these are enemy-only
			"T_SUMMON",
			"T_SHRIEK",
			"T_HOWL",
			"T_MULTIPLY",
			"T_SHADOW_PHASE_DOOR",
			"T_SHADOW_BLINDSIDE",
			"T_DREDGE_FRENZY",
			-- can't be frenzied
			"T_FRENZIED_LEAP",
			"T_FRENZIED_BITE",
		}
		for id, talent in pairs(self.talents_def) do
			if talent.type[1]:find("^base/")
			or talent.type[1]:find("^inscriptions/")
			or talent.type[1]:find("^uber/")
			or talent.type[1]:find("^race/")
			or talent.type[1]:find("^undead/")
			or talent.type[1]:find("objects")
			or talent.type[1]:find("golemancy")
			or talent.type[1]:find("golem/golem") then
				table.insert(talents_to_exclude, id)
			end
		end

		local t_ids = {}
		-- make a table of the IDs of all the creature's learnable talents
		for t_id, t_level in pairs(eff.digested_creature.talents) do
			if not contains(talents_to_exclude, t_id) then
				local t = self:getTalentFromId(t_id)
				
				if self:getTalentLevel(t) >= eff.digested_creature:getTalentLevel(t) then
					game.logSeen(self, ("You already know %s better than %s."):format(t.name, eff.digested_creature.name))
				elseif self:getTalentLevel(t) >= math.ceil(self:getTalentLevelRaw(self:getTalentFromId(self.T_DIGEST))) then
					game.logSeen(self, ("%s is already at the maximum level allowed."):format(t.name))
				else
					table.insert(t_ids, t_id)
				end
			end
		end
		
		local t_id = nil
		
		if #t_ids > 0 then -- if there is at least one learnable talent
			t_id = t_ids[math.random(#t_ids)] -- pick a random learnable talent
		end
		
		if t_id then -- if we picked a talent to learn
			local t = self:getTalentFromId(t_id) -- the actual talent table
			
			-- this table is used to keep track of how many talents we have and how many levels of each we have learned
			self.digested_talents = self.digested_talents or {}
		
			-- calculate our current numbers
			local num_digested_talents = 0
			local total_talent_level = 0
			for id, level in pairs(self.digested_talents) do
				num_digested_talents = num_digested_talents + 1
				total_talent_level = total_talent_level + level
			end
			
			-- learn the talent if we can
			if num_digested_talents < self.max_talents then
				if total_talent_level < self.max_total_talent_level then       
					self.digested_talents[t_id] = (self.digested_talents[t_id] or 0) + 1
					self:learnTalent(t_id, true)
					game.logSeen(self, ("%s learned %s!"):format(self.name, t.name))
				else
					game.logSeen(self, "You cannot memorize any more talent levels. Forget talents you already know if you want to learn more levels.")
				end
			else
				game.logSeen(self, "You cannot memorize any more talents. Forget ones you already know if you want to learn more.")
			end

			--[[ perhaps for a future update
			-- learn talent type at 1.00 mastery if we don't know it
			local tt = t.type[1]
			if not self:knowTalentType(tt) then
				local tt_def = self:getTalentTypeFrom(tt)
				local cat = tt_def.type:gsub("/.*", "")
				self:learnTalentType(tt, false)
				self:setTalentTypeMastery(tt, 1.00)
				game.logSeen(self, ("%s learned talent category %s!"):format(self.name, cat:capitalize().." / "..tt_def.name:capitalize()))
			else -- we already know the talent type; add 0.02 mastery
				mastery_add = 0.02
				self:setTalentTypeMastery(tt, self:getTalentTypeMastery(tt) + mastery_add)
				game.logSeen(self, ("%s gained %.2f mastery in talent category %s!"):format(self.name, mastery_add, cat:capitalize().." / "..tt_def.name:capitalize()))
			end
			--]]
		end
		
		-- end talent gain
		
		eff.digested_creature = nil
	end,
}

newEffect{
	name = "NUTRITION", image = "talents/catabolize.png",
	desc = "Nutrition",
	long_desc = function(self, eff) return ("You have absorbed nutrients from %s, gaining %d %s."):format(eff.creature_name, eff.amt, eff.stat) end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "beneficial",
	parameters = {creature_name="None", amt=1, num=1, stat="STR"},
	
	activate = function(self, eff)
		local Stats = require "engine.interface.ActorStats"
		eff.stat_gain_id = self:addTemporaryValue("inc_stats", { [Stats["STAT_"..eff.stat]] = eff.amt })
	end,

	deactivate = function(self, eff)
		if eff.stat_gain_id then
			self:removeTemporaryValue("inc_stats", eff.stat_gain_id)
		end
	end,
}

newEffect{
	name = "ARCANE_NUTRITION", image = "talents/catabolize.png",
	desc = "Arcane Nutrition",
	long_desc = function(self, eff) return ("You have absorbed nutrients from %s, gaining %d spellpower."):format(eff.item_name, eff.spellpower_gain, eff.resist_gain) end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "beneficial",
	parameters = {item_name="None", item_tier=1},
	
	activate = function(self, eff)
		eff.spellpower_gain = 3*eff.item_tier
		eff.spellpower_gain_id = self:addTemporaryValue("combat_spellpower", eff.spellpower_gain)
	end,

	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_spellpower", eff.spellpower_gain_id)
	end,
}

newEffect{
	name = "NATURE_NUTRITION", image = "talents/catabolize.png",
	desc = "Natural Nutrition",
	long_desc = function(self, eff) return ("You have absorbed nutrients from %s, gaining %d acid, nature, and blight resistance."):format(eff.item_name, eff.resist_gain) end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "beneficial",
	parameters = {item_name="None", item_tier=1},
	
	activate = function(self, eff)
		eff.resist_gain = 2*eff.item_tier
		eff.resist_gain_id = self:addTemporaryValue("resists", {[DamageType.ACID]=eff.resist_gain, [DamageType.NATURE]=eff.resist_gain, [DamageType.BLIGHT]=eff.resist_gain})
	end,

	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.resist_gain_id)
	end,
}

newEffect{
	name = "TECHNIQUE_NUTRITION", image = "talents/catabolize.png",
	desc = "Skill Nutrition",
	long_desc = function(self, eff) return ("You have absorbed nutrients from %s, gaining %d physical power, %d accuracy, and %d physical resistance."):format(eff.item_name, eff.physpower_gain, eff.acc_gain, eff.resist_gain) end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "beneficial",
	parameters = {item_name="None", item_tier=1},
	
	activate = function(self, eff)
		eff.physpower_gain = 2*eff.item_tier
		eff.physpower_gain_id = self:addTemporaryValue("combat_dam", eff.physpower_gain)
		eff.acc_gain = 3*eff.item_tier
		eff.acc_gain_id = self:addTemporaryValue("combat_atk", eff.acc_gain)
		eff.resist_gain = 2*eff.item_tier
		eff.resist_gain_id = self:addTemporaryValue("resists", {[DamageType.PHYSICAL]=eff.resist_gain})
	end,

	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.physpower_gain_id)
		self:removeTemporaryValue("combat_atk", eff.acc_gain_id)
		self:removeTemporaryValue("resists", eff.resist_gain_id)
	end,
}

newEffect{
	name = "PSIONIC_NUTRITION", image = "talents/catabolize.png",
	desc = "Psionic Nutrition",
	long_desc = function(self, eff) return ("You have absorbed nutrients from %s, gaining %d mindpower and %d mental save."):format(eff.item_name, eff.mindpower_gain, eff.save_gain) end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "beneficial",
	parameters = {item_name="None", item_tier=1},
	
	activate = function(self, eff)
		eff.mindpower_gain = 2*eff.item_tier
		eff.mindpower_gain_id = self:addTemporaryValue("combat_mindpower", eff.mindpower_gain)
		eff.save_gain = 3*eff.item_tier
		eff.save_gain_id = self:addTemporaryValue("combat_mentalresist", eff.save_gain)
	end,

	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_mindpower", eff.mindpower_gain_id)
		self:removeTemporaryValue("combat_mentalresist", eff.save_gain_id)
	end,
}

newEffect{
	name = "ANTIMAGIC_NUTRITION", image = "talents/catabolize.png",
	desc = "Antimagical Nutrition",
	long_desc = function(self, eff) return ("You have absorbed nutrients from %s, gaining %d arcane resistance and %d spell save."):format(eff.item_name, eff.resist_gain, eff.save_gain) end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "beneficial",
	parameters = {item_name="None", item_tier=1},
	
	activate = function(self, eff)
		eff.resist_gain = 2*eff.item_tier
		eff.resist_gain_id = self:addTemporaryValue("resists", {[DamageType.ARCANE]=eff.resist_gain})
		eff.save_gain = 3*eff.item_tier
		eff.save_gain_id = self:addTemporaryValue("combat_spellresist", eff.save_gain)
	end,

	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.resist_gain_id)
		self:removeTemporaryValue("combat_spellresist", eff.save_gain_id)
	end,
}

newEffect{
	name = "UNKNOWN_NUTRITION", image = "talents/catabolize.png",
	desc = "Mysterious Nutrition",
	long_desc = function(self, eff) return ("You have absorbed nutrients from %s, gaining +%d to all resistances."):format(eff.item_name, eff.resist_gain) end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "beneficial",
	parameters = {item_name="None", item_tier=1},
	
	activate = function(self, eff)
		eff.resist_gain = 2*eff.item_tier
		eff.resist_gain_id = self:addTemporaryValue("resists", {all=eff.resist_gain})
	end,

	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.resist_gain_id)
	end,
}

newEffect{
	name = "SALIVATED", image = "talents/salivate.png",
	desc = "Saliva",
	long_desc = function(self, eff) return ("%s has been salivated upon and is prone to being devoured."):format(self.name:capitalize()) end,
	type = "physical",
	subtype = { miscellaneous=true },
	status = "detrimental",
	parameters = { bonus=1 },
}

newEffect{
	name = "APPETIZER", image = "talents/whet_appetite.png",
	desc = "Appetizer",
	long_desc = function(self, eff) return ("You have whetted your appetite on %s, increasing your chance to devour it."):format(self.name:capitalize()) end,
	type = "physical",
	subtype = { miscellaneous=true },
	status = "detrimental",
	parameters = { bonus=1 },
}
