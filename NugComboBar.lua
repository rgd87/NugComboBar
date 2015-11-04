NugComboBar = CreateFrame("Frame", "NugComboBar", UIParent)
local NugComboBar = NugComboBar

local user
local RogueGetComboPoints = GetComboPoints
local GetComboPoints = RogueGetComboPoints
local allowedUnit = "player"
local allowedCaster = "player"
local allowedTargetUnit = "player"
local showEmpty, showAlways, onlyCombat
local hideSlowly
local secondLayerEnabled
local fadeAfter = 6
local soundFullEnabled = false
local combatFade = true -- whether to fade in combat
local defaultValue = 0
local defaultProgress = 0
local currentSpec = -1

NugComboBar:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

NugComboBar:RegisterEvent("ADDON_LOADED")

local L = setmetatable({}, {
    __index = function(t, k)
        t[k] = k
        return k
    end,
    __call = function(t,k)
        return t[k]
    end,
})
NugComboBar.L = L

local scanAura
local filter = "HELPFUL"
local GetAuraStack = function(unit)
    if not scanAura then return 0 end
    local name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitAura(allowedUnit, scanAura, nil, filter)
    if allowedCaster and caster ~= allowedCaster then count = nil end
    if count then
        return count, expirationTime-duration, duration
    else return 0,0,0 end
end

local AuraTimerOnUpdate = function(self, time)
    self._elapsed = (self._elapsed or 0) + time
    if self._elapsed < 0.03 then return end
    self._elapsed = 0

    if not self.startTime then return end
    local progress = self.duration - (GetTime() - self.startTime)
    self:SetValue(progress)
end

RogueGetComboPoints = function(unit)
    return UnitPower("player", 4)
end


