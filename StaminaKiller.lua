StaminaKiller = LibStub( "AceAddon-3.0" ):NewAddon( "StaminaKiller", "AceEvent-3.0", "AceConsole-3.0" )

local L = LibStub( "AceLocale-3.0" ):GetLocale( "StaminaKiller" )
local LBZ = LibStub( "LibBabble-Zone-3.0" ):GetLookupTable()

local playerId
local combatLogHooked = false

local buffsToRemove = {
	[48161] = true, -- Power Word: Fortitude (Rank 8)
	[48162] = true, -- Prayer of Fortitude (Rank 4)
	[47440] = true, -- Commanding Shout (Rank 3)
	[72590] = true, -- Stamina (from the scroll)
}

local spellsToWatch = {
	-- Lich King: Infest
	[73779] = true,
	[70541] = true,
	[73780] = true,
	[73781] = true,
--[===[@debug@
	[6117] = true, -- Mage Armor (Rank 1)
--@end-debug@]===]
}

function StaminaKiller:OnInitialize()
	for buffId, _ in pairs( buffsToRemove ) do
		buffsToRemove[buffId] = GetSpellInfo( buffId )
	end
	
	self:Print( L["Initialized."] )
end

function StaminaKiller:OnEnable()
	playerId = UnitGUID( "player" )
	combatLogHooked = false
	
	self:RegisterEvent( "ZONE_CHANGED_NEW_AREA" )
	self:ZONE_CHANGED_NEW_AREA()
end

function StaminaKiller:ZONE_CHANGED_NEW_AREA()
	local zoneName = GetRealZoneText()

--[===[@debug@
	if zoneName == LBZ["The Exodar"] then
		zoneName = LBZ["Icecrown Citadel"]
	end
--@end-debug@]===]

	if zoneName == LBZ["Icecrown Citadel"] then
		if not combatLogHooked then
			self:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" )
			combatLogHooked = true
			
			self:Print( L["In Icecrown Citadel - waiting for Infest."] )
		end
	else
		if combatLogHooked then
			self:UnregisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" )
			combatLogHooked = false
			
			self:Print( L["Out of Icecrown Citadel - combat log monitoring disabled."] )
		end
	end
end

function StaminaKiller:COMBAT_LOG_EVENT_UNFILTERED( event, timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ... )
	if eventtype == "SPELL_AURA_APPLIED" then
		if dstGUID == playerId then
			local spellId = ...
			
			if spellsToWatch[spellId] then
				for buffId, buffName in pairs( buffsToRemove ) do
					CancelUnitBuff( "player", buffName )
				end

				self:Print( L["Buffs removed."] )
			end
		end
	end
end