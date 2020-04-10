local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC


local GetSpell = function(spellId)
    return function()
        return IsPlayerSpell(spellId)
    end
end

local function FindAura(unit, spellID, filter)
    for i=1, 100 do
        -- rank will be removed in bfa
        local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, auraSpellID = UnitAura(unit, i, filter)
        if not name then return nil end
        if spellID == auraSpellID then
            return name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, auraSpellID
        end
    end
end

local GetAuraStack = function(scanID, filter, unit, casterCheck)
    filter = filter or "HELPFUL"
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
    triggers = { GetSpecialization, GetSpell(185313), GetSpell(193531), GetSpell(238104) }, -- Shadow Dance, Deeper Stratagem, Enveloping Shadows
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
        else
            self:SetMaxPoints(maxCP)
            self:SetPointGetter(RogueGetComboPoints)
        end
    end,
})

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
        self:SetSourceUnit("player")
        self:SetTargetUnit("player")
        self:SetPointGetter(RogueGetComboPoints)
    end
})

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
})


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

            if form == BEAR_FORM and spec == 3 and IsPlayerSpell(80313) then --Pulverize
                self:ApplyConfig("Pulverize")
            elseif form == CAT_FORM and IsPlayerSpell(22568) then -- Ferocious Bite, in bfa without Feral Affinity you don't have bite or cps
                self:ApplyConfig("ComboPointsDruid")
            else
                self:Disable()
            end
        end
        self.UPDATE_SHAPESHIFT_FORM(self)
    end
})


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
    triggers = { GetSpecialization },
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
})

NugComboBar:RegisterConfig("ShieldOfTheRighteousness", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        self.eventProxy:RegisterEvent("SPELL_UPDATE_CHARGES")
        self.eventProxy.SPELL_UPDATE_COOLDOWN = GENERAL_UPDATE
        self.eventProxy.SPELL_UPDATE_CHARGES = GENERAL_UPDATE
        self:SetMaxPoints(3)
        self:SetDefaultValue(3)
        self.flags.showEmpty = true
        self:EnableBar(0, 6,"Small", "Timer")
        self:SetPointGetter(MakeGetChargeFunc(53600)) -- Shield of the Righteous
    end
})

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
    triggers = { GetSpecialization },
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
})


NugComboBar:RegisterConfig("IronskinBrew", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        self.eventProxy:RegisterEvent("SPELL_UPDATE_CHARGES")
        self.eventProxy.SPELL_UPDATE_COOLDOWN = GENERAL_UPDATE
        self.eventProxy.SPELL_UPDATE_CHARGES = GENERAL_UPDATE
        if IsPlayerSpell(196721) then -- Light Brewing
            self:SetMaxPoints(4)
            self:SetDefaultValue(4)
        else
            self:SetMaxPoints(3)
            self:SetDefaultValue(3)
        end
        self.flags.showEmpty = true
        self.flags.soundFullEnabled = true
        self:EnableBar(0, 6,"Small", "Timer")
        self:SetPointGetter(MakeGetChargeFunc(115308)) -- Ironskin Brew
    end
})

NugComboBar:RegisterConfig("Teachings", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
        self.eventProxy.UNIT_AURA = GENERAL_UPDATE
        self:SetMaxPoints(3)
        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true
        self:EnableBar(0, 6,"Small", "Timer")
        self:SetPointGetter(GetAuraStack(202090)) -- Teachings of the Monastery
    end
})

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
})

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
})