-- local min = math.min
-- local max = math.max
function NugComboBar:LoadClassSettings()
        local class = select(2,UnitClass("player"))
        self.MAX_POINTS = nil
        self:SetupClassTheme()
        soundFullEnabled = false
        if self.bar then self.bar:SetColor(unpack(NugComboBarDB.colors.bar1)) end
        if class == "ROGUE" then
            local anticipationBuffName = GetSpellInfo(115189)
            local checkAnticipation = true
            soundFullEnabled = true
            allowedTargetUnit = "target"
            local ComboPointsWithAnticipation = function(unit)
                local _,anticipation
                if checkAnticipation then
                    _,_,_,anticipation = UnitBuff("player", anticipationBuffName, nil)
                end
                anticipation = anticipation or 0
                local cp = RogueGetComboPoints(unit)
                if not secondLayerEnabled or (anticipation > 0 and cp < anticipation) then
                    return cp, anticipation, nil, 0
                else
                    return cp, nil,nil, anticipation
                end
            end
            GetComboPoints = ComboPointsWithAnticipation

            self:SetMaxPoints(5)
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            self:RegisterEvent("UNIT_COMBO_POINTS")
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self:RegisterEvent("SPELLS_CHANGED")
            self.SPELLS_CHANGED = function(self, event)
                if IsPlayerSpell(114015) then -- Anticipation
                    self:EnableBar(0, 5, "Long")
                    self:RegisterUnitEvent("UNIT_AURA", "player")
                    checkAnticipation = true
                else
                    self:DisableBar()
                    self:UnregisterEvent("UNIT_AURA")
                    checkAnticipation = false
                end
            end
            self:SPELLS_CHANGED()
        elseif class == "DRUID" then
            self:RegisterEvent("PLAYER_TARGET_CHANGED") -- required for both
            self:SetMaxPoints(5)
            local dummy = function() return 0 end

            local reset = function()
                defaultValue = 0
                soundFullEnabled = false
                hideSlowly = NugComboBarDB.hideSlowly
                showEmpty = NugComboBarDB.showEmpty
            end



            local mushrooms_icon = "INTERFACE\\ICONS\\druid_ability_wildmushroom_a"
            local GetMushrooms = function()
                local mushrooms = 0
                for i=1,4 do
                    local haveTotem, name, startTime, duration, icon = GetTotemInfo(i)
                    if icon == mushrooms_icon then mushrooms = mushrooms + 1 end
                end
                if GetSpecialization() == 4 and mushrooms == 1 then mushrooms = 3 end
                return mushrooms
            end

            local shrooms = function()
                self:SetMaxPoints(3)
                hideSlowly = false
                self:RegisterEvent("PLAYER_TOTEM_UPDATE")
                GetComboPoints = GetMushrooms
                self.PLAYER_TOTEM_UPDATE = function(self, event, totemID)
                    self:UNIT_COMBO_POINTS(nil, allowedUnit)
                end
                self:PLAYER_TOTEM_UPDATE()
            end

            local starsurge = function()
                self:RegisterEvent("SPELL_UPDATE_CHARGES")
                local charges, maxCharges, start, duration = GetSpellCharges(78674)
                self:SetMaxPoints(maxCharges)
                defaultValue = 3
                -- self:EnableBar(0, duration, "Small")
                -- if self.bar then self.bar:SetScript("OnUpdate", AuraTimerOnUpdate) end
                GetComboPoints = function()
                    local charges, maxCharges, start, duration = GetSpellCharges(78674)
                    return charges, start, duration
                end
                self.SPELL_UPDATE_CHARGES = function(self, event, arg1)
                    self:UNIT_COMBO_POINTS(nil, allowedUnit)
                end
                self:SPELL_UPDATE_CHARGES()
            end

            local cat = function()
                self:SetMaxPoints(5)
                soundFullEnabled = true
                allowedTargetUnit = "target"
                self:RegisterEvent("UNIT_COMBO_POINTS")
                self:RegisterEvent("PLAYER_TARGET_CHANGED")
                GetComboPoints = RogueGetComboPoints
                allowedUnit = "player"
                self:UNIT_COMBO_POINTS(nil,allowedUnit)
            end

            local disable = function()
                -- self:SetMaxPoints(3)
                -- self:RegisterEvent("UNIT_AURA")
                self.UNIT_AURA = self.UNIT_COMBO_POINTS
                -- scanAura = GetSpellInfo(33745) -- Lacerate
                -- filter = "HARMFUL"
                -- allowedUnit = "target"
                -- allowedCaster = "player"
                GetComboPoints = dummy -- disable 
                local old1 = showEmpty
                local old2 = hideSlowly
                showEmpty = false
                hideSlowly = false
                self:UNIT_COMBO_POINTS(nil,allowedUnit) 
                showEmpty = old1
                hideSlowly = old2
            end


            local pulverize = function()
                self:SetMaxPoints(3)
                self:RegisterEvent("UNIT_AURA")
                self:RegisterEvent("PLAYER_TARGET_CHANGED")
                self.UNIT_AURA = self.UNIT_COMBO_POINTS
                soundFullEnabled = true
                scanAura = GetSpellInfo(33745) -- Lacerate
                filter = "HARMFUL"
                allowedUnit = "target"
                -- allowedCaster = "player"
                GetComboPoints = GetAuraStack
                self:UNIT_COMBO_POINTS(nil,allowedUnit) 
            end

            self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
            self.UPDATE_SHAPESHIFT_FORM = function(self)
                self:UnregisterEvent("UNIT_AURA")
                self:UnregisterEvent("UNIT_COMBO_POINTS")
                self:UnregisterEvent("PLAYER_TARGET_CHANGED")
                self:UnregisterEvent("PLAYER_TOTEM_UPDATE")
                local spec = GetSpecialization()
                local form = GetShapeshiftFormID()
                reset()
                if form == BEAR_FORM then
                    if spec == 3 and IsSpellKnown(80313) --pulverize
                        then pulverize()
                        else disable()
                    end
                elseif form == CAT_FORM then cat()
                elseif spec == 1 then
                    starsurge()
                -- elseif spec == 4 then
                    -- shrooms()
                else
                    disable()
                end
            end
            self:UPDATE_SHAPESHIFT_FORM()
        elseif class == "PALADIN" then
            local GetHolyPower = function(unit)
                return UnitPower(unit, SPELL_POWER_HOLY_POWER)
            end
            soundFullEnabled = true
            self:SetMaxPoints(3)
            self:RegisterEvent("UNIT_POWER")
            self.UNIT_POWER = function(self,event,unit,ptype)
                if ptype ~= "HOLY_POWER" or unit ~= "player" then return end
                self.UNIT_COMBO_POINTS(self,event,unit,ptype)
            end
            GetComboPoints = GetHolyPower
            self:RegisterEvent("SPELLS_CHANGED")
            self.SPELLS_CHANGED = function(self, event)
                if IsPlayerSpell(115675)  -- Boundless Conviction
                    then self:SetMaxPoints(5, "PALADIN")
                    else self:SetMaxPoints(3)
                end
            end
            self:SPELLS_CHANGED()
        elseif class == "MONK" then
            soundFullEnabled = true
            local GetChi = function(unit)
                return UnitPower(unit, SPELL_POWER_CHI)
            end
            local GetChiAndStagger = function(unit)
                --just to fill the second arg, everything is done in OnUpdate
                local stagger = UnitStagger("player")
                return UnitPower(unit, SPELL_POWER_CHI), (stagger and stagger > 0) and stagger or nil
            end

            local StaggerOnUpdate = function(self, time)
                self._elapsed = (self._elapsed or 0) + time
                if self._elapsed < 0.5 then return end
                self._elapsed = 0

                NugComboBar:UNIT_COMBO_POINTS(nil, "player")
            end

            local isCT = NugComboBarDB.classThemes

            self:SetMaxPoints(4, isCT and "4NO6")
            self:RegisterEvent("UNIT_POWER")
            self.UNIT_POWER = function(self,event,unit,ptype)
                if ptype ~= "CHI" or unit ~= "player" then return end
                self.UNIT_COMBO_POINTS(self,event,unit,ptype)
            end
            GetComboPoints = GetChi


            self.UNIT_MAXHEALTH = function(self, event, unit)
                self.bar:SetMinMaxValues(0, UnitHealthMax("player"))
            end
            self.UNIT_HEALTH = self.UNIT_COMBO_POINTS

            self:RegisterEvent("SPELLS_CHANGED")
            self.SPELLS_CHANGED = function(self, event)
                local wwperk = IsSpellKnown(157411) and 1 or 0

                if IsSpellKnown(115396)  -- Ascension
                    then self:SetMaxPoints(5+wwperk)
                    else self:SetMaxPoints(4+wwperk)
                end

                local spec = GetSpecialization()
                if spec == 1 then
                    GetComboPoints = GetChiAndStagger
                    self:EnableBar(0, UnitHealthMax("player"),"Long")
                    if self.bar then
                        self.bar:SetScript("OnUpdate", StaggerOnUpdate)
                        self:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
                        self:RegisterUnitEvent("UNIT_HEALTH", "player")
                    end
                else
                    GetComboPoints = GetChi
                    self:UnregisterEvent("UNIT_MAXHEALTH")
                    self:UnregisterEvent("UNIT_HEALTH")
                    self:DisableBar()
                end

                self:UNIT_COMBO_POINTS(nil,"player")
            end
            self:SPELLS_CHANGED()
        elseif class == "SHAMAN" then
            self:RegisterEvent("UNIT_AURA")
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            allowedUnit = "player"



            local LShield = GetSpellInfo(324) -- Lightning Shield
            local GetLightningShield = function(chargeSize)
                return function(unit)
                        local _,_,_, count, _,_,_, caster = UnitAura("player", LShield, nil, "HELPFUL")
                        if not count then return 0 end
                        if count == 1 then return 0 end
                        count = math.modf(count/chargeSize)
                        return count, nil, nil, nil
                    end
            end

            local GetLightningShield2 = function(unit)
                local _,_,_, count, _,_,_, caster = UnitAura("player", LShield, nil, "HELPFUL")
                if not count then
                    return 0, 1
                end

                if count >= 15 then
                    NugComboBar.bar:SetColor(unpack(NugComboBarDB.colors.bar2))
                else
                    NugComboBar.bar:SetColor(unpack(NugComboBarDB.colors.bar1))
                end

                return 0, count
            end

            local GetMaelstromT18 = function(unit)
                local _,_,_, count, _,_,_, caster = UnitBuff("player", GetSpellInfo(53817), nil)
                count = count or 0
                local secondRowCount = 0
                if count > 5 then
                    secondRowCount = count - 5
                    count = 5
                end

                return count, nil,nil, secondRowCount
            end

            self:RegisterEvent("SPELLS_CHANGED")
            self.SPELLS_CHANGED = function(self)
                local spec = GetSpecialization()
                if spec == 1 then
                    local showProgressBar = NugComboBarDB.fulminationBar
                    if showProgressBar then
                        defaultValue = 0
                        defaultProgress = 1
                        self:SetMaxPoints(5)
                        if self.bar then
                            showEmpty = true
                            local maxcharges = IsSpellKnown(157774) and 20 or 15
                            self:EnableBar(1, maxcharges, "Big")
                            GetComboPoints = GetLightningShield2
                        else
                            showEmpty = false
                            GetComboPoints = GetAuraStack
                        end
                    else
                        self:DisableBar()
                        self:SetMaxPoints(5, "SHAMAN5")
                        soundFullEnabled = true
                        GetComboPoints = GetLightningShield(IsSpellKnown(157774) and 4 or 3)
                    end
                elseif spec == 3 then
                    self:DisableBar()
                    self:SetMaxPoints(2)
                    scanAura = GetSpellInfo(51564) -- Tidal Waves
                    GetComboPoints = GetAuraStack
                else
                    NugComboBar.TrackItemSet("Enhancement_T18", {
                        124293, 124297, 124302, 124303, 124308, --normal
                    })
                    NugComboBar.RegisterSetBonusCallback("Enhancement_T18", 4,
                        function() NugComboBar:LoadClassSettings() end,
                        function() NugComboBar:LoadClassSettings() end
                    )

                    self:DisableBar()
                    soundFullEnabled = true
                    self:SetMaxPoints(5)
                    if NugComboBar.IsSetBonusActive("Enhancement_T18", 4) then
                    -- if true then
                        -- self:SetMaxPoints(10, "SHAMANDOUBLE")
                        GetComboPoints = GetMaelstromT18
                    else
                        scanAura = GetSpellInfo(53817) -- Maelstrom Weapon
                        GetComboPoints = GetAuraStack
                    end
                    -- GetComboPoints = GetAuraStack
                end
                self:UNIT_AURA(nil,allowedUnit)
            end
            self:SPELLS_CHANGED()
        elseif class == "WARLOCK" then
            local GetShards = function(unit)
                return UnitPower(unit, SPELL_POWER_SOUL_SHARDS)
            end
            local GetDemonicFury = function(unit)
                return 0, UnitPower(unit, SPELL_POWER_DEMONIC_FURY)
            end
            local GetBurningEmbers = function(unit)
                local maxPower = UnitPowerMax("player", SPELL_POWER_BURNING_EMBERS, true)
                local power = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true)
                local numEmbers = floor(power / MAX_POWER_PER_EMBER)
                local progress = math.fmod(power, MAX_POWER_PER_EMBER)
                return numEmbers, progress
            end
            self.UNIT_POWER = function(self,event,unit,ptype)
                if unit ~= "player" then return end
                if ptype == "SOUL_SHARDS" or ptype == "BURNING_EMBERS" or ptype == "DEMONIC_FURY" then
                    return self.UNIT_COMBO_POINTS(self,event,unit,ptype)
                end
            end

            local metaStatus
            self.UNIT_AURA = function(self, event, unit)
                if unit ~= "player" then return end
                local current = ( UnitAura("player", GetSpellInfo(WARLOCK_METAMORPHOSIS), nil, "HELPFUL") ~= nil)
                if metaStatus == current  then return end
                metaStatus = current
                if current then
                    self.bar:SetColor(unpack(NugComboBarDB.colors.bar2))
                else
                    self.bar:SetColor(unpack(NugComboBarDB.colors.bar1))
                end
            end
    
            self:SetMaxPoints(3)
            GetComboPoints = GetShards

            self.SPELLS_CHANGED = function(self, event)
                showEmpty = true
                self:UnregisterEvent("UNIT_AURA")
                -- self:DisableBar()
                local spec = GetSpecialization()
                if      spec == 3 then
                    self:EnableBar(0, MAX_POWER_PER_EMBER, "Small")
                    if self.bar then self.bar:SetColor(unpack(NugComboBarDB.colors.bar1)) end
                    local maxembers = UnitPowerMax( "player", SPELL_POWER_BURNING_EMBERS )
                    defaultValue = 1
                    defaultProgress = 0
                    self:SetMaxPoints(maxembers)
                    GetComboPoints = GetBurningEmbers
                    self:UNIT_POWER(nil,allowedUnit, "BURNING_EMBERS")
                elseif  spec == 1 and IsPlayerSpell(WARLOCK_SOULBURN) then
                    self:DisableBar()
                    local maxshards = UnitPowerMax( "player", SPELL_POWER_SOUL_SHARDS )
                    defaultValue = maxshards
                    self:SetMaxPoints(maxshards)
                    GetComboPoints = GetShards
                    self:UNIT_POWER(nil,allowedUnit, "SOUL_SHARDS" )
                elseif spec == 2 then
                    defaultValue = 0
                    defaultProgress = 200
                    if self.bar then
                        self:EnableBar(0, UnitPowerMax("player", SPELL_POWER_DEMONIC_FURY), "Big")
                        GetComboPoints = GetDemonicFury
                        self:RegisterEvent("UNIT_AURA")
                        self:UNIT_POWER(nil,allowedUnit, "DEMONIC_FURY" )
                        metaStatus = nil
                        self.UNIT_AURA(nil, allowedUnit)
                    else
                        showEmpty = false
                        GetComboPoints = GetAuraStack
                        self:UNIT_POWER(nil,allowedUnit, "SOUL_SHARDS" )
                    end
                end
            end
            self.GLYPH_UPDATED = self.SPELLS_CHANGED
            self.GLYPH_ADDED = self.GLYPH_UPDATED
            self.GLYPH_REMOVED = self.GLYPH_UPDATED
            
            self:SPELLS_CHANGED()

            self:RegisterEvent("GLYPH_UPDATED")
            self:RegisterEvent("GLYPH_ADDED")
            self:RegisterEvent("GLYPH_REMOVED")
            self:RegisterEvent("SPELLS_CHANGED")
            self:RegisterEvent("UNIT_POWER")
        elseif class == "WARRIOR" then
            self:SetMaxPoints(4)
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            allowedUnit = "player"
            GetComboPoints = GetAuraStack
            hideSlowly = false
            self:RegisterEvent("SPELLS_CHANGED")

            local proficiency = GetSpellInfo(169686)
            local GetProficiency = function(unit)
                local _,_,_, count, _, duration, expirationTime, caster = UnitAura("player", proficiency, nil, "HELPFUL")
                if not count then return 0 end
                local layer2count = 0
                if not secondLayerEnabled then
                    count = count > 3 and count - 3 or 0
                else
                    local a,rem = math.modf(count/2)
                    layer2count = a
                    count = (rem > 0) and a + 1 or a
                    -- if count > 3 then
                        -- layer2count = count - 3
                        -- count = 3
                    -- end
                end
                return count, expirationTime-duration, duration, layer2count
            end

            self.SPELLS_CHANGED = function(self)
                local spec = GetSpecialization()
                self:RegisterEvent("UNIT_AURA")
                if spec == 2 then 
                    self:EnableBar(0, 10, "Small")
                    if self.bar then self.bar:SetScript("OnUpdate", AuraTimerOnUpdate) end
                    if IsSpellKnown(157473) then
                        self:SetMaxPoints(4)
                    else
                        self:SetMaxPoints(3)
                    end
                    scanAura = GetSpellInfo(85739) -- Meatcleaver
                    GetComboPoints = GetAuraStack
                elseif spec == 3 and IsSpellKnown(169685) then
                    -- if not secondLayerEnabled then
                        self:SetMaxPoints(3)
                        self:EnableBar(0, 6, "Small")
                        -- scanAura = GetSpellInfo(169686) -- proficiency
                    -- else
                    GetComboPoints = GetProficiency
                    if self.bar then self.bar:SetScript("OnUpdate", AuraTimerOnUpdate) end
                else
                    self:UnregisterEvent("UNIT_AURA")
                end
            end
            self:SPELLS_CHANGED()
        elseif class == "HUNTER" then
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            GetComboPoints = GetAuraStack
            self:SetMaxPoints(5)
            filter = "HELPFUL"
            local bm = function()
                self:SetMaxPoints(5)
                self:RegisterEvent("UNIT_AURA")
                soundFullEnabled = true
                scanAura = GetSpellInfo(19615) -- Frenzy Effect
                allowedUnit = "pet"
                allowedCaster = "pet"
                GetComboPoints = GetAuraStack
            end
            self:RegisterEvent("SPELLS_CHANGED")
            self.SPELLS_CHANGED = function(self)
                local spec = GetSpecialization()
                if spec == 1 then return bm() end
                self:UnregisterEvent("UNIT_AURA")
            end
            self:SPELLS_CHANGED()
        elseif class == "DEATHKNIGHT" then
            self:SetMaxPoints(5)
            self:RegisterEvent("UNIT_AURA")
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            filter = "HELPFUL"
            allowedCaster = "player"

            local BloodChargeName = GetSpellInfo(114851)
            local ScentOfBlood = GetSpellInfo(50421)
            local ShadowInfusion = GetSpellInfo(91342)
            local GetBloodCharges = function(spec)
                return function(unit)
                    local _,_,_, count, _,_,_, caster = UnitAura("player", BloodChargeName, nil, "HELPFUL")
                    -- if not count then return 0 end
                    count = count or 0
                    local layer2count = 0
                    local barcount = nil
                    local fives,rem = math.modf(count/5)
                    if count > 10 then
                        if secondLayerEnabled and count == 12 then
                            layer2count = 2
                        else
                            barcount = count - 10
                        end
                    else
                        barcount = count - fives*5
                    end

                    local secondRowCount = nil
                    if spec == "Unholy" then
                        local _,_,_, count2, _,_,_, caster = UnitAura("pet", ShadowInfusion, nil, "HELPFUL")
                        secondRowCount = count2 or 0
                    else
                        if NugComboBarDB.special1 then
                            local _,_,_, count2, _,_,_, caster = UnitAura("player", ScentOfBlood, nil, "HELPFUL")
                            secondRowCount = count2 or 0
                        end
                    end
                    return fives, barcount, nil, layer2count, secondRowCount
                end
            end
            
            self:RegisterEvent("SPELLS_CHANGED")
            self.SPELLS_CHANGED = function(self, event)
                local spec = GetSpecialization()
                if      spec == 3 then -- unholy
                    if IsSpellKnown(45529) and NugComboBarDB.special1 then -- Blood Charges
                        self:EnableBar(0,5, "Small")
                        self:SetMaxPoints(2, "DKDOUBLE", 5)
                        GetComboPoints = GetBloodCharges("Unholy")
                    else
                        allowedUnit = "pet"
                        self:DisableBar()
                        self:SetMaxPoints(5)
                        scanAura = GetSpellInfo(91342) -- Shadow Infusion
                        GetComboPoints = GetAuraStack
                        soundFullEnabled = true
                    end
                elseif IsSpellKnown(45529) then
                    self:EnableBar(0,5, "Small")
                    GetComboPoints = GetBloodCharges("Blood")
                    if NugComboBarDB.special1 and spec == 1 then
                        self:SetMaxPoints(2, "DKDOUBLE", 5)
                    else
                        self:SetMaxPoints(2)
                    end
                elseif spec == 1 and NugComboBarDB.special1 then
                    allowedUnit = "player"
                    scanAura = GetSpellInfo(50421) -- Scent of Blood
                    GetComboPoints = GetAuraStack
                end
            end
            self:SPELLS_CHANGED()
        elseif class == "PRIEST" then
            local GetShadowOrbs = function(unit)
                return UnitPower(unit, SPELL_POWER_SHADOW_ORBS)
            end
            self:SetMaxPoints(3)
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            self.UNIT_POWER = function(self,event,unit,ptype)
                if ptype ~= "SHADOW_ORBS" or unit ~= "player" then return end
                self.UNIT_COMBO_POINTS(self,event,unit,ptype)
            end
            allowedUnit = "player"
            local shadow_orbs = function()
                self:DisableBar()
                self:RegisterEvent("UNIT_POWER")
                self:UnregisterEvent("UNIT_AURA")
                if IsSpellKnown(157217) then
                    self:SetMaxPoints(5, "PALADIN")
                else
                    self:SetMaxPoints(3)
                end
                
                GetComboPoints = GetShadowOrbs
                soundFullEnabled = true
            end
            local evangelism = function()
                self:SetMaxPoints(5)
                self:EnableBar(0, 20, "Long")
                if self.bar then self.bar:SetScript("OnUpdate", AuraTimerOnUpdate) end
                self:RegisterEvent("UNIT_AURA")
                self:UnregisterEvent("UNIT_POWER")
                GetComboPoints = GetAuraStack
                scanAura = GetSpellInfo(81661) -- Evangelism
            end
            local serendipity = function()
                self:SetMaxPoints(2)
                self:DisableBar()
                -- self:EnableBar(0, 20,"Small")
                -- if self.bar then self.bar:SetScript("OnUpdate", AuraTimerOnUpdate) end
                self:RegisterEvent("UNIT_AURA")
                self:UnregisterEvent("UNIT_POWER")
                GetComboPoints = GetAuraStack
                scanAura = GetSpellInfo(63735) -- Serendipity
            end
            self:RegisterEvent("SPELLS_CHANGED")
            self.SPELLS_CHANGED = function(self, event)
                local spec = GetSpecialization()
                if spec == 3 then
                    shadow_orbs()
                elseif spec == 2 then
                    serendipity()
                else
                    evangelism()
                end
            end
            self:SPELLS_CHANGED()
        elseif class == "MAGE" then 
            self:RegisterEvent("UNIT_AURA")
            self.UNIT_AURA = self.UNIT_COMBO_POINTS 

            self:RegisterEvent("SPELLS_CHANGED")
            self.SPELLS_CHANGED = function(self, event)
                local spec = GetSpecialization()
                self:SetMaxPoints(4)
                if spec == 1 then
                    local showMissileProcs = NugComboBarDB.special1
                    if showMissileProcs then
                        self:SetMaxPoints(4, "ARCANE", 3)
                        local arcaneCharges = GetSpellInfo(36032)
                        local arcaneMissiles = GetSpellInfo(79683)
                        local GetChargesAndBarrage = function(unit)
                            local _,_,_, count1 = UnitAura("player", arcaneCharges, nil, "HARMFUL")
                            local _,_,_, count2 = UnitAura("player", arcaneMissiles, nil, "HELPFUL")
                            return count1 or 0, 0, nil, nil, count2 or 0 -- for second line
                        end
                        -- scanAura = GetSpellInfo(36032) -- Arcane Blast Buff
                        -- filter = "HARMFUL"
                        -- allowedUnit = "player"
                        GetComboPoints = GetChargesAndBarrage
                    else
                        self:DisableBar()
                        self:SetMaxPoints(4)
                        scanAura = GetSpellInfo(36032) -- Arcane Blast Buff
                        filter = "HARMFUL"
                        GetComboPoints = GetAuraStack
                    end
                else
                    self:DisableBar()
                    self:SetMaxPoints(5)
                    scanAura = GetSpellInfo(116267) -- Incanter's Flow Buff
                    filter = "HELPFUL"
                    GetComboPoints = GetAuraStack
                end
            end
            self:SPELLS_CHANGED()
        else
            self:SetMaxPoints(2)
            return
        end
