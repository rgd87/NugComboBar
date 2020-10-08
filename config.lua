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
    triggers = { GetSpecialization, GetSpell(193531) }, -- Deeper Stratagem,
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

        if not isClassic then -- Kyrian Covenant Ability
            self.eventProxy:RegisterUnitEvent("UNIT_POWER_POINT_CHARGE", "player")
            local selectedPoint = nil
            self.eventProxy.UNIT_POWER_POINT_CHARGE = function(self, event, unit)
                local chargedPoints = GetUnitChargedPowerPoints("player") -- returns table or nil
                local echoingReprimand = chargedPoints and chargedPoints[1]
                if echoingReprimand ~= selectedPoint then
                    selectedPoint = echoingReprimand
                    if selectedPoint ~= nil then
                        self:SelectPoint(selectedPoint)
                    else
                        self:DeselectAllPoints()
                    end
                end
            end
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
                self:Update()
            elseif form == CAT_FORM and IsPlayerSpell(22568) then -- Ferocious Bite, in bfa without Feral Affinity you don't have bite or cps
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
        self:SetMaxPoints(3)
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
            self:SetMaxPoints(maxFireBlastCharges, "FIREMAGE3", 3)
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
