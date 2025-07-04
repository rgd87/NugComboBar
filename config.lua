local addonName, ns = ...

ns.APILevel = math.floor(select(4,GetBuildInfo())/10000)
local APILevel = ns.APILevel
local isClassic = APILevel <= 3
local GlobalGetSpecialization = C_SpecializationInfo and C_SpecializationInfo.GetSpecialization or _G.GetSpecialization
local GetSpecialization = APILevel <= 4 and function() return 1 end or GlobalGetSpecialization

local DRUID_CAT_FORM = DRUID_CAT_FORM or CAT_FORM or 1
local DRUID_BEAR_FORM = DRUID_BEAR_FORM or BEAR_FORM or 5
local RetailGetSpellCooldown = function(...)
    local C_Spell_GetSpellCooldown = C_Spell.GetSpellCooldown
    local info = C_Spell_GetSpellCooldown(...)
    return info.startTime, info.duration, info.enabled, info.modRate
end
local RetailGetSpellCharges = function(...)
    local C_Spell_GetSpellCharges = C_Spell.GetSpellCharges
    local info = C_Spell_GetSpellCharges(...)
    return info.currentCharges, info.maxCharges, info.cooldownStartTime, info.cooldownDuration
end
local GetSpellCooldown = GetSpellCooldown or RetailGetSpellCooldown
local GetSpellCharges = GetSpellCharges or RetailGetSpellCharges

ns.DRUID_BEAR_FORM = DRUID_BEAR_FORM
ns.DRUID_CAT_FORM = DRUID_CAT_FORM
local UnitPower = UnitPower

local GetSpell = function(spellId)
    return function()
        return IsPlayerSpell(spellId)
    end
end

local DeprecatedUnitAura = function(unitToken, index, filter)
    local auraData = C_UnitAuras.GetAuraDataByIndex(unitToken, index, filter);
    if not auraData then
        return nil;
    end

    return AuraUtil.UnpackAuraData(auraData);
end
local UnitAura = UnitAura or DeprecatedUnitAura

local function FindAura(unit, spellID, filter)
    for i=1, 100 do
        local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, auraSpellID = UnitAura(unit, i, filter)
        if not name then return nil end
        if spellID == auraSpellID then
            return name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, auraSpellID
        end
    end
end

local GetAuraStack = function(scanID, filter, unit, casterCheck)
    filter = filter or "HELPFUL"
    unit = unit or "player"
    return function()
        local name, icon, count, debuffType, duration, expirationTime, caster = FindAura(unit, scanID, filter)
        if casterCheck and caster ~= casterCheck then count = nil end
        if count then
            return count --, expirationTime-duration, duration
        else return 0,0,0 end
    end
end

local GetAuraStackWTimer = function(scanID, filter, unit, casterCheck)
    filter = filter or "HELPFUL"
    unit = unit or "player"
    return function()
        local name, icon, count, debuffType, duration, expirationTime, caster = FindAura(unit, scanID, filter)
        if casterCheck and caster ~= casterCheck then count = nil end
        if count then
            return count, expirationTime-duration, duration
        else return 0,0,0 end
    end
end

local MakeGetChargeFunc = function(spellID)
    return function(unit)
        local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spellID)
        if charges == maxCharges then chargeStart = nil end
        return charges, chargeStart, chargeDuration
    end
end

local function GENERIC_FILTERED_UNIT_POWER_UPDATE(powerType)
    return function(self,event,unit,ptype)
        if unit ~= "player" or ptype ~= powerType then return end
        return self:Update(unit, ptype)
    end
end

local function MakeGetComboPower(powerTypeIndex)
    return function(unit)
        return UnitPower("player", powerTypeIndex)
    end
end

ns.GetSpell = GetSpell
ns.FindAura = FindAura
ns.GetAuraStack = GetAuraStack
ns.GetAuraStackWTimer = GetAuraStackWTimer
ns.MakeGetChargeFunc = MakeGetChargeFunc
ns.GENERIC_FILTERED_UNIT_POWER_UPDATE = GENERIC_FILTERED_UNIT_POWER_UPDATE
ns.MakeGetComboPower = MakeGetComboPower

---------------
-- COMMON
---------------

local GENERAL_UPDATE = function(self)
    self:Update()
end

ns.GENERAL_UPDATE = GENERAL_UPDATE

local COMBO_POINTS_UNIT_POWER_UPDATE = function(self,event,unit,ptype)
    if unit ~= "player" then return end
    if ptype == "COMBO_POINTS" then
        return self:Update()
    end
end

if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then

---------------------
-- ROGUE
---------------------

local Enum_PowerType_ComboPoints = Enum.PowerType.ComboPoints
local RogueGetComboPoints = function(unit)
    return UnitPower("player", Enum_PowerType_ComboPoints)
end

local GetShadowdance = function()
    local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(185313) -- shadow dance
    if charges == maxCharges then chargeStart = nil end
    return charges, chargeStart, chargeDuration
end

local makeRCP = function(anticipation, subtlety, maxFill, maxCP)
    local secondRowCount = 0

    return function(unit)
        local secondRowCount, chargeStart, chargeDuration
        if subtlety then
            secondRowCount, chargeStart, chargeDuration  = GetShadowdance()
        end
        local cp = RogueGetComboPoints(unit)
        if anticipation and cp > 5 then
            return 5, chargeStart, chargeDuration, cp-5, secondRowCount
        elseif maxFill and cp == maxCP then
            return cp, chargeStart, chargeDuration, cp, secondRowCount
        end
        return cp, chargeStart, chargeDuration, 0, secondRowCount
    end
