--[[
+-------------------------------------------------------------------------------------------------------+
| cdtweaks: whenever a stoneskinned creature gets hit, inform the player about the number of skins left |
+-------------------------------------------------------------------------------------------------------+
--]]

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual condition
	local apply = function()
		-- Mark the creature as 'condition applied'
		sprite:setLocalInt("gtDisplayStoneskinsLeft", 1)
		--
		local effectCodes = {
			{["op"] = 0x141}, -- Remove effects by resource (321)
			{["op"] = 0xE8}, -- Cast spell on condition (232)
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["durationType"] = 1,
				["res"] = "GTSTNSKN",
				["m_sourceRes"] = "GTSTNSKN",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	-- Check if the creature is stoneskinned
	local applyCondition = sprite.m_derivedStats.m_nStoneSkins > 0 -- at least one skin
	--
	if sprite:getLocalInt("gtDisplayStoneskinsLeft") == 0 then
		if applyCondition then
			apply()
		end
	else
		if applyCondition then
			-- do nothing
		else
			-- Mark the creature as 'condition removed'
			sprite:setLocalInt("gtDisplayStoneskinsLeft", 0)
			--
			sprite:applyEffect({
				["effectID"] = 0x141, -- Remove effects by resource (321)
				["res"] = "GTSTNSKN",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- op402 listener --

function GTSTNSKN(CGameEffect, CGameSprite)
	local m_lHitter = EEex_GameObject_Get(CGameSprite.m_lHitter.m_Instance) -- CGameSprite
	-- sanity check
	if m_lHitter ~= nil then
		local skins = {}
		-- ignore non-weapon attacks
		if m_lHitter.m_targetId == CGameSprite.m_id then
			EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, function(effect)
				if effect.m_effectId == 0xDA then -- Stoneskin effect (218)
					table.insert(skins, effect.m_effectAmount)
				end
			end)
			--
			Infinity_DisplayString(CGameSprite:getName() .. Infinity_FetchString(%feedback_strref_stoneskin%) .. GT_LuaTool_FindGreatestInt(skins) .. Infinity_FetchString(%feedback_strref_skins_left%))
		end
	end
end
