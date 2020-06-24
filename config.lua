local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local GetSpecialization = isClassic and function() return 1 end or _G.GetSpecialization

local UnitPower = UnitPower

local GetSpell = function(spellId)
    return function()
        return IsPlayerSpell(spellId)
    end
end

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

local MakeGetChargeFunc = function(spellID)
    return function(unit)
        local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spellID)
        if charges == maxCharges then chargeStart = nil end
        return charges, chargeStart, chargeDuration
    end
end

---------------
-- COMMON
---------------

local GENERAL_UPDATE = function(self)
    self:Update()
end

---------------------
-- ROGUE
---------------------

local COMBO_POINTS_UNIT_POWER_UPDATE = function(self,event,unit,ptype)
    if unit ~= "player" then return end
    if ptype == "COMBO_POINTS" then
        return self:Update()
    end
end


local RogueGetComboPoints
if isClassic then
    local OriginalGetComboPoints = _G.GetComboPoints
    RogueGetComboPoints = function(unit)
        unit = unit or "player"
        return OriginalGetComboPoints(unit, "target")
    end
else
    local Enum_PowerType_ComboPoints = Enum.PowerType.ComboPoints
    RogueGetComboPoints = function(unit)
        return UnitPower("player", Enum_PowerType_ComboPoints)
    end
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
    triggers = { GetSpecialization, GetSpell(193531) }, -- Shadow Dance, Deeper Stratagem, Enveloping Shadows
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
        self.eventProxy.UNIT_POWER_UPDATE = COMBO_POINTS_UNIT_POWER_UPDATE

        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true
        self:SetSourceUnit("player")
        self:SetTargetUnit("player")

        if isClassic then
            self.eventProxy:RegisterEvent("PLAYER_TARGET_CHANGED")
            self.eventProxy.PLAYER_TARGET_CHANGED = GENERAL_UPDATE
        end

        local maxCP = IsPlayerSpell(193531) and 6 or 5 -- Deeper Stratagem

        self:SetMaxPoints(maxCP)
        self:SetPointGetter(RogueGetComboPoints)
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
        if isSub then
            local maxShadowDance = IsPlayerSpell(238104) and 3 or 2
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

        if isClassic then
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
    triggers = { GetSpecialization }, -- Pulv, FerBite

    setup = function(self, spec)

        self:RegisterEvent("UPDATE_SHAPESHIFT_FORM") -- Registering on main addon, not event proxy
        self.UPDATE_SHAPESHIFT_FORM = function(self)

            local spec = GetSpecialization()
            local form = GetShapeshiftFormID()
            self:ResetConfig()

            if form == CAT_FORM then -- Ferocious Bite, in bfa without Feral Affinity you don't have bite or cps
                self:ApplyConfig("ComboPointsDruid")
                self:Update()
            else
                self:Disable()
            end
        end
        self.UPDATE_SHAPESHIFT_FORM(self)
    end
}, "DRUID")