end

local defaults = {
    apoint = "CENTER",
    parent = "UIParent",
    point = "CENTER", --to
    x = 0, y = 0,
    anchorpoint = "LEFT",
    scale = 1.0,
    showEmpty = false,
    hideSlowly = true,
    disableBlizz = false,
    colors = {
        [1] = {0.77,0.26,0.29},
        [2] = {0.77,0.26,0.29},
        [3] = {0.77,0.26,0.29},
        [4] = {0.77,0.26,0.29},
        [5] = {0.77,0.26,0.29},
        [6] = {0.77,0.26,0.29},
        [7] = {0.77,0.26,0.29},
        [8] = {0.77,0.26,0.29},
        [9] = {0.77,0.26,0.29},
        [10] = {0.77,0.26,0.29},
        ["bar1"] = { 0.9,0.1,0.1 },
        ["bar2"] = { .9,0.1,0.4 },
        ["layer2"] = { 0.80, 0.23, 0.79 },
    },
    enable3d = true,
    preset3d = "glowPurple",
    preset3dlayer2 = "fireOrange",
    preset3dpointbar2 = "fireOrange",
    classThemes = false,
    secondLayer = true,
    colors3d = true,
    showAlways = false,
    onlyCombat = false,
    disableProgress = false,
    adjustX = 2.05,
    adjustY = 2.1,
    alpha = 1,
    special1 = false,
    hideWithoutTarget = false,
    vertical = false,
    soundChannel = "SFX",
    soundNameFull = "none",
    soundNameFullCustom = "Interface\\AddOns\\YourSound.mp3",
    disabled = false,
}
NugComboBar.defaults = defaults