end

NugComboBar:RegisterConfig("ComboPointsRogue", {
    -- Deeper Stratagem, Devious Stratagem(Outlaw), Secret Stratagem(Sub)
    triggers = { GetSpecialization, GetSpell(193531), GetSpell(394321), GetSpell(394320) },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
        self.eventProxy.UNIT_POWER_UPDATE = COMBO_POINTS_UNIT_POWER_UPDATE

        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true
        self:SetSourceUnit("player")
        self:SetTargetUnit("player")

        if APILevel <= 5 then
            self.eventProxy:RegisterEvent("PLAYER_TARGET_CHANGED")
            self.eventProxy.PLAYER_TARGET_CHANGED = GENERAL_UPDATE
        end

        local DeeperStratagem = IsPlayerSpell(193531) and 1 or 0 -- Deeper Stratagem
        local DeviousStratagem = IsPlayerSpell(394321) and 1 or 0 -- Deeper Stratagem
        local SecretStratagem = IsPlayerSpell(394320) and 1 or 0 -- Secret Stratagem
        local SanguineStratagem = IsPlayerSpell(457512) and 1  or 0 -- Sanguine Stratagem
        local maxCP = 5 + DeeperStratagem + DeviousStratagem + SecretStratagem + SanguineStratagem

        self:SetMaxPoints(maxCP)
        self:SetPointGetter(RogueGetComboPoints)

        if not isClassic then -- Kyrian Covenant Ability
            self.eventProxy:RegisterUnitEvent("UNIT_POWER_POINT_CHARGE", "player")

            self.eventProxy.UNIT_POWER_POINT_CHARGE = function(self, event, unit)
                local chargedPoints = GetUnitChargedPowerPoints("player") -- returns table or nil
                for i = 1, self.MAX_POINTS do
                    local isSelected
                    if chargedPoints then
                        for _, pointIndex in ipairs(chargedPoints) do
                            if i == pointIndex then
                                isSelected = true
                                break
                            end
                        end
                    end

                    if isSelected then
                        self:SelectPoint(i)
                    else
                        self:DeselectPoint(i)
                    end
                    self:Update()
                end
            end

            self:DeselectAllPoints()
            self.eventProxy.UNIT_POWER_POINT_CHARGE(self, nil, "player")
        end
    end,
}, "ROGUE")

NugComboBar:RegisterConfig("ComboPointsAndShadowdance", {
    triggers = { GetSpecialization, GetSpell(185313), GetSpell(193531), GetSpell(238104) }, -- Shadow Dance, Deeper Stratagem, Enveloping Shadows
    setup = function(self, spec)
        self:ApplyConfig("ComboPointsRogue")

        local isSub = (spec == 3) and IsPlayerSpell(185313) -- if Shadow Dance
        local isAnticipation = false -- IsPlayerSpell(114015)
        local maxCP = IsPlayerSpell(193531) and 6 or 5 -- Deeper Stratagem
        local maxFill = NugComboBarDB.maxFill
        local maxShadowDance = IsPlayerSpell(238104) and 2 or 1
        if isSub and maxShadowDance == 2 then
            local barSetup = "ROGUE"..maxCP..maxShadowDance
            self.eventProxy:RegisterEvent("SPELL_UPDATE_COOLDOWN")
            self.eventProxy:RegisterEvent("SPELL_UPDATE_CHARGES")
            self.eventProxy.SPELL_UPDATE_COOLDOWN = GENERAL_UPDATE
            self.eventProxy.SPELL_UPDATE_CHARGES = GENERAL_UPDATE
            self:SetMaxPoints(maxCP, barSetup, maxShadowDance)
            self:EnableBar(0, 6, 90, "Timer")
            self.flags.chargeCooldownOnSecondBar = true
            self:SetPointGetter(makeRCP(isAnticipation, isSub, maxFill, maxCP)) -- RogueGetComboPoints
        end
    end,
}, "ROGUE", 3)

---------------------
-- DRUID
---------------------

NugComboBar:RegisterConfig("ComboPointsDruid", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
        self.eventProxy.UNIT_POWER_UPDATE = COMBO_POINTS_UNIT_POWER_UPDATE
        self:SetMaxPoints(5)
        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true

        if APILevel <= 5 then
            self.eventProxy:RegisterEvent("PLAYER_TARGET_CHANGED")
            self.eventProxy.PLAYER_TARGET_CHANGED = GENERAL_UPDATE
        end

        self:SetSourceUnit("player")
        self:SetTargetUnit("player")
        self:SetPointGetter(RogueGetComboPoints)
    end
}, "DRUID")

NugComboBar:RegisterConfig("Pulverize", {
    triggers = { GetSpecialization, GetSpell(80313) },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_AURA", "target")
        self.eventProxy.UNIT_AURA = GENERAL_UPDATE
        self.eventProxy:RegisterEvent("PLAYER_TARGET_CHANGED")
        self.eventProxy.PLAYER_TARGET_CHANGED = GENERAL_UPDATE
        self:SetMaxPoints(3)
        self.flags.soundFullEnabled = true
        self:SetSourceUnit("player")
        self:SetTargetUnit("target")
        self:SetPointGetter(GetAuraStack(192090, "HARMFUL", "target", "player"))
    end
}, "DRUID", 3)


