local addonName, ns = ...

local APILevel = ns.APILevel

local GetSpecialization = C_SpecializationInfo and C_SpecializationInfo.GetSpecialization or _G.GetSpecialization
if APILevel <= 4 then
    GetSpecialization = function() return 1 end
end
local GetSpell = ns.GetSpell
local FindAura = ns.FindAura
local GetAuraStack = ns.GetAuraStack
local GetAuraStackWTimer = ns.GetAuraStackWTimer
local MakeGetChargeFunc = ns.MakeGetChargeFunc
local MakeGetComboPower = ns.MakeGetComboPower
local GENERAL_UPDATE = ns.GENERAL_UPDATE
local GENERIC_FILTERED_UNIT_POWER_UPDATE = ns.GENERIC_FILTERED_UNIT_POWER_UPDATE


local DRUID_BEAR_FORM = ns.DRUID_BEAR_FORM
local DRUID_CAT_FORM = ns.DRUID_CAT_FORM


if APILevel ~= 5 then return end
-- Mists of Pandaria CONFIG


local OriginalGetComboPoints = _G.GetComboPoints
local RogueGetComboPoints = function(unit)
    unit = unit or "player"
    return OriginalGetComboPoints(unit, "target")
end
local GetAnticipation = GetAuraStack(115189, "HELPFUL", "player")
local function GetComboPointsAncitipation(unit)
    local cp = RogueGetComboPoints(unit)
    local anticipation = GetAnticipation()
    return cp, nil, nil, anticipation
end

NugComboBar:RegisterConfig("ComboPointsAnticipation", {
    triggers = { GetSpecialization, GetSpell(114015) }, -- Shadow Dance, Deeper Stratagem, Enveloping Shadows
    setup = function(self, spec)
        self:ApplyConfig("ComboPointsRogueClassic")

        local isAnticipation = IsPlayerSpell(114015)

        if isAnticipation then
            self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
            self.eventProxy.UNIT_AURA = GENERAL_UPDATE

            self:SetPointGetter(GetComboPointsAncitipation)
        end
    end,
}, "ROGUE")


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
            then self:SetMaxPoints(5)
            else self:SetMaxPoints(4)
        end
        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true
        self:SetPointGetter(GetChi)
    end
}, "MONK")

---------------------
-- PALADIN
---------------------

NugComboBar:RegisterConfig("HolyPower", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
        self.eventProxy.UNIT_POWER_UPDATE = GENERIC_FILTERED_UNIT_POWER_UPDATE("HOLY_POWER")
        self:SetMaxPoints(3)
        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true
        self:SetSourceUnit("player")
        self:SetTargetUnit("player")
        self:SetPointGetter(MakeGetComboPower(Enum.PowerType.HolyPower))
    end
}, "PALADIN")

NugComboBar:RegisterConfig("ShadowOrbs", {
    triggers = { GetSpecialization, GetSpell(95740) },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
        self.eventProxy.UNIT_POWER_UPDATE = GENERIC_FILTERED_UNIT_POWER_UPDATE("SHADOW_ORBS")
        self:SetMaxPoints(3)
        self:SetDefaultValue(0)
        self:SetSourceUnit("player")
        self:SetTargetUnit("player")
        self:SetPointGetter(MakeGetComboPower(Enum.PowerType.ShadowOrbs))
        self.flags.soundFullEnabled = true
    end
}, "PREIST")



NugComboBar:RegisterConfig("TasteForBlood", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
        self.eventProxy.UNIT_AURA = GENERAL_UPDATE
        self:SetMaxPoints(5)
        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true
        self:SetPointGetter(GetAuraStack(60503, "HELPFUL")) -- TasteForBlood
    end
}, "WARRIOR", 1)
NugComboBar:RegisterConfig("Meatcleaver", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
        self.eventProxy.UNIT_AURA = GENERAL_UPDATE
        self:SetMaxPoints(3)
        self:SetDefaultValue(0)
        -- self.flags.soundFullEnabled = true
        self:SetPointGetter(GetAuraStack(85739, "HELPFUL")) -- Meatcleaver
    end
}, "WARRIOR", 2)


local Enum_PowerType_BurningEmbers = Enum.PowerType.BurningEmbers
local GetDestructionShards = function(unit)
    local shards = UnitPower("player", Enum_PowerType_BurningEmbers)
    local fragments = UnitPower("player", Enum_PowerType_BurningEmbers, true)
    local rfragments = fragments - (shards*10)
    if rfragments == 0 then rfragments = nil end
    return shards, rfragments
end
NugComboBar:RegisterConfig("SoulShards", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
        self:SetMaxPoints(4)

        self.flags.soundFullEnabled = true
        self:SetSourceUnit("player")
        self:SetTargetUnit("player")
        -- self:SetPointGetter(MakeGetComboPower(Enum.PowerType.SoulShards))

        if spec == 3 then
            self.eventProxy.UNIT_POWER_UPDATE = GENERIC_FILTERED_UNIT_POWER_UPDATE("BURNING_EMBERS")
            self:SetPointGetter(GetDestructionShards)
            self:EnableBar(0, 10,"Small" )
            self:SetDefaultValue(1)
        else
            self.eventProxy.UNIT_POWER_UPDATE = GENERIC_FILTERED_UNIT_POWER_UPDATE("SOUL_SHARDS")
            self:SetPointGetter(MakeGetComboPower(Enum.PowerType.SoulShards))
            self:DisableBar()
            self:SetDefaultValue(4)
        end
    end
}, "WARLOCK")





NugComboBar:RegisterConfig("Pulverize", { --CATA
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
        self:SetPointGetter(GetAuraStack(33745, "HARMFUL", "target", "player"))
    end
}, "DRUID")

NugComboBar:RegisterConfig("ShapeshiftDruid", {
    triggers = { GetSpecialization, GetSpell(80313), GetSpell(22568) }, -- Pulv, FerBite

    setup = function(self, spec)
        self:RegisterEvent("UPDATE_SHAPESHIFT_FORM") -- Registering on main addon, not event proxy
        self.UPDATE_SHAPESHIFT_FORM = function(self)
            local spec = GetSpecialization()
            local form = GetShapeshiftFormID()
            self:ResetConfig()

            if form == DRUID_BEAR_FORM and IsPlayerSpell(80313) then --Pulverize
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


NugComboBar:RegisterConfig("ShadowInfusion", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_AURA", "pet")
        self.eventProxy.UNIT_AURA = GENERAL_UPDATE
        self:SetMaxPoints(5)
        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true
        self:SetPointGetter(GetAuraStack(91342, "HELPFUL", "pet")) -- Shadow Infusion
    end
}, "DEATHKNIGHT", 3)