local function SetupDefaults(t, defaults)
    for k,v in pairs(defaults) do
        if type(v) == "table" then
            if t[k] == nil then
                t[k] = CopyTable(v)
            else
                SetupDefaults(t[k], v)
            end
        else
            if t[k] == nil then t[k] = v end
        end
    end
end
local function RemoveDefaults(t, defaults)
    for k, v in pairs(defaults) do
        if type(t[k]) == 'table' and type(v) == 'table' then
            RemoveDefaults(t[k], v)
            if next(t[k]) == nil then
                t[k] = nil
            end
        elseif t[k] == v then
            t[k] = nil
        end
    end
    return t
end


NugComboBar.SkinVersion = 500
do 
    local initial = true
    function NugComboBar.ADDON_LOADED(self,event,arg1)
        if arg1 == "NugComboBar" then
            if initial then
                SLASH_NCBSLASH1 = "/ncb";
                SLASH_NCBSLASH2 = "/nugcombobar";
                SLASH_NCBSLASH3 = "/NugComboBar";
                SlashCmdList["NCBSLASH"] = NugComboBar.SlashCmd
            end
            
            NugComboBarDB_Global = NugComboBarDB_Global or {}
            NugComboBarDB_Character = NugComboBarDB_Character or {}
            NugComboBarDB_Character.specspec = NugComboBarDB_Character.specspec or {}
            local _,class = UnitClass("player")
            NugComboBarDB_Global.charspec = NugComboBarDB_Global.charspec or {}
            user = UnitName("player").."@"..GetRealmName()

            if not initial then
                RemoveDefaults(NugComboBarDB, defaults)
            end

            if NugComboBarDB_Global.charspec[user] then -- old format compatibility
                NugComboBarDB_Global.charspec[user] = nil
                NugComboBarDB_Character.charspec = true
            end

            -- local NugComboBarDBSource
            if NugComboBarDB_Character.charspec then
                local spec = GetSpecialization()
                if spec and NugComboBarDB_Character.specspec[spec] then
                    NugComboBarDB_Character.specdb = NugComboBarDB_Character.specdb or {}
                    NugComboBarDB_Character.specdb[spec] = NugComboBarDB_Character.specdb[spec] or {}

                    NugComboBarDBSource = NugComboBarDB_Character.specdb[spec]
                else
                    NugComboBarDBSource = NugComboBarDB_Character
                end
            else
                NugComboBarDBSource = NugComboBarDB_Global
            end


            if not NugComboBarDBSource.apoint and NugComboBarDBSource.point then NugComboBarDBSource.apoint = NugComboBarDBSource.point end
            SetupDefaults(NugComboBarDBSource, defaults)
            if not NugComboBarDB_Global.adjustX then NugComboBarDB_Global.adjustX = defaults.adjustX end
            if not NugComboBarDB_Global.adjustY then NugComboBarDB_Global.adjustY = defaults.adjustY end

            if NugComboBarDBSource.classThemes then
                NugComboBarDB = setmetatable({
                    __classTheme = nil,
                    colors = {}
                }, {
                    __index = function(t,k)
                        local ct = rawget(t, "__classTheme")
                        if ct and ct[k] then
                            return ct[k]
                        else
                            return NugComboBarDBSource[k]
                        end
                    end,
                    __newindex = function(t,k,v)
                        NugComboBarDBSource[k] = v
                    end,
                })

                setmetatable(NugComboBarDB.colors, {
                        __index = function(t,k)
                            local ct = NugComboBarDB.__classTheme
                            if not ct then return NugComboBarDBSource.colors[k] end
                            local ctc = rawget(ct, "colors")
                            if not ctc then return NugComboBarDBSource.colors[k] end
                            if ctc[k] then return ctc[k] end
                            if not ctc[k] and type(k) == 'number' then
                                if ctc.normal then return ctc.normal end
                            end
                            return NugComboBarDBSource.colors[k]
                        end,
                        __newindex = function(t,k,v)
                        end,
                    })

            else
                NugComboBarDB = NugComboBarDBSource
            end

            NugComboBar.isDisabled = nil
            if type(NugComboBarDBSource.disabled) == "table" then NugComboBarDBSource.disabled = nil end --old format bugfix
            NugComboBarDB_Global.disabled = nil
            if NugComboBarDB.disabled then
                NugComboBar.isDisabled = true
                NugComboBar:SuperDisable()
            end

            -- self:RegisterEvent("PLAYER_LOGIN")
            self:RegisterEvent("PLAYER_LOGOUT")

            if NugComboBarDB.disableBlizz then NugComboBar.disableBlizz() end

            if initial then
                local f = CreateFrame('Frame', nil, InterfaceOptionsFrame) -- helper frame to load GUI and to watch specialization changes
                f:SetScript('OnShow', function(self)
                    self:SetScript('OnShow', nil)
                    LoadAddOn('NugComboBarGUI')
                end)

                f:RegisterEvent("SPELLS_CHANGED")
                f:SetScript("OnEvent", function()
                    NugComboBar:OnSpecChanged()
                end)
            end
            
    --~         self:RegisterEvent("UPDATE_STEALTH")
    --~         self:RegisterEvent("UNIT_DISPLAYPOWER")
    --~         self.UNIT_DISPLAYPOWER = self.UPDATE_STEALTH
            initial = false
        end
    end
end
function NugComboBar.PLAYER_LOGOUT(self, event)
    RemoveDefaults(NugComboBarDB, defaults)
end