NugComboBar:RegisterConfig("ShapeshiftDruid", {
    triggers = { GetSpecialization, GetSpell(80313), GetSpell(22568) }, -- Pulv, FerBite

    setup = function(self, spec)
        -- local solar_aura = 164545
        -- local lunar_aura = 164547
        -- local GetEmpowerments = function(unit)
        --     local _,_, solar = FindAura("player", solar_aura, "HELPFUL")
        --     local _,_, lunar = FindAura("player", lunar_aura, "HELPFUL")
        --     lunar = lunar or 0
        --     solar = solar or 0
        --     return lunar, nil, nil, 0, solar
        -- end

        -- local empowerments = function()
        --     self:SetMaxPoints(3, "MOONKIN", 3)
        --     GetComboPoints = GetEmpowerments
        --     self:RegisterEvent("UNIT_AURA")
        -- end

        self:RegisterEvent("UPDATE_SHAPESHIFT_FORM") -- Registering on main addon, not event proxy
        self.UPDATE_SHAPESHIFT_FORM = function(self)
            local spec = GetSpecialization()
            local form = GetShapeshiftFormID()
            self:ResetConfig()

            if form == DRUID_BEAR_FORM and spec == 3 and IsPlayerSpell(80313) then --Pulverize
                self:ApplyConfig("Pulverize")
                self:Update()
            elseif form == DRUID_CAT_FORM and IsPlayerSpell(22568) then -- Ferocious Bite, in bfa without Feral Affinity you don't have bite or cps
                self:ApplyConfig("ComboPointsDruid")
                self:Update()
            else
                self:Disable()
            end
        end
        self.UPDATE_SHAPESHIFT_FORM(self)
    end
}, "DRUID")


--[[
NugComboBar:RegisterConfig("ShapeshiftDruidCatweaving", {
    triggers = { GetSpecialization, GetSpell(80313), GetSpell(22568) }, -- Pulv, FerBite

    setup = function(self, spec)
        self:RegisterEvent("UPDATE_SHAPESHIFT_FORM") -- Registering on main addon, not event proxy
        local oldConfig = nil
        self.UPDATE_SHAPESHIFT_FORM = function(self)
            local spec = GetSpecialization()
            local form = GetShapeshiftFormID()

            local newConfig
            if form == BEAR_FORM then
                if spec == 3 and IsPlayerSpell(80313) then  --Pulverize
                    newConfig = "Pulverize"
                else
                    newConfig = nil
                end
            elseif IsPlayerSpell(22568) then -- Ferocious Bite, in bfa without Feral Affinity you don't have bite or cps
                newConfig = "ComboPointsDruid"
            else
                newConfig = nil
            end

            if newConfig then
                if newConfig ~= oldConfig then
                    self:ResetConfig()
                    self:ApplyConfig(newConfig)
                    self:Update()
                end
            else
                self:Disable()
            end
            oldConfig = newConfig
        end
        self.UPDATE_SHAPESHIFT_FORM(self)
    end
}, "DRUID")
]]

---------------------
-- PALADIN
---------------------

local Enum_PowerType_HolyPower = Enum.PowerType.HolyPower
local TheFiresOFJustice = 209785
local GetHolyPowerWBuffs = function(unit)
    local fojup = FindAura("player", TheFiresOFJustice, "HELPFUL")
    local hp = UnitPower("player", Enum_PowerType_HolyPower)
    local layer2 = 0
    if fojup then
        layer2 = 1
    end
    return hp, nil, nil, layer2
end
local GetHolyPower = function(unit)
    return UnitPower("player", Enum_PowerType_HolyPower)
end

local HOLY_POWER_UNIT_POWER_UPDATE = function(self,event,unit,ptype)
    if ptype ~= "HOLY_POWER" or unit ~= "player" then return end
    self.UNIT_COMBO_POINTS(self,event,unit,ptype)
end

NugComboBar:RegisterConfig("HolyPower", {
    triggers = { GetSpecialization, GetSpell(203316) },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
        self.eventProxy.UNIT_POWER_UPDATE = HOLY_POWER_UNIT_POWER_UPDATE
        self:SetMaxPoints(5, "PALADIN")
        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true
        self:SetSourceUnit("player")
        self:SetTargetUnit("player")
        if IsPlayerSpell(203316) and NugComboBarDB.paladinBuffs then -- FoJ Talent
            self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
            self.eventProxy.UNIT_AURA = GENERAL_UPDATE
            self:SetPointGetter(GetHolyPowerWBuffs)
        else
            self:SetPointGetter(GetHolyPower)
        end
    end
}, "PALADIN")

---------------------
-- MONK
---------------------

local Enum_PowerType_Chi = Enum.PowerType.Chi
local GetChi = function(unit)
    return UnitPower("player", Enum_PowerType_Chi)
end

local CHI_UNIT_POWER_UPDATE = function(self,event,unit,ptype)
    if ptype ~= "CHI" or unit ~= "player" then return end
    self.UNIT_COMBO_POINTS(self,event,unit,ptype)
end

