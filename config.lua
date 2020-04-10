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
    if unit then allowedUnit = unit end
    filter = filter or "HELPFUL"
    return function(unit)
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

---------------------
-- ROGUE
---------------------


local RogueGetComboPoints
-- if isClassic then
--     local OriginalGetComboPoints = _G.GetComboPoints
--     RogueGetComboPoints = function(unit)
--         return OriginalGetComboPoints(unit, "target")
--     end
-- else
RogueGetComboPoints = function(unit)
    return UnitPower("player", 4)
end
-- end

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

NugComboBar:RegisterConfig("ComboPoints", {
    triggers = { GetSpecialization, GetSpell(185313) },
    events = {
        UNIT_POWER_FREQUENT = function(self,event,unit,ptype)
            if unit ~= "player" then return end
            if ptype == "COMBO_POINTS" then
                return self.UNIT_COMBO_POINTS(self,event,unit,ptype)
            end
        end,
        SPELL_UPDATE_COOLDOWN = function(self, event)
            self:UNIT_COMBO_POINTS(nil, "player")
        end
        -- if isClassic then
        --     self:RegisterEvent("PLAYER_TARGET_CHANGED")
        -- end
    },
    forcedFlags = {
        chargeCooldownOnSecondBar = true
    },
    setup = function(self, spec)

            local isSub = (GetSpecialization() == 3) and IsPlayerSpell(185313)
            local isAnticipation = IsPlayerSpell(114015)
            local maxCP = IsPlayerSpell(193531) and 6 or 5 -- Deeper Stratagem
            local maxFill = NugComboBarDB.maxFill
        if isSub then
            local maxShadowDance = IsPlayerSpell(238104) and 3 or 2
            local barSetup = "ROGUE"..maxCP..maxShadowDance
            self:SetMaxPoints(maxCP, barSetup, maxShadowDance)
            self:EnableBar(0, 6, 90, "Timer")
        else
            self:DisableBar()
            self:SetMaxPoints(maxCP)
        end

        return makeRCP(isAnticipation, isSub, maxFill, maxCP)--  RogueGetComboPoints
    end,
})

---------------------
-- DRUID
---------------------


local COMBO_POINTS_UNIT_POWER_UPDATE = function(self,event,unit,ptype)
    if unit ~= "player" then return end
    if ptype == "COMBO_POINTS" then
        return self.UNIT_COMBO_POINTS(self,event,unit,ptype)
    end
end

NugComboBar:RegisterConfig("ComboPointsDruid", {
    triggers = { GetSpecialization },
    events = {
        -- PLAYER_TARGET_CHANGED = true, -- required for Pulverize?
            -- UNIT_POWER_UPDATE = function(self,event,unit,ptype)
            --     if unit ~= "player" then return end
            --     if ptype == "COMBO_POINTS" then
            --         return self.UNIT_COMBO_POINTS(self,event,unit,ptype)
            --     end
            -- end,
        -- if isClassic then
        --     self:RegisterEvent("PLAYER_TARGET_CHANGED")
        -- end
    },
    setup = function(self, spec)
        self.eventProxy:RegisterEvent("UNIT_POWER_UPDATE")
        self.eventProxy.UNIT_POWER_UPDATE = COMBO_POINTS_UNIT_POWER_UPDATE
        self:SetMaxPoints(5)
        self.flags.soundFullEnabled = true
        self:SetSourceUnit("player")
        self:SetTargetUnit("player")
        self:RegisterEvent("UNIT_POWER_FREQUENT")
        self:SetPointGetter(RogueGetComboPoints)
        self:Update()
    end
})


NugComboBar:RegisterConfig("ShapeshiftDruid", {
    triggers = { GetSpecialization, GetSpell(80313) },
    events = {
        -- PLAYER_TARGET_CHANGED = true, -- required for Pulverize?
        UNIT_POWER_FREQUENT = function(self,event,unit,ptype)
            if unit ~= "player" then return end
            if ptype == "COMBO_POINTS" then
                return self.UNIT_COMBO_POINTS(self,event,unit,ptype)
            end
        end,
        UNIT_AURA = function(self, event, unit)
            -- self:Update()
        end,
        -- if isClassic then
        --     self:RegisterEvent("PLAYER_TARGET_CHANGED")
        -- end
    },
    forcedFlags = {
        chargeCooldownOnSecondBar = true
    },
    setup = function(self, spec)
        self:SetMaxPoints(5)

        local enablePulverize = false

        -- local reset = function()
        --     defaultValue = 0
        --     soundFullEnabled = false
        --     hideSlowly = NugComboBarDB.hideSlowly
        --     showEmpty = NugComboBarDB.showEmpty
        -- end


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

        local cat = function()
            self:SetMaxPoints(5)
            self.flags.soundFullEnabled = true
            -- allowedTargetUnit = "player"
            self:RegisterEvent("UNIT_POWER_FREQUENT")
            local maxFill = NugComboBarDB.maxFill
            GetComboPoints = RogueGetComboPoints
            -- allowedUnit = "player"
            self:Update()
        end

        -- local disable = function()
        --     -- self:SetMaxPoints(3)
        --     -- self:RegisterEvent("UNIT_AURA")
        --     self.UNIT_AURA = self.UNIT_COMBO_POINTS
        --     GetComboPoints = dummy -- disable
        --     local old1 = showEmpty
        --     local old2 = hideSlowly
        --     showEmpty = false
        --     hideSlowly = false
        --     self:UNIT_COMBO_POINTS(nil,allowedUnit)
        --     showEmpty = old1
        --     hideSlowly = old2
        -- end


        local pulverize = function()
            self:SetMaxPoints(3)
            self:RegisterEvent("UNIT_AURA")
            -- self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            self.flags.soundFullEnabled = true
            GetComboPoints = GetAuraStack(192090, "HARMFUL", "target") -- Lacerate`
            self:UNIT_COMBO_POINTS(nil,allowedUnit)
        end

        self.eventProxy:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
        self.UPDATE_SHAPESHIFT_FORM = function(self)
            -- self:UnregisterEvent("PLAYER_TARGET_CHANGED") -- it should be always on to hideWithoutTarget to work

            local spec = GetSpecialization()
            local form = GetShapeshiftFormID()
            self:Reset()

            if form == BEAR_FORM then
                if spec == 3 and enablePulverize and IsPlayerSpell(80313) --pulverize
                    then pulverize()
                    else self:Disable()
                end
            elseif form == CAT_FORM then
                cat()
                -- self:ApplyConfig("ComboPoints")

            -- elseif spec == 1 then
                -- empowerments()
            else
                self:Disable()
            end
        end
        self.eventProxy:UPDATE_SHAPESHIFT_FORM()
    end
})