NugComboBar.soundFiles = {
    ["none"] = "none",
    ["gm_chatwarning"] = "Sound\\INTERFACE\\GM_ChatWarning.ogg",
    ["coldblood"] = "Sound\\Spells\\ColdBlood.ogg",
    ["alarmclockwarning3"] = "Sound\\INTERFACE\\AlarmClockWarning3.ogg",
    ["auctionwindowopen"] = "Sound\\INTERFACE\\AuctionWindowOpen.ogg",
    ["wispwhat1"] = "Sound\\Event Sounds\\Wisp\\WispWhat1.ogg",
    ["custom"] = "custom",
}
NugComboBar.soundChoices = {
    "none",
    "gm_chatwarning",
    "coldblood",
    "alarmclockwarning3",
    "auctionwindowopen",
    "wispwhat1",
    "custom",
}



local trim = function(v)
    return math.floor(v*1000)/1000
end

local ResolutionOffsets = {
    [trim(48/9)] = { 0.77, 0.75 },
    [trim(16/10)] = { 2.25, 2.25 },
    [trim(16/9)] = { 2.05, 2.1 },
    [trim(4/3)] = { 2.5, 2.5 },
}

function NugComboBar:CheckResolution()
    local maximized = GetCVar("gxMaximize") == "1"
    -- GetCVar("gxWindow")
    local aspectratio
    if maximized then
        aspectratio = trim(GetMonitorAspectRatio())
    else
        local res = GetCVar("gxResolution")
        local w,h = string.match(res, "(%d+)x(%d+)")
        aspectratio = trim(w/h)
    end
    
    local offsets = ResolutionOffsets[aspectratio]
    if not offsets then
        print("NCB: Unknown game resolution, adjust offsets manually")
    else
        NugComboBarDB_Global.adjustX, NugComboBarDB_Global.adjustY = unpack(offsets)
        self._disableOffsetSettings = true
    end
end


function NugComboBar:SetupClassTheme()
    if not NugComboBarDB.classThemes then return end
    local _, class = UnitClass("player")
    local spec = GetSpecialization()
    local cT = NugComboBar.themes[class]
    if not cT then return rawset(NugComboBarDB,"__classTheme", nil) end
    local sT = cT[spec] or cT[0]
    rawset(NugComboBarDB,"__classTheme", sT)
end

function NugComboBar:IsDefaultSkin()
    return not IsAddOnLoaded("NugComboBarMakina") and not  IsAddOnLoaded("NugComboBarStriped")
end

do
    local initial = true
    function NugComboBar.PLAYER_LOGIN(self, event)
        if initial then
            self:CheckResolution()
        end

        local isDefaultSkin = NugComboBar:IsDefaultSkin()
        -- backward compatibility to old skins, for default there should be just :Create
        if isDefaultSkin then
            self:Create()
        else if initial then self:Create() end
        end

        -- -- class themes
        -- if NugComboBar:IsDefaultSkin() and NugComboBarDB.classThemes and NugComboBarDB.enable3d then
        --     local _, class = UnitClass("player")
        --     local spec = GetSpecialization()
        --     local preset = NugComboBar.themes[class].preset
        --     local colors = NugComboBar.themes[class].colors
        --     local usecolors = colors ~= nil

        --     NugComboBar:Set3DPreset(preset3d, preset3dlayer2)
        -- end


        if NugComboBarDB.disableProgress then
            NugComboBar.EnableBar_ = NugComboBar.EnableBar
            NugComboBar.EnableBar = NugComboBar.DisableBar
            NugComboBar:DisableBar()
        end

        showEmpty = NugComboBarDB.showEmpty
        showAlways = NugComboBarDB.showAlways
        onlyCombat = NugComboBarDB.onlyCombat
        hideSlowly = NugComboBarDB.hideSlowly
        if secondLayerEnabled == nil then secondLayerEnabled = NugComboBarDB.secondLayer end;
        self:SetAlpha(0)

        if NugComboBarDB.scale < 0.93 and string.find(NugComboBarDB.preset3d, "funnel") then
            print("[NugComboBar] funnelXXXX presets do not work on a scale below 0.9.")
            NugComboBarDB.scale = 1
        end
        self:SetScale(NugComboBarDB.scale)

        self.Commands.anchorpoint(NugComboBarDB.anchorpoint)

        self:LoadClassSettings()
        if initial then
            self:CreateAnchor()
        else
            self.anchor:ClearAllPoints()
            self.anchor:SetPoint(NugComboBarDB.apoint, NugComboBarDB.parent, NugComboBarDB.point,NugComboBarDB.x,NugComboBarDB.y)
        end

        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
        self:RegisterEvent("PET_BATTLE_OPENING_START")
        self:RegisterEvent("PET_BATTLE_CLOSE")
        self.PLAYER_ENTERING_WORLD = self.CheckComboPoints -- Update on looading screen to clear after battlegrounds
        self.PLAYER_REGEN_ENABLED = self.CheckComboPoints
        self.PLAYER_REGEN_DISABLED = self.CheckComboPoints
        self.PET_BATTLE_OPENING_START = self.CheckComboPoints
        self.PET_BATTLE_CLOSE = self.CheckComboPoints

        initial = false
        --self:AttachAnimationGroup()
        -- self:UNIT_COMBO_POINTS("INIT", allowedUnit, nil, true)
    end
end

--~ function NugComboBar.UPDATE_STEALTH(self)
--~     if (IsStealthed() or UnitAffectingCombat("player")) and UnitPowerType("player") == 3 then
--~         self:UNIT_MAXENERGY()
--~         self:UpdateEnergy()
--~         self:Show()
--~     else
--~         self:Hide()
--~     end
--~ end
--~ function NugComboBar.UNIT_AURA(self, event, unit)
--~     if allowedUnits[unit] then self:UNIT_COMBO_POINTS(event,unit)end
--~ end

-- function NugComboBar.AddHidingAnimation(self)
--     local ag = self:CreateAnimationGroup()
--     local a1 = ag:CreateAnimation("Alpha")
--     a1:SetChange(0)
--     a1:SetDuration(4)
--     a1:SetOrder(1)

--     local a2 = ag:CreateAnimation("Alpha")
--     a2:SetChange(-1)
--     a2:SetDuration(2)
--     a2:SetOrder(2)

--     self.HideAnim = ag
--     ag:SetScript("OnFinished",function(self)
--         self:GetParent():SetAlpha(0)
--     end)
-- endir
local fadeTime = 1
local fader = CreateFrame("Frame")
local HideTimer = function(self, time)
    self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
    if self.OnUpdateCounter < fadeAfter then return end

    local ncb = NugComboBar
    local a = 1-((self.OnUpdateCounter - fadeAfter) / fadeTime)
    ncb:SetAlpha(NugComboBarDB.alpha*a)
    if self.OnUpdateCounter >= fadeAfter + fadeTime then
        self:SetScript("OnUpdate",nil)
        ncb:SetAlpha(0)
        ncb.hiding = false
        self.OnUpdateCounter = 0
    end
end


function NugComboBar.PLAYER_TARGET_CHANGED(self, event)
    self:UNIT_COMBO_POINTS(event, allowedUnit)
    if not UnitExists("target") and NugComboBarDB.hideWithoutTarget then
        self:Hide()
    end
end

function NugComboBar.CheckComboPoints(self)
    self:UNIT_COMBO_POINTS(event, allowedUnit, nil)
end

-- local frame = CreateFrame("Frame")
-- local tfunc = function(self,time)
--     self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
--     if self.OnUpdateCounter < 0 then return end
--     self.OnUpdateCounter = 0

--     OldFunc = GetComboPoints
--     local ptype = self.ptype
--     local unit = self.unit
--     GetComboPoints = function(unit) return OldFunc(unit)+1 end
--     NugComboBar:UNIT_COMBO_POINTS(-1, unit, ptype)
--     GetComboPoints = OldFunc
   
--     self.started = nil
--     self:SetScript("OnUpdate", nil) 
-- end

function NugComboBar.EnableBar(self, min, max, btype)
    if not self.bar then return end
    self.bar.enabled = true
    if min and max then self.bar:SetMinMaxValues(min, max) end
    self.bar.max = max
    if btype and self.bar[btype] then self.bar[btype](self.bar) end
    self.bar:Show()
end

function NugComboBar.DisableBar(self)
    if not self.bar then return end
    self.bar.enabled = false
    self.bar:Small()
    self.bar:Hide()
end

local function AnticipationIn(point, i)
    local r,g,b = unpack(NugComboBarDB.colors["layer2"])
    point:SetColor(r,g,b)
    point.anticipationColor = true

    point:SetPreset(NugComboBarDB.preset3dlayer2)
end

local function AnticipationOut(point, i)
    local r,g,b = unpack(NugComboBarDB.colors[i])
    point:SetColor(r,g,b)
    point.anticipationColor = false

    point:SetPreset(NugComboBarDB.preset3d)
end