NugComboBar:RegisterConfig("Chi", {
    triggers = { GetSpecialization, GetSpell(115396) },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
        self.eventProxy.UNIT_POWER_UPDATE = CHI_UNIT_POWER_UPDATE
        if IsPlayerSpell(115396)  -- Ascension
            then self:SetMaxPoints(6)
            else self:SetMaxPoints(5)
        end
        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true
        self:SetPointGetter(GetChi)
    end
}, "MONK", 3)


NugComboBar:RegisterConfig("PurifyingBrew", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        self.eventProxy:RegisterEvent("SPELL_UPDATE_CHARGES")
        self.eventProxy.SPELL_UPDATE_COOLDOWN = GENERAL_UPDATE
        self.eventProxy.SPELL_UPDATE_CHARGES = GENERAL_UPDATE
        self:SetMaxPoints(2)
        self:SetDefaultValue(2)
        self.flags.showEmpty = true
        self.flags.soundFullEnabled = true
        self:EnableBar(0, 6,"Small", "Timer")
        self:SetPointGetter(MakeGetChargeFunc(119582)) -- Purifying Brew
    end
}, "MONK", 1)

NugComboBar:RegisterConfig("Teachings", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
        self.eventProxy.UNIT_AURA = GENERAL_UPDATE
        self:SetMaxPoints(4)
        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true
        self:SetPointGetter(GetAuraStack(202090)) -- Teachings of the Monastery
    end
}, "MONK", 2)

NugComboBar:RegisterConfig("RenewingMist", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        self.eventProxy:RegisterEvent("SPELL_UPDATE_CHARGES")
        self.eventProxy.SPELL_UPDATE_COOLDOWN = GENERAL_UPDATE
        self.eventProxy.SPELL_UPDATE_CHARGES = GENERAL_UPDATE
        self:SetMaxPoints(2)
        self:SetDefaultValue(2)
        self.flags.showEmpty = true
        self:EnableBar(0, 6,"Small", "Timer")
        self:SetPointGetter(MakeGetChargeFunc(115151)) -- Renewing Mist
    end
}, "MONK", 2)

---------------------
-- PRIEST
---------------------

NugComboBar:RegisterConfig("FlashConcentration", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
        self.eventProxy.UNIT_AURA = GENERAL_UPDATE
        self:SetMaxPoints(5)
        self:SetDefaultValue(0)
        -- self.flags.soundFullEnabled = true
        self:EnableBar(0, 6,"Small", "Timer")
        self:SetPointGetter(GetAuraStackWTimer(336267)) -- Flash Concentration
    end
}, "PRIEST", 2)

---------------------
-- WARLOCK
---------------------

local Enum_PowerType_SoulShards = Enum.PowerType.SoulShards

local SOUL_SHARDS_UNIT_POWER_UPDATE = function(self,event,unit,ptype)
    if ptype == "SOUL_SHARDS" then
        return self:Update()
    end
end

local GetShards = function(unit)
    return UnitPower("player", Enum_PowerType_SoulShards)
end

local GetDestructionShards = function(unit)
    local shards = UnitPower("player", Enum_PowerType_SoulShards)
    local fragments = UnitPower("player", Enum_PowerType_SoulShards, true)
    local rfragments = fragments - (shards*10)
    if rfragments == 0 then rfragments = nil end
    return shards, rfragments
end

NugComboBar:RegisterConfig("SoulShards", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
        self.eventProxy.UNIT_POWER_UPDATE = SOUL_SHARDS_UNIT_POWER_UPDATE
        local maxshards = UnitPowerMax( "player", Enum_PowerType_SoulShards )
        self:SetMaxPoints(maxshards)
        self:SetDefaultValue(3)
        self.flags.soundFullEnabled = true
        self.flags.showEmpty = true
        if spec == 3 then
            self:SetPointGetter(GetDestructionShards)
            self:EnableBar(0, 10,"Small" )
        else
            self:SetPointGetter(GetShards)
            self:DisableBar()
        end
    end
}, "WARLOCK")

---------------------
-- EVOKER
---------------------

local Enum_PowerType_Essence = Enum.PowerType.Essence


local essenceLastProgress = 0.0
local essenceLastResetTime = 0
local essenceLastPoints = 0
local essenceLastPointGainTime = 0
local essenceWasFull = false

local GetEssence = function(unit)
    local points = UnitPower("player", Enum_PowerType_Essence)
    local pointsMax = UnitPowerMax("player", Enum_PowerType_Essence)

    local now = GetTime()
    if points - essenceLastPoints == 1 then
        essenceLastPointGainTime = now
        -- print(GetTime(), "point GAIN")
    end
    essenceLastPoints = points

    local bankedPoint = 0

    -- if not quiet then print(essenceWasFull, now - essenceLastPointGainTime, now - essenceLastPointGainTime > 3.5, now - essenceLastResetTime < 1, now - essenceLastResetTime) end
    local sinceLastReset = now - essenceLastResetTime
    if not essenceWasFull and now - essenceLastPointGainTime > 3.5 and sinceLastReset > 0.05 and sinceLastReset < 1 then
        bankedPoint = 1
    end
    points = points + bankedPoint

    local isAtMaxPoints = points == pointsMax
    if not isAtMaxPoints then
        essenceWasFull = false
        local partialPoint = UnitPartialPower("player", Enum_PowerType_Essence);
		local elapsedPortion = (partialPoint / 1000.0);

        return points, elapsedPortion
    else
        essenceWasFull = true
        return points, nil, nil
    end
