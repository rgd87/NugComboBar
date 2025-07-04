local addonName, ns = ...

local APILevel = ns.APILevel

local GlobalGetSpecialization = C_SpecializationInfo and C_SpecializationInfo.GetSpecialization or _G.GetSpecialization
local GetSpecialization = APILevel <= 4 and function() return 1 end or GlobalGetSpecialization
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
}, "DEATHKNIGHT")