local comboPointsBefore = 0
-- local lastChangeTimer = CreateFrame("Frame")
-- local lastChangeOnUpdate = function(self, time)
--     self._elapsed = (self._elapsed or 0) + time
--     if self._elapsed < 10 then return end
--     self._elapsed = 0
--     print(GetTime(), "UNIT_COMBO_POINTS(nil, allowedUnit)")
--     NugComboBar:UNIT_COMBO_POINTS(nil, allowedUnit)
--     lastChangeTimer:SetScript("OnUpdate", nil)
-- end
-- local lastChangeValue
-- local lastChangeTime = GetTime()
local targetBefore
function NugComboBar.UNIT_COMBO_POINTS(self, event, unit, ptype)
    if unit ~= allowedUnit then return end

    if onlyCombat and not UnitAffectingCombat("player") then return self:Hide() else self:Show() end -- usually frame is set to 0 alpha
    -- local arg1, arg2
    local comboPoints, arg1, arg2, secondLayerPoints, secondBarPoints = GetComboPoints(unit);
    -- print(comboPoints, arg1, arg2, secondLayerPoints, secondBarPoints)
    local progress = not arg2 and arg1 or nil
    if self.bar and self.bar.enabled then
        if arg1 then
            self.bar:Show()
            if arg2 then
                local startTime, duration = arg1, arg2
                self.bar.startTime = startTime
                self.bar.duration = duration
            else
                self.bar:SetValue(progress)
            end
        else
            self.bar:Hide()
        end
    end

    if soundFullEnabled then
        if  comboPoints == self.MAX_POINTS and
            comboPoints ~= comboPointsBefore and
            -- comboPointsBefore ~= 0 then
            UnitGUID(allowedTargetUnit) == targetBefore then
                    local sn = NugComboBarDB.soundNameFull
                    local sound = (sn == "custom") and NugComboBarDB.soundNameFullCustom or NugComboBar.soundFiles[NugComboBarDB.soundNameFull]
                    PlaySoundFile(sound, NugComboBarDB.soundChannel)
        end
        targetBefore = UnitGUID(allowedTargetUnit)
    end

    for i = 1, self.MAX_POINTS do
        local point = self.p[i]
        if i <= comboPoints then
            point:Activate()
        end
        if i > comboPoints then
            point:Deactivate()
        end

        if secondLayerPoints then -- Anticipation stuff
            if i <= secondLayerPoints then              
                if  (point.currentPreset and point.currentPreset ~= NugComboBarDB.preset3dlayer2)
                    or
                    (not point.anticipationColor) then

                    point:Reappear(AnticipationIn, i)
                end
            else
                if  (point.currentPreset and point.currentPreset ~= NugComboBarDB.preset3d)
                    or
                    (point.anticipationColor) then

                    if i <= comboPoints then
                        point:Reappear(AnticipationOut, i)
                    else
                        AnticipationOut(point, i)
                    end
                end
            end
        end
    end

    --second bar
    if self.MAX_POINTS2 then
    for i = 1, self.MAX_POINTS2 do
        local point = self.p[i+self.MAX_POINTS]
        if i <= secondBarPoints then
            point:Activate()
        end
        if i > secondBarPoints then
            point:Deactivate()
        end
    end
    end

    -- print("progress", progress)
    -- print (comboPoints, defaultValue, comboPoints == defaultValue, (progress == nil or progress == defaultProgress), not UnitAffectingCombat("player"), not showEmpty)
    local forceHide = C_PetBattles.IsInBattle()
    if forceHide or 
        (
            not showAlways and
            comboPoints == defaultValue and -- or (defaultValue == -1 and lastChangeTime < GetTime() - 9)) and
            (progress == nil or progress == defaultProgress) and
            (not UnitAffectingCombat("player") or not showEmpty)
        )
        then
            local hidden = self:GetAlpha() == 0
            if hideSlowly and not forceHide then
                -- print("hiding, hidden:", self.hiding, hidden)
                if (not self.hiding and not hidden)  then
                    -- print("start hiding")
                    fader:SetScript("OnUpdate", HideTimer)
                    fader.OnUpdateCounter = 0
                    self.hiding = true
                end
            else
                self:SetAlpha(0)
            end
    else
        fader:SetScript("OnUpdate", nil)
        self.hiding = false
        self:SetAlpha(NugComboBarDB.alpha)
    end

    comboPointsBefore = comboPoints

    -- if defaultValue == -1 then
    --         lastChangeTime = GetTime()
    --         lastChangeTimer:SetScript("OnUpdate", lastChangeOnUpdate)
    --         print(GetTime(), 'lastChange!')
    --         lastChangeTimer._elapsed = 0
    -- else
    --     lastChangeTimer:SetScript("OnUpdate", nil)
    -- end

    -- if event ~= -1 then
    --     tframe.started = true
    --     tframe.unit = unit
    --     tframe.ptype = ptype
    --     tframe:SetScript("OnUpdate", tfunc)
    -- end
end

function NugComboBar.SetColor(point, r, g, b)
    if b then
        NugComboBarDB.colors[point] = {r,g,b}
    else
        local clr = NugComboBarDB.colors[point]
        if not clr then return end
        r,g,b = unpack(clr)
    end
    if NugComboBar.bar and point == "bar1" then
        return NugComboBar.bar:SetColor(r,g,b)
    end

    local p = NugComboBar.p[point]
    if p then
        return p:SetColor(r,g,b)
    end
end

-- function NugComboBar.AttachAnimationGroup(self)
--     local ag = self:CreateAnimationGroup()
--     local a1 = ag:CreateAnimation("Rotation")
--     a1:SetDegrees(90)
--     a1:SetDuration(0.1)
--     a1:SetOrder(1)
--     a1.ag = ag
--     a1:SetScript("OnFinished",function(self)
--         self.ag:Pause();
--     end)
--     self.rag = ag
--     ag:Play()
-- end

function NugComboBar.CreateAnchor(frame)
    local self = CreateFrame("Frame",nil,UIParent)
    self:SetWidth(10)
    self:SetHeight(frame:GetHeight())
    self:SetBackdrop{
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 0,
        insets = {left = -2, right = -2, top = -2, bottom = -2},
    }
	self:SetBackdropColor(1, 0, 0, 0.8)
    self:SetFrameStrata("HIGH")
    
    self:SetPoint(NugComboBarDB.apoint, NugComboBarDB.parent, NugComboBarDB.point,NugComboBarDB.x,NugComboBarDB.y)
    local p1 = NugComboBarDB.anchorpoint
    local p2
    if      p1 == "LEFT" then p2 = "RIGHT"
    elseif  p1 == "RIGHT" then p2 = "LEFT"
    elseif  p1 == "TOP" then p2 = "BOTTOM"
    end
    frame:SetPoint(p1,self,p2,0,0)
    
    
    self:EnableMouse(true)
    self:RegisterForDrag("LeftButton")
    self:SetMovable(true)
    self:SetScript("OnDragStart",function(self) self:StartMoving(); self:SetUserPlaced(false) end)
    self:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing();
        self:SetUserPlaced(false)
        NugComboBarDB.apoint, _, NugComboBarDB.point, NugComboBarDB.x, NugComboBarDB.y = self:GetPoint(1)
        NugComboBarDB.parent = "UIParent"
    end)
    
    self:Hide()
    frame.anchor = self
end



function NugComboBar.ShowColorPicker(self,color)
    ColorPickerFrame:Hide()
    local upcolor = (color > 0) and color or 5
    NugComboBar.colorPickerColor = color
    ColorPickerFrame:SetColorRGB(unpack(NugComboBarDB.colors[upcolor]))
    ColorPickerFrame.hasOpacity = false
    ColorPickerFrame.previousValues = {unpack(NugComboBarDB.colors[upcolor])} -- otherwise we'll get reference to changed table
    ColorPickerFrame.func = function(previousValues)
        local r,g,b
        local color = NugComboBar.colorPickerColor
        if previousValues then
            r,g,b = unpack(previousValues)
        else
            r,g,b = ColorPickerFrame:GetColorRGB();
        end
        if color == 0 then
            for i=1,#self.point do
                NugComboBar.SetColor(i,r,g,b)
            end
        elseif color == -1 then
            for i=1, self.MAX_POINTS2 do
                local index = i+self.MAX_POINTS
                NugComboBar.SetColor(index,r,g,b)
            end
        else
            NugComboBar.SetColor(color,r,g,b)
        end
    end
    ColorPickerFrame.cancelFunc = ColorPickerFrame.func
    ColorPickerFrame:Show()
end

function NugComboBar.Set3DPreset(self, preset, preset2)
    local e1 = preset or NugComboBarDB.preset3d
    local e2 = preset2 or NugComboBarDB.preset3dpointbar2
    -- for _, point in pairs(self.point) do
    for i = 1, self.MAX_POINTS do
        local p = self.p[i]
        p:SetPreset(e1)
    end
    if self.MAX_POINTS2 then
    for i = 1, self.MAX_POINTS2 do
        local p = self.p[self.MAX_POINTS+i]
        p:SetPreset(e2)
    end
    end