end




local ESSENCE_UNIT_POWER_UPDATE = function(self,event,unit,ptype)
    if ptype ~= "ESSENCE" or unit ~= "player" then return end
    -- print(GetTime(),ptype, unit)
    self.UNIT_COMBO_POINTS(self,event,unit,ptype)
end

local EssenseProgressBarOnUpdate = function(self, time)
    self._elapsed = (self._elapsed or 0) + time
    if self._elapsed < 0.03 then return end
    self._elapsed = 0

    local point, progress = GetEssence("player")
    if progress then
        self:SetValue(progress)

        if progress - essenceLastProgress < -0.7 then
            essenceLastResetTime = GetTime()
            -- print(GetTime(), "Reset")
            NugComboBar:Update("player", "ESSENCE")
        end
        essenceLastProgress = progress
    else
        self:Hide()
    end
end

NugComboBar:RegisterConfig("Essence", {
    triggers = { GetSpecialization, GetSpell(369908) },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
        self.eventProxy.UNIT_POWER_UPDATE = ESSENCE_UNIT_POWER_UPDATE

        -- self.eventProxy:SetScript("OnUpdate", GetEssenceOnUpdate)

        -- local max = UnitPowerMax( "player", Enum_PowerType_Essence ) -- not updated quick enough on talent change
        local max = 5
        if IsPlayerSpell(369908) then max = max + 1 end
        self:SetMaxPoints(max)
        self:SetDefaultValue(max)
        -- self.flags.soundFullEnabled = true
        self.flags.shouldBeFull = true
        self.flags.showEmpty = true

        self:SetPointGetter(GetEssence)
        self:EnableBar(0, 1, "Small", "Timer")
        self.bar:SetScript("OnUpdate", EssenseProgressBarOnUpdate)
    end
}, "EVOKER")

---------------------
-- DEMON HUNTER
---------------------

NugComboBar:RegisterConfig("SoulFragments", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
        self.eventProxy.UNIT_AURA = GENERAL_UPDATE
        self:SetMaxPoints(5)
        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true
        self:SetPointGetter(GetAuraStack(203981, "HELPFUL", "player")) -- Soul Fragments
    end
}, "DEMONHUNTER")


---------------------
-- DEATH KNIGHT
---------------------

local GetTotalRunes = function(self, unit)
    local n = 0
    for i=1,6 do
        local _,_,isReady = GetRuneCooldown(i)
        if isReady then  n = n + 1 end
    end
    return n
end

local RUNE_POWER_UPDATE = function(self, event, runeIndex, isEnergize)
    self:Update("player", runeIndex, isEnergize)
end

NugComboBar:RegisterConfig("Runes", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.flags.isRuneTracker = true
        local isPrettyRuneCharger = self.db.global.enablePrettyRunes
        if isPrettyRuneCharger then
            self:SetMaxPoints(6, "DEATHKNIGHT")
        else
            self:SetMaxPoints(6, "6NO6")
        end
        self:SetDefaultValue(6)

        self.eventProxy:RegisterEvent("RUNE_POWER_UPDATE")
        self.eventProxy.RUNE_POWER_UPDATE = RUNE_POWER_UPDATE

        self:SetPointGetter(GetTotalRunes) -- Soul Fragments
    end
}, "DEATHKNIGHT")


NugComboBar:RegisterConfig("FesteringWounds", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_AURA", "target")
        self.eventProxy.UNIT_AURA = GENERAL_UPDATE
        self.eventProxy:RegisterEvent("PLAYER_TARGET_CHANGED")
        self.eventProxy.PLAYER_TARGET_CHANGED = GENERAL_UPDATE
        self:SetMaxPoints(6)
        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true
        self:SetSourceUnit("player")
        self:SetTargetUnit("target")
        self:SetPointGetter(GetAuraStack(194310, "HARMFUL", "target", "player")) -- Festering Wounds
    end
}, "DEATHKNIGHT", 3)


---------------------
-- MAGE
---------------------

local Enum_PowerType_ArcaneCharges = Enum.PowerType.ArcaneCharges

local GetArcaneCharges = function(unit)
    return UnitPower("player", Enum_PowerType_ArcaneCharges)
end

local ARCANE_CHARGES_UNIT_POWER_FREQUENT = function(self,event,unit,ptype)
    if ptype == "ARCANE_CHARGES" then
        return self.UNIT_COMBO_POINTS(self,event,unit,ptype)
    end
end

NugComboBar:RegisterConfig("ArcaneCharges", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
        self.eventProxy.UNIT_POWER_UPDATE = ARCANE_CHARGES_UNIT_POWER_FREQUENT
        self:SetMaxPoints(UnitPowerMax( "player", Enum_PowerType_ArcaneCharges ))
        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true
        self:SetPointGetter(GetArcaneCharges)
    end
}, "MAGE", 1)

NugComboBar:RegisterConfig("Icicles", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
        self.eventProxy.UNIT_AURA = GENERAL_UPDATE
        self:SetMaxPoints(5)
        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true
        self:SetPointGetter(GetAuraStack(205473, "HELPFUL", "player")) -- Icicles
    end
}, "MAGE", 3)


