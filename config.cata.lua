local addonName, ns = ...

local APILevel = ns.APILevel

local GetSpecialization = APILevel <= 4 and function() return 1 end or _G.GetSpecialization
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


if APILevel ~= 4 then return end
-- CATACLYSM CONFIG


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
        self.eventProxy:RegisterUnitEvent("UNIT_AURA", "player")
        self.eventProxy.UNIT_AURA = GENERAL_UPDATE
        self:SetMaxPoints(3)
        self:SetDefaultValue(0)
        self.flags.soundFullEnabled = true
        self:SetPointGetter(GetAuraStack(77487)) -- Shadow Orbs
    end
}, "PREIST")


NugComboBar:RegisterConfig("SoulShards", {
    triggers = { GetSpecialization },
    setup = function(self, spec)
        self.eventProxy:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
        self.eventProxy.UNIT_POWER_UPDATE = GENERIC_FILTERED_UNIT_POWER_UPDATE("SOUL_SHARDS")
        self:SetMaxPoints(3)
        self:SetDefaultValue(3)
        self.flags.soundFullEnabled = true
        self:SetSourceUnit("player")
        self:SetTargetUnit("player")
        self:SetPointGetter(MakeGetComboPower(Enum.PowerType.SoulShards))
    end
}, "WARLOCK")