end

function NugComboBar.Reinitialize(self)
    NugComboBar:ADDON_LOADED(nil, "NugComboBar")
    if LibStub then
        local cfgreg = LibStub("AceConfigRegistry-3.0", true)
        if cfgreg then cfgreg:NotifyChange("NugComboBar-General") end
    end
    if not NugComboBar.isDisabled then
        NugComboBar:PLAYER_LOGIN(nil)
        NugComboBar:PLAYER_ENTERING_WORLD(nil)
        if NugComboBar.anchor:IsVisible() then
            NugComboBar.Commands.unlock()
        end
    end
end

local ParseOpts = function(str)
    local fields = {}
    for opt,args in string.gmatch(str,"(%w*)%s*=%s*([%w%,%-%_%.%:%\\%']+)") do
        fields[opt:lower()] = tonumber(args) or args
    end
    return fields
end
NugComboBar.Commands = {
    ["unlock"] = function(v)
        NugComboBar.anchor:Show()
        NugComboBar:SetAlpha(NugComboBarDB.alpha)
        for i=1,NugComboBar.MAX_POINTS do
            NugComboBar.p[i]:Activate()
        end
    end,
    ["lock"] = function(v)
        NugComboBar.anchor:Hide()
        NugComboBar:UNIT_COMBO_POINTS(nil, allowedUnit)
    end,
    ["reset"] = function(v)
        NugComboBar.anchor:ClearAllPoints()
        NugComboBar.anchor:SetPoint("CENTER",UIParent,"CENTER",0,0)
    end,
    ["anchorpoint"] = function(v)
        local ap = v:upper()
        if ap ~= "RIGHT" and ap ~="LEFT" and ap ~= "TOP" then print ("Current anchor point is: "..NugComboBarDB.anchorpoint); return end
        NugComboBarDB.anchorpoint = ap
        local p1 = NugComboBarDB.anchorpoint
        local p2
        if      p1 == "LEFT" then p2 = "RIGHT"
        elseif  p1 == "RIGHT" then p2 = "LEFT"
        elseif  p1 == "TOP" then p2 = "BOTTOM"
        end
        NugComboBar:ClearAllPoints()
        NugComboBar:SetPoint(p1,NugComboBar.anchor,p2,0,0)
    end,
    ["showempty"] = function(v)
        NugComboBarDB.showEmpty = not NugComboBarDB.showEmpty
        showEmpty = NugComboBarDB.showEmpty
        NugComboBar:PLAYER_TARGET_CHANGED()
    end,
    ["showalways"] = function(v)
        NugComboBarDB.showAlways = not NugComboBarDB.showAlways
        showAlways = NugComboBarDB.showAlways
        NugComboBar:PLAYER_TARGET_CHANGED()
    end,
    ["onlycombat"] = function(v)
        NugComboBarDB.onlyCombat = not NugComboBarDB.onlyCombat
        onlyCombat = NugComboBarDB.onlyCombat
        NugComboBar:PLAYER_TARGET_CHANGED()
    end,
    ["hideslowly"] = function(v)
        NugComboBarDB.hideSlowly = not NugComboBarDB.hideSlowly
        hideSlowly = NugComboBarDB.hideSlowly
    end,
    ["toggleblizz"] = function(v)
        NugComboBarDB.disableBlizz = not NugComboBarDB.disableBlizz
        print ("NCB> Changes will take effect after /reload")
    end,
    ["special"] = function(v)
        NugComboBarDB.special1 = not NugComboBarDB.special1
        print ("NCB Special = ", NugComboBarDB.special1)
    end,
    ["scale"] = function(v)
        local num = tonumber(v)
        if num then 
            NugComboBarDB.scale = num; NugComboBar:SetScale(NugComboBarDB.scale);
        else print ("Current scale is: ".. NugComboBarDB.scale)
        end
    end,
    ["alpha"] = function(v)
        local num = tonumber(v)
        if num then 
            NugComboBarDB.alpha = num; NugComboBar:SetAlpha(NugComboBarDB.alpha);
        else print ("Current alpha is: ".. NugComboBarDB.alpha)
        end
    end,
    ["disable"] = function(v)
        if not NugComboBarDB_Character.charspec then return end
        if NugComboBarDB.disabled then
            NugComboBarDB.disabled = false
        else
            NugComboBarDB.disabled = true
        end
        NugComboBar:Reinitialize()
        -- print ("NCB> Disabled for current class. Changes will take effect after /reload")
    end,
    ["changecolor"] = function(v)
        local num = tonumber(v)
        if num then 
            NugComboBar:ShowColorPicker(num)
        end
    end,
    ["adjustx"] = function(v)
        local num = tonumber(v)
        if num then
            NugComboBarDB_Global.adjustX = num
            for i,point in ipairs(NugComboBar.point) do
                point:SetPreset(point.currentPreset)
            end
        end
    end,
    ["adjusty"] = function(v)
        local num = tonumber(v)
        if num then
            NugComboBarDB_Global.adjustY = num
            for i,point in ipairs(NugComboBar.point) do
                point:SetPreset(point.currentPreset)
            end
        end
    end,
    ["hidewotarget"] = function(v)
        NugComboBarDB.hideWithoutTarget = not NugComboBarDB.hideWithoutTarget
    end,
    ["charspec"] = function(v)
        if NugComboBarDB_Character.charspec then
            NugComboBarDB_Character.charspec = nil
        else
            NugComboBarDB_Character.charspec = true
        end

        NugComboBar:Reinitialize()
    end,
    ["specspec"] = function(v)
        if not NugComboBarDB_Character.charspec then print("Character-specific should be enabled first"); return end

        local spec = GetSpecialization()
        if not spec or spec == 0 then
            return
        end
        if NugComboBarDB_Character.specspec[spec] then
            NugComboBarDB_Character.specspec[spec] = nil
        else
            NugComboBarDB_Character.specspec[spec] = true
        end

        NugComboBar:Reinitialize()
    end,
    ["secondlayer"] = function(v)
        NugComboBarDB.secondLayer = not NugComboBarDB.secondLayer
        secondLayerEnabled = NugComboBarDB.secondLayer
    end,
    ["toggleprogress"] = function(v)
        NugComboBarDB.disableProgress = not NugComboBarDB.disableProgress
        if NugComboBarDB.disableProgress then
            NugComboBar.EnableBar_ = NugComboBar.EnableBar
            NugComboBar.EnableBar = NugComboBar.DisableBar
            NugComboBar:DisableBar()
        else
            NugComboBar.EnableBar = NugComboBar.EnableBar_
            NugComboBar:LoadClassSettings()
        end
    end,
    ["toggle3d"] = function(v)
        NugComboBarDB.enable3d = not NugComboBarDB.enable3d
        print (string.format("NCB> 3D mode is %s, it will take effect after /reload", NugComboBarDB.enable3d and "enabled" or "disabled"))
    end,
    ["classthemes"] = function(v)
        NugComboBarDB.classThemes = not NugComboBarDB.classThemes
        NugComboBar:Reinitialize()
    end,
    ["preset3d"] = function(v)
        if not NugComboBar.presets[v] then
            return print(string.format("Preset '%s' does not exist", v))
        end
        NugComboBarDB.preset3d = v
        NugComboBar:Set3DPreset(v)
    end,
    ["preset3dlayer2"] = function(v)
        if not NugComboBar.presets[v] then
            return print(string.format("Preset '%s' does not exist", v))
        end
        NugComboBarDB.preset3dlayer2 = v
    end,
    ["preset3dpointbar2"] = function(v)
        if not NugComboBar.presets[v] then
            return print(string.format("Preset '%s' does not exist", v))
        end
        NugComboBarDB.preset3dpointbar2 = v
        NugComboBar:Set3DPreset()
    end,
    ["colors3d"] = function(v)
        NugComboBarDB.colors3d = not NugComboBarDB.colors3d
        for i=1,#NugComboBar.point do
            NugComboBar.SetColor(i)
        end
    end,
    ["gui"] = function(v)
        LoadAddOn('NugComboBarGUI')
        InterfaceOptionsFrame_OpenToCategory("NugComboBar")
        InterfaceOptionsFrame_OpenToCategory("NugComboBar")
    end,
    ["vertical"] = function(v)
        NugComboBarDB.vertical = not NugComboBarDB.vertical 
        NugComboBar:Create()
        NugComboBar:PLAYER_LOGIN(nil)
        NugComboBar:PLAYER_ENTERING_WORLD(nil)
    end,
    ["playsound"] = function(v)
        if not NugComboBar.soundFiles[v] then
            return print(string.format("Sound '%s' does not exist", v))
        end
        NugComboBarDB.soundNameFull = v
    end,
    ["setpos"] = function(v)
        local p = ParseOpts(v)
        NugComboBarDB.apoint = p["point"] or NugComboBarDB.apoint
        NugComboBarDB.parent = p["parent"] or NugComboBarDB.parent
        NugComboBarDB.point = p["to"] or NugComboBarDB.point
        NugComboBarDB.x = p["x"] or NugComboBarDB.x
        NugComboBarDB.y = p["y"] or NugComboBarDB.y
        local pos = NugComboBarDB
        NugComboBar.anchor:SetPoint(pos.apoint, pos.parent, pos.point, pos.x, pos.y)
    end,
}