local GetFireBlastCharges = MakeGetChargeFunc(108853) -- Fire Blast
local GetPhoenixFlamesCharges = MakeGetChargeFunc(194466) -- Phoenix's Flames
local FireMageGetCombined = function(unit)
    local fb = GetFireBlastCharges()
    local pf = GetPhoenixFlamesCharges()
    return fb, nil, nil, 0, pf
end

NugComboBar:RegisterConfig("Fireblast", {
    triggers = { GetSpecialization, GetSpell(205029) }, -- Flame On
    setup = function(self, spec)
        self.eventProxy:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        self.eventProxy:RegisterEvent("SPELL_UPDATE_CHARGES")
        self.eventProxy.SPELL_UPDATE_COOLDOWN = GENERAL_UPDATE
        self.eventProxy.SPELL_UPDATE_CHARGES = GENERAL_UPDATE

        local maxFireBlastCharges = 2 + (IsPlayerSpell(205029) and 1 or 0) -- Flame On

        self:SetMaxPoints(maxFireBlastCharges)
        self:SetDefaultValue(maxFireBlastCharges)

        self.flags.showEmpty = true
        -- self.flags.soundFullEnabled = true
        self:EnableBar(0, 6,"Small", "Timer")
        self:SetPointGetter(GetFireBlastCharges)
    end
}, "MAGE", 2)

NugComboBar:RegisterConfig("PhoenixFlamesFireblast", {
    triggers = { GetSpecialization, GetSpell(205029), GetSpell(257541) }, -- Flame On, PF
    setup = function(self, spec)
        self:ApplyConfig("Fireblast")

        local isPhoenixFlames = IsPlayerSpell(257541)
        local maxFireBlastCharges = 2 + (IsPlayerSpell(205029) and 1 or 0) -- Flame On

        if isPhoenixFlames then
            self:SetMaxPoints(maxFireBlastCharges, "FIREMAGE_CIND"..maxFireBlastCharges, 3)
            self:SetPointGetter(FireMageGetCombined)
            self:DisableBar()
        else
            self:SetMaxPoints(maxFireBlastCharges)
            self:SetPointGetter(GetFireBlastCharges)
        end
    end
}, "MAGE", 2)

---------------------
-- WARRIOR
---------------------

local MeatcleaverBuff = 85739
local GetMeatcleaver = function()
    local name, icon, count, debuffType, duration, expirationTime = FindAura("player", MeatcleaverBuff, "HELPFUL")
    return name and count*2 or 0
end

NugComboBar:RegisterConfig("Meatcleaver", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
        self.eventProxy.UNIT_AURA = GENERAL_UPDATE
        self:SetMaxPoints(4)
        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true
        if IsPlayerSpell(280392) then
            self:SetPointGetter(GetAuraStack(85739, "HELPFUL", "player"))
        else
            self:SetPointGetter(GetMeatcleaver)
        end
    end
}, "WARRIOR", 2)

NugComboBar:RegisterConfig("ShieldBlock", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        self.eventProxy:RegisterEvent("SPELL_UPDATE_CHARGES")
        self.eventProxy.SPELL_UPDATE_COOLDOWN = GENERAL_UPDATE
        self.eventProxy.SPELL_UPDATE_CHARGES = GENERAL_UPDATE
        self:SetMaxPoints(2)
        self:SetDefaultValue(2)
        self.flags.showEmpty = true
        self.flags.soundFullEnabled = true
        self:EnableBar(0, 6,"Small", "Timer")
        self:SetPointGetter(MakeGetChargeFunc(2565)) -- Shield Block
    end
}, "WARRIOR", 3)


---------------------
-- SHAMAN
---------------------

NugComboBar:RegisterConfig("TidalWaves", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
        self.eventProxy.UNIT_AURA = GENERAL_UPDATE
        self:SetMaxPoints(2)
        self:SetDefaultValue(0)
        self:SetPointGetter(GetAuraStack(53390, "HELPFUL", "player")) -- Tidal Waves
    end
}, "SHAMAN", 3)


--[[
local function GetTestData()
    local cp = math.random(10)
    local l2 = math.max(cp - 5, 0)
    if cp > 5 then cp = 5 end
    return cp, nil, nil, l2
end

NugComboBar:RegisterConfig("TestConfig", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
        self.eventProxy.UNIT_AURA = GENERAL_UPDATE
        self:SetMaxPoints(5)
        self:SetDefaultValue(0)
        self:SetPointGetter(GetTestData) -- Tidal Waves
    end
}, "SHAMAN")
]]

do

local undulationCharge = 0
local undulationConsumed = false
local undulationStartTime
local undulationDuration

local GetUndulation = function()
    return undulationCharge, undulationStartTime, undulationDuration
end

NugComboBar:RegisterConfig("Undulation", {
    triggers = { GetSpecialization, GetSpell(200071) },
    setup = function(self, spec)

        -- undulationCharge = 0 -- reset on talent or spec change
        -- Apparently the internal charges don't reset whatever you do

        if not IsPlayerSpell(200071) then
            return self:Disable()
        end

        local bit_band = bit.band
        local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
        self.eventProxy.COMBAT_LOG_EVENT_UNFILTERED = function(self, event)
            local timestamp, eventType, hideCaster,
            srcGUID, srcName, srcFlags, srcFlags2,
            dstGUID, dstName, dstFlags, dstFlags2,
            spellID, spellName, spellSchool, auraType, amount = CombatLogGetCurrentEventInfo()

            if (bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE) then -- isSrcPlayer
                if eventType == "SPELL_CAST_SUCCESS" then
                    if spellID == 77472 or spellID == 8004 then
                        if FindAura("player", 216251, "HELPFUL") then -- Undulation buff
                            undulationConsumed = true
                            undulationCharge = 1
                        else
                            undulationCharge = undulationCharge + 1
                        end

                        self:Update()
                    end

                elseif spellID == 216251 then -- Undulation buff

                    if eventType == "SPELL_AURA_APPLIED" then
                        local name, icon, count, debuffType, duration, expirationTime = FindAura("player", 216251, "HELPFUL")
                        if name then
                            undulationStartTime = expirationTime - duration
                            undulationDuration = duration
                            self:Update()
                        end

                    elseif eventType == "SPELL_AURA_REMOVED" then
                        if not undulationConsumed then
                            undulationCharge = 0
                        end
                        undulationConsumed = false
                        undulationStartTime = nil
                        undulationDuration = nil

                        self:Update()
                    end
                end
            end
        end

        self.eventProxy:RegisterUnitEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self:SetMaxPoints(3)
        self:SetDefaultValue(0)
        self:EnableBar(0, 6, 90, "Timer", true)
        self.flags.onlyCombat = true -- forcing to hide out of combat, because otherwise it'll stay forever
        self:SetPointGetter(GetUndulation)
    end
}, "SHAMAN", 3)
end

NugComboBar:RegisterConfig("Icefury", {
    triggers = { GetSpecialization, GetSpell(210714) },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
        self.eventProxy.UNIT_AURA = GENERAL_UPDATE
        self:SetMaxPoints(4)
        self:SetDefaultValue(0)
        self.flags.hideSlowly = false
        self:SetPointGetter(GetAuraStack(210714, "HELPFUL", "player")) -- Icefury
    end
}, "SHAMAN", 1)


local function GetMaelstromWaapon()
    local name, icon, count, debuffType, duration, expirationTime, caster = FindAura("player", 344179, "HELPFUL") -- new API function
    if not name then return 0 end
    local c1 = math.min(count, 5)
    local c2 = math.max(count - 5, 0)
    return c1, nil, nil, c2
end

NugComboBar:RegisterConfig("MaelstromWeapon", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
        self.eventProxy.UNIT_AURA = GENERAL_UPDATE
        self:SetMaxPoints(5)
        self:SetDefaultValue(0)
        self:SetPointGetter(GetMaelstromWaapon)
    end
}, "SHAMAN", 2)

end -- end of retail configs

-- Classic