function NugComboBar.SlashCmd(msg)
    k,v = string.match(msg, "([%w%+%-%=]+) ?(.*)")
    if not k or k == "help" then
        print([[Usage:
          |cff55ffff/ncb gui|r
          |cff55ff55/ncb charspec|r
          |cff55ff55/ncb lock|r
          |cff55ff55/ncb unlock|r
          |cff55ff55/ncb toggle3d|r
          |cff55ff55/ncb preset3d <preset>|r
          |cff55ff55/ncb scale|r <0.3 - 2.0>
          |cff55ff55/ncb changecolor|r <1-6, 0 = all, -1 = 2nd bar>
          |cff55ff55/ncb anchorpoint|r <left | right>
          |cff55ff55/ncb showempty|r
          |cff55ff55/ncb hideslowly|r
          |cff55ff55/ncb toggleblizz|r
          |cff55ff55/ncb disable|enable|r (for current class)
          |cff55ff55/ncb setpos|r point=CENTER parent=UIParent to=CENTER x=0 y=0
          |cff55ff55/ncb reset|r]]
        )
    end
    if NugComboBar.Commands[k] then
        NugComboBar.Commands[k](v)
    end

--~     if k == "rotation" then
--~         local ag = name:CreateAnimationGroup()
--~     local a1 = ag:CreateAnimation("Rotation")
--~     a1:SetDegrees(90)
--~     a1:SetDuration(0.1)
--~     a1:SetOrder(1)
--~     a1.ag = ag
--~     a1:SetScript("OnFinished",function(self)
--~         self.ag:Pause();
--~     end)
--~     end
    
end


function NugComboBar.disableBlizz()
    local class = select(2,UnitClass("player"))
        if class == "ROGUE" or class == "DRUID" then
            ComboFrame:UnregisterAllEvents()
            ComboFrame:Hide()
        end
        if class == "WARLOCK" then
            WarlockPowerFrame:UnregisterAllEvents()
            WarlockPowerFrame:Hide()
            WarlockPowerFrame._Show = WarlockPowerFrame.Show
            WarlockPowerFrame.Show = WarlockPowerFrame.Hide
        end
        if class == "PALADIN" then
            PaladinPowerBar:UnregisterAllEvents()
            PaladinPowerBar:Hide()
            PaladinPowerBar._Show = PaladinPowerBar.Show
            PaladinPowerBar.Show = PaladinPowerBar.Hide
        end
        if class == "PRIEST" then
            PriestBarFrame:UnregisterAllEvents()
            PriestBarFrame:Hide()
            PriestBarFrame._Show = PriestBarFrame.Show
            PriestBarFrame.Show = PriestBarFrame.Hide
        end
        if class == "MONK" then
            MonkHarmonyBar:UnregisterAllEvents()
            MonkHarmonyBar:Hide()
            MonkHarmonyBar._Show = MonkHarmonyBar.Show
            MonkHarmonyBar.Show = MonkHarmonyBar.Hide
        end
    -- else
    --     if class == "ROGUE" or class == "DRUID" then
    --         ComboFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    --         ComboFrame:RegisterEvent("UNIT_COMBO_POINTS")
    --         if not PlayerFrame.unit then PlayerFrame.unit = "player" end
    --         -- if not PlayerFrame:IsVisible() then return end
    --         ComboFrame_Update()
    --     end
    --     if class == "WARLOCK" then
    --         WarlockPowerFrame.Show = WarlockPowerFrame._Show
    --         WarlockPowerFrame:Show()
    --         if not PlayerFrame.unit then PlayerFrame.unit = "player" end
    --         -- if not PlayerFrame:IsVisible() then return end
    --         WarlockPowerFrame_OnLoad(WarlockPowerFrame)
    --         -- WarlockPowerFrame_Update()
    --     end
    --     if class == "PALADIN" then
    --         PaladinPowerBar.Show = PaladinPowerBar._Show
    --         PaladinPowerBar:Show()
    --         if not PlayerFrame.unit then PlayerFrame.unit = "player" end
    --         -- if not PlayerFrame:IsVisible() then return end
    --         PaladinPowerBar_OnLoad(PaladinPowerBar)
    --         PaladinPowerBar_Update(PaladinPowerBar)
    --     end
    --     if class == "PRIEST" then
    --         PriestBarFrame.Show = PriestBarFrame._Show
    --         PriestBarFrame:Show()
    --         if not PlayerFrame.unit then PlayerFrame.unit = "player" end
    --         -- if not PlayerFrame:IsVisible() then return end
    --         PriestBarFrame.spec = nil
    --         PriestBarFrame_OnLoad(PriestBarFrame)
    --     end
    --     if class == "MONK" then
    --         MonkHarmonyBar.Show = MonkHarmonyBar._Show
    --         MonkHarmonyBar:Show()
    --         if not PlayerFrame.unit then PlayerFrame.unit = "player" end
    --         -- if not PlayerFrame:IsVisible() then return end
    --         MonkHarmonyBar_OnLoad(MonkHarmonyBar)
    --     end
    -- end
end

function NugComboBar:OnSpecChanged()
    local spec = GetSpecialization()
    if currentSpec ~= spec then
        currentSpec = spec
        NugComboBar:Reinitialize()
    end
end

function NugComboBar:SuperDisable()
    self:UnregisterAllEvents()
    self:DisableBar()
    if self.anchor then self.anchor:Hide() end
    self:SetAlpha(0)
end





local ItemSetsRegistered = {}

local tierSlots = {
    (GetInventorySlotInfo("ChestSlot")),
    (GetInventorySlotInfo("HeadSlot")),
    (GetInventorySlotInfo("ShoulderSlot")),
    (GetInventorySlotInfo("LegsSlot")),
    (GetInventorySlotInfo("HandsSlot")),
}

local setwatcher = CreateFrame("Frame", nil, UIParent)
setwatcher:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

-- setwatcher:RegisterEvent("PLAYER_LOGIN")

-- function setwatcher:PLAYER_LOGIN()
    -- if next(ItemSetsRegistered) then
        -- self:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
        -- self:UNIT_INVENTORY_CHANGED(nil, "player")
    -- end
-- end


function setwatcher:UNIT_INVENTORY_CHANGED(event, unit)
    for tiername, tier in pairs(ItemSetsRegistered) do
        local tier_items = tier.items
        local pieces_equipped = 0
        for _, slot in ipairs(tierSlots) do
            local itemID = GetInventoryItemID("player", slot)
            if tier_items[itemID] then pieces_equipped = pieces_equipped + 1 end
        end

        for bp, bonus in pairs(tier.callbacks) do
            if pieces_equipped >= bp then
                if not bonus.equipped then
                    if bonus.on then bonus.on() end
                    bonus.equipped = true
                end
            else
                if bonus.equipped then
                    if bonus.off then bonus.off() end
                    bonus.equipped = false
                end
            end
        end
    end
end

function NugComboBar.TrackItemSet(tiername, itemArray)
    ItemSetsRegistered[tiername] = ItemSetsRegistered[tiername] or {}
    if not ItemSetsRegistered[tiername].items then
        ItemSetsRegistered[tiername].items = {}
        ItemSetsRegistered[tiername].callbacks = {}
        local bitems = ItemSetsRegistered[tiername].items
        for _, itemID in ipairs(itemArray) do
            bitems[itemID] = true
        end
    end

    setwatcher:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
end

function NugComboBar.RegisterSetBonusCallback(tiername, pieces, handle_on, handle_off)
    local tier = ItemSetsRegistered[tiername]
    if not tier then error(string.format("Itemset '%s' is not registered", tiername)) end
    tier.callbacks[pieces] = {}
    tier.callbacks[pieces].equipped = false
    tier.callbacks[pieces].on = handle_on
    tier.callbacks[pieces].off = handle_off
end


function NugComboBar.IsSetBonusActive(tiername, bonuscount)
        local tier = ItemSetsRegistered[tiername]
        local tier_items = tier.items
        local pieces_equipped = 0
        for _, slot in ipairs(tierSlots) do
            local itemID = GetInventoryItemID("player", slot)
            if tier_items[itemID] then pieces_equipped = pieces_equipped + 1 end
        end
        return (pieces_equipped >= bonuscount)
end

-- function NugComboBar:EnableItemSetTracking()
--     if next(ItemSetsRegistered) then
--         self:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
--         self:UNIT_INVENTORY_CHANGED(nil, "player")
--     end
-- end