if APILevel <= 5 then

    local OriginalGetComboPoints = _G.GetComboPoints
    local RogueGetComboPoints = function(unit)
        unit = unit or "player"
        return OriginalGetComboPoints(unit, "target")
    end

    local COMBO_POINTS_UNIT_POWER_UPDATE_CLASSIC = function(self,event,unit,ptype)
        if unit ~= "player" then return end
        -- In classic often when you switch targets the first UNIT_POWER_UPDATE for CPs is simply not firing,
        -- It's still fired for ENERGY power type tho, so just checking on all power updates
        -- if ptype == "COMBO_POINTS" then
            return self:Update()
        -- end
    end

    NugComboBar:RegisterConfig("ComboPointsRogueClassic", {
        triggers = { GetSpecialization, GetSpell(193531) }, -- Deeper Stratagem,
        setup = function(self, spec)
            self.eventProxy:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
            self.eventProxy.UNIT_POWER_UPDATE = COMBO_POINTS_UNIT_POWER_UPDATE_CLASSIC

            self:SetDefaultValue(0)
            self.flags.soundFullEnabled = true
            self:SetSourceUnit("player")
            self:SetTargetUnit("target")

            if APILevel <= 5 then
                self.eventProxy:RegisterEvent("PLAYER_TARGET_CHANGED")
                self.eventProxy.PLAYER_TARGET_CHANGED = GENERAL_UPDATE
            end

            local maxCP = IsPlayerSpell(193531) and 6 or 5 -- Deeper Stratagem

            self:SetMaxPoints(maxCP)
            self:SetPointGetter(RogueGetComboPoints)
        end,
    }, "ROGUE")


    NugComboBar:RegisterConfig("ComboPointsDruid", {
        triggers = { GetSpecialization },
        setup = function(self, spec)
            self.eventProxy:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
            self.eventProxy.UNIT_POWER_UPDATE = COMBO_POINTS_UNIT_POWER_UPDATE_CLASSIC
            self:SetMaxPoints(5)
            self:SetDefaultValue(0)
            self.flags.soundFullEnabled = true

            if APILevel <= 5 then
                self.eventProxy:RegisterEvent("PLAYER_TARGET_CHANGED")
                self.eventProxy.PLAYER_TARGET_CHANGED = GENERAL_UPDATE
            end

            self:SetSourceUnit("player")
            self:SetTargetUnit("player")
            self:SetPointGetter(RogueGetComboPoints)
        end
    }, "DRUID")


    NugComboBar:RegisterConfig("ShapeshiftDruid", {
        triggers = { GetSpecialization },

        setup = function(self, spec)
            self:RegisterEvent("UPDATE_SHAPESHIFT_FORM") -- Registering on main addon, not event proxy
            self.UPDATE_SHAPESHIFT_FORM = function(self)

                local spec = GetSpecialization()
                local form = GetShapeshiftFormID()
                self:ResetConfig()

                if form == DRUID_CAT_FORM then -- Ferocious Bite, in bfa without Feral Affinity you don't have bite or cps
                    self:Enable()
                    self:ApplyConfig("ComboPointsDruid")
                    self:Update()
                else
                    self:Disable()
                end
            end
            self.UPDATE_SHAPESHIFT_FORM(self)
        end
    }, "DRUID")


    -- BURNING CRUSADE
    if APILevel == 2 then
    NugComboBar:RegisterConfig("ArcaneBlastClassic", {
        triggers = { GetSpecialization },
        setup = function(self, spec)
            self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
            self.eventProxy.UNIT_AURA = GENERAL_UPDATE
            self:SetMaxPoints(3)
            self:SetDefaultValue(0)
            self.flags.soundFullEnabled = true
            self:SetPointGetter(GetAuraStack(36032, "HARMFUL")) -- Arcane Blast
        end
    }, "MAGE")
    end

    -- Season of Discovery
    if APILevel == 1 then
    NugComboBar:RegisterConfig("ArcaneBlastClassic", {
        triggers = { GetSpecialization },
        setup = function(self, spec)
            self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
            self.eventProxy.UNIT_AURA = GENERAL_UPDATE
            self:SetMaxPoints(4)
            self:SetDefaultValue(0)
            self.flags.soundFullEnabled = true
            self:SetPointGetter(GetAuraStack(400573, "HARMFUL")) -- Arcane Blast
        end
    }, "MAGE")

    NugComboBar:RegisterConfig("MaelstromWeapon", {
        triggers = { GetSpecialization },
        setup = function(self, spec)
            self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
            self.eventProxy.UNIT_AURA = GENERAL_UPDATE
            self:SetMaxPoints(5)
            self:SetDefaultValue(0)
            self.flags.soundFullEnabled = true
            self:SetPointGetter(GetAuraStack(408505, "HELPFUL")) -- Maelstrom Weapon
        end
    }, "SHAMAN")
    end




    -- WRATH & CATA ARCANE BLAST
    if APILevel >= 3 then
        NugComboBar:RegisterConfig("ArcaneBlastClassic", {
            triggers = { GetSpecialization },
            setup = function(self, spec)
                self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
                self.eventProxy.UNIT_AURA = GENERAL_UPDATE
                self:SetMaxPoints(4)
                self:SetDefaultValue(0)
                self.flags.soundFullEnabled = true
                self:SetPointGetter(GetAuraStack(36032, "HARMFUL")) -- Arcane Blast
            end
        }, "MAGE")
    end

    -- WRATH & CATA MAELSTROM
    if APILevel >= 3 then
        NugComboBar:RegisterConfig("MaelstromWeapon", {
            triggers = { GetSpecialization },
            setup = function(self, spec)
                self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
                self.eventProxy.UNIT_AURA = GENERAL_UPDATE
                self:SetMaxPoints(5)
                self:SetDefaultValue(0)
                self.flags.soundFullEnabled = true
                self:SetPointGetter(GetAuraStack(53817, "HELPFUL")) -- Maelstrom Weapon
            end
        }, "SHAMAN")
    end



end












-- -- Wrath of the Lich King

-- if APILevel == 3 then

--     local OriginalGetComboPoints = _G.GetComboPoints
--     local RogueGetComboPoints = function(unit)
--         unit = unit or "player"
--         return OriginalGetComboPoints(unit, "target")
--     end

--     local COMBO_POINTS_UNIT_POWER_UPDATE_CLASSIC = function(self,event,unit,ptype)
--         if unit ~= "player" then return end
--         -- In classic often when you switch targets the first UNIT_POWER_UPDATE for CPs is simply not firing,
--         -- It's still fired for ENERGY power type tho, so just checking on all power updates
--         -- if ptype == "COMBO_POINTS" then
--             return self:Update()
--         -- end
--     end

--     NugComboBar:RegisterConfig("ComboPointsRogueClassic", {
--         triggers = { GetSpecialization, GetSpell(193531) }, -- Deeper Stratagem,
--         setup = function(self, spec)
--             self.eventProxy:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
--             self.eventProxy.UNIT_POWER_UPDATE = COMBO_POINTS_UNIT_POWER_UPDATE_CLASSIC

--             self:SetDefaultValue(0)
--             self.flags.soundFullEnabled = true
--             self:SetSourceUnit("player")
--             self:SetTargetUnit("target")

--             if APILevel <= 5 then
--                 self.eventProxy:RegisterEvent("PLAYER_TARGET_CHANGED")
--                 self.eventProxy.PLAYER_TARGET_CHANGED = GENERAL_UPDATE
--             end

--             local maxCP = IsPlayerSpell(193531) and 6 or 5 -- Deeper Stratagem

--             self:SetMaxPoints(maxCP)
--             self:SetPointGetter(RogueGetComboPoints)
--         end,
--     }, "ROGUE")

-- end
