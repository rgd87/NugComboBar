NugComboBar = CreateFrame("Frame",nil, UIParent)
local NugComboBar = NugComboBar

local user
local RogueGetComboPoints = GetComboPoints
local GetComboPoints = RogueGetComboPoints
local allowedUnit = "player"
local allowedCaster = "player"
local showEmpty, showAlways
local hideSlowly
local fadeAfter = 6
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

function NugComboBar:LoadClassSettings()
        local class = select(2,UnitClass("player"))
        self.MAX_POINTS = nil
        if self.bar then self.bar:SetColor(unpack(NugComboBarDB.colors.bar1)) end
        if class == "ROGUE" then
            local anticipationBuffName = GetSpellInfo(115189)
            local ComboPointsWithAnticipation = function(unit)
                local name, _,_, count = UnitBuff("player", anticipationBuffName, nil)
                return RogueGetComboPoints(unit), count
            end
            self:SetMaxPoints(5)
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            self:RegisterEvent("UNIT_COMBO_POINTS")
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self:RegisterEvent("SPELLS_CHANGED")
            self.SPELLS_CHANGED = function(self, event)
                if IsPlayerSpell(114015) then -- Anticipation
                    self:EnableBar(0, 5, "Long")
                    self:RegisterUnitEvent("UNIT_AURA", "player")
                    GetComboPoints = ComboPointsWithAnticipation
                else
                    self:DisableBar()
                    self:UnregisterEvent("UNIT_AURA")
                    GetComboPoints = RogueGetComboPoints
                end
            end
            self:SPELLS_CHANGED()
        elseif class == "DRUID" then
            self:RegisterEvent("PLAYER_TARGET_CHANGED") -- required for both
            self:SetMaxPoints(5)
            local dummy = function() return 0 end

            local mushrooms_icon = "INTERFACE\\ICONS\\druid_ability_wildmushroom_a"
            local GetMushrooms = function()
                local mushrooms = 0
                for i=1,4 do
                    local haveTotem, name, startTime, duration, icon = GetTotemInfo(i)
                    if icon == mushrooms_icon then mushrooms = mushrooms + 1 end
                end
                return mushrooms
            end
            local shrooms = function()
                self:SetMaxPoints(3)
                hideSlowly = false
                showEmpty = NugComboBarDB.showEmpty
                self:RegisterEvent("PLAYER_TOTEM_UPDATE")
                GetComboPoints = GetMushrooms
                self.PLAYER_TOTEM_UPDATE = function(self, event, totemID)
                    self:UNIT_COMBO_POINTS(nil, allowedUnit)
                end
                self:PLAYER_TOTEM_UPDATE()
            end

            local cat = function()
                self:SetMaxPoints(5)
                hideSlowly = NugComboBarDB.hideSlowly
                showEmpty = NugComboBarDB.showEmpty
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
                local old = hideSlowly
                showEmpty = false
                hideSlowly = false
                self:UNIT_COMBO_POINTS(nil,allowedUnit)
                hideSlowly = old
            end
            self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
            self.UPDATE_SHAPESHIFT_FORM = function(self)
                self:UnregisterEvent("UNIT_AURA")
                self:UnregisterEvent("UNIT_COMBO_POINTS")
                self:UnregisterEvent("PLAYER_TOTEM_UPDATE")
                local spec = GetSpecialization()
                local form = GetShapeshiftFormID()
                if form == BEAR_FORM then bear()
                elseif form == CAT_FORM then cat()
                elseif spec == 1 or spec == 4 then
                    shrooms()
                else
                    disable()
                end
            end
            self:UPDATE_SHAPESHIFT_FORM()
        elseif class == "PALADIN" then
            local GetHolyPower = function(unit)
                return UnitPower(unit, SPELL_POWER_HOLY_POWER)
            end
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
            local GetChi = function(unit)
                return UnitPower(unit, SPELL_POWER_CHI)
            end
            self:SetMaxPoints(4)
            self:RegisterEvent("UNIT_POWER")
            self.UNIT_POWER = function(self,event,unit,ptype)
                if ptype ~= "CHI" or unit ~= "player" then return end
                self.UNIT_COMBO_POINTS(self,event,unit,ptype)
            end
            GetComboPoints = GetChi

            self:RegisterEvent("SPELLS_CHANGED")
            self.SPELLS_CHANGED = function(self, event)
                if IsSpellKnown(115396)  -- Ascension
                    then self:SetMaxPoints(5)
                    else self:SetMaxPoints(4)
                end
                self:UNIT_COMBO_POINTS(nil,"player")
            end
            self:SPELLS_CHANGED()
        elseif class == "SHAMAN" then
            self:SetMaxPoints(5)
            self:RegisterEvent("UNIT_AURA")
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            allowedUnit = "player"
            local LShield = GetSpellInfo(324) -- Lightning Shield
            local GetLightningShield = function(unit)
                local _,_,_, count, _,_,_, caster = UnitAura("player", LShield, nil, "HELPFUL")
                return (count and count - 1 or 0)
            end
            self:RegisterEvent("SPELLS_CHANGED")
            self.SPELLS_CHANGED = function(self)
                local spec = GetSpecialization()
                if spec == 1 then
                    self:SetMaxPoints(6)
                    GetComboPoints = GetLightningShield
                else
                    self:SetMaxPoints(5)
                    scanAura = GetSpellInfo(53817) -- Maelstrom Weapon
                    GetComboPoints = GetAuraStack
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
            self:RegisterEvent("GLYPH_UPDATED")
            self:RegisterEvent("GLYPH_ADDED")
            self:RegisterEvent("GLYPH_REMOVED")
            self:RegisterEvent("SPELLS_CHANGED")
            self:RegisterEvent("UNIT_POWER")
            self:SetMaxPoints(3); GetComboPoints = GetShards
            self.SPELLS_CHANGED = function(self, event)
                showEmpty = true
                self:UnregisterEvent("UNIT_AURA")
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
        elseif class == "WARRIOR" then
            local tfb_bar = function(self)
                self:EnableBar(0, 15, "Long")
                if self.bar then self.bar:SetScript("OnUpdate", AuraTimerOnUpdate) end
            end
            self:SetMaxPoints(5)
            -- self:RegisterEvent("UNIT_AURA")
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            allowedUnit = "player"
            GetComboPoints = GetAuraStack
            hideSlowly = false
            self:RegisterEvent("SPELLS_CHANGED")
            self.SPELLS_CHANGED = function(self)
                local spec = GetSpecialization()
                self:RegisterEvent("UNIT_AURA")
                if spec == 2 then 
                    self:EnableBar(0, 10, "Small")
                    if self.bar then self.bar:SetScript("OnUpdate", AuraTimerOnUpdate) end
                    self:SetMaxPoints(3)
                    scanAura = GetSpellInfo(85739) -- Meatcleaver
                elseif spec == 1 then
                    self:EnableBar(0, 15, "Long")
                    if self.bar then self.bar:SetScript("OnUpdate", AuraTimerOnUpdate) end
                    self:SetMaxPoints(5)
                    scanAura = GetSpellInfo(125831) -- Taste for blood
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
            local mm = function()
                self:SetMaxPoints(3)
                self:RegisterEvent("UNIT_AURA")
                scanAura = GetSpellInfo(82925) -- Ready, Set, Aim...
                allowedUnit = "player"
                allowedCaster = "player"
                GetComboPoints = function (unit)
                    if not scanAura then return 0 end
                    if UnitAura(allowedUnit, GetSpellInfo(82926), nil, filter) then return 3 end -- Fire! proc buff
                    local name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitAura(allowedUnit, scanAura, nil, filter)
                    if allowedCaster and caster ~= allowedCaster then count = 0 end
                    return (count or 0)
                end
            end
            local bm = function()
                self:SetMaxPoints(5)
                self:RegisterEvent("UNIT_AURA")
                scanAura = GetSpellInfo(19615) -- Frenzy Effect
                allowedUnit = "pet"
                allowedCaster = "pet"
                GetComboPoints = GetAuraStack
            end
            self:RegisterEvent("SPELLS_CHANGED")
            self.SPELLS_CHANGED = function(self)
                local spec = GetSpecialization()
                if spec == 2 then return mm() end
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
            GetComboPoints = GetAuraStack
            
            self:RegisterEvent("SPELLS_CHANGED")
            self.SPELLS_CHANGED = function(self, event)
                local spec = GetSpecialization()
                if      spec == 3 then -- unholy
                    allowedUnit = "pet"
                    scanAura = GetSpellInfo(91342) -- Shadow Infusion
                elseif  spec == 1 then
                    allowedUnit = "player"
                    scanAura = GetSpellInfo(50421) -- Scent of Blood
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
                self:RegisterEvent("UNIT_POWER")
                self:UnregisterEvent("UNIT_AURA")
                self:SetMaxPoints(3)
                GetComboPoints = GetShadowOrbs
            end
            local evangelism = function()
                self:SetMaxPoints(5)
                self:RegisterEvent("UNIT_AURA")
                self:UnregisterEvent("UNIT_POWER")
                GetComboPoints = GetAuraStack
                scanAura = GetSpellInfo(81661) -- Evangelism
            end
            self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
            self.ACTIVE_TALENT_GROUP_CHANGED = function(self)
                if GetSpecialization() == 3 -- MF
                then shadow_orbs()
                else evangelism()
                end
            end
            self:ACTIVE_TALENT_GROUP_CHANGED()
        elseif class == "MAGE" then 
            self:SetMaxPoints(6, "ARCANE")
            self:RegisterEvent("UNIT_AURA")
            self.UNIT_AURA = self.UNIT_COMBO_POINTS 
            scanAura = GetSpellInfo(36032) -- Arcane Blast Buff 
            filter = "HARMFUL" 
            allowedUnit = "player" 
            GetComboPoints = GetAuraStack
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
        ["bar1"] = { 0.9,0.1,0.1 },
        ["bar2"] = { .9,0.1,0.4 },
    },
    enable3d = true,
    preset3d = "glowPurple",
    showAlways = false,
}

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

            if NugComboBarDB_Character.charspec then
                local spec = GetSpecialization()
                if spec and NugComboBarDB_Character.specspec[spec] then
                    NugComboBarDB_Character.specdb = NugComboBarDB_Character.specdb or {}
                    NugComboBarDB_Character.specdb[spec] = NugComboBarDB_Character.specdb[spec] or {}

                    NugComboBarDB = NugComboBarDB_Character.specdb[spec]
                else
                    NugComboBarDB = NugComboBarDB_Character
                end
            else
                NugComboBarDB = NugComboBarDB_Global
            end

            if not NugComboBarDB.apoint and NugComboBarDB.point then NugComboBarDB.apoint = NugComboBarDB.point end
            SetupDefaults(NugComboBarDB, defaults)

            NugComboBar.isDisabled = nil
            if type(NugComboBarDB.disabled) == "table" then NugComboBarDB.disabled = nil end --old format bugfix
            NugComboBarDB_Global.disabled = nil
            if NugComboBarDB.disabled then
                NugComboBar.isDisabled = true
                NugComboBar:SuperDisable()
            end

            -- self:RegisterEvent("PLAYER_LOGIN")
            self:RegisterEvent("PLAYER_LOGOUT")

            NugComboBar.toggleBlizz() --even if disabled

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

do
    local initial = true
    function NugComboBar.PLAYER_LOGIN(self, event)
        if initial then self:Create() end
        self:LoadClassSettings()
        if showEmpty == nil then showEmpty = NugComboBarDB.showEmpty end;
        if showAlways == nil then showAlways = NugComboBarDB.showAlways end;
        if hideSlowly == nil then hideSlowly = NugComboBarDB.hideSlowly end;
        self:SetAlpha(0)
        self:SetScale(NugComboBarDB.scale)
        self.Commands.anchorpoint(NugComboBarDB.anchorpoint)
        if initial then
            self:CreateAnchor()
        else
            self.anchor:ClearAllPoints()
            self.anchor:SetPoint(NugComboBarDB.apoint, NugComboBarDB.parent, NugComboBarDB.point,NugComboBarDB.x,NugComboBarDB.y)
        end

        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self.PLAYER_ENTERING_WORLD = self.PLAYER_REGEN_ENABLED -- Update on looading screen to clear after battlegrounds

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
    local a = fadeAfter + fadeTime - self.OnUpdateCounter
    ncb:SetAlpha(a)
    if self.OnUpdateCounter >= fadeAfter + fadeTime then
        self:SetScript("OnUpdate",nil)
        ncb:SetAlpha(0)
        ncb.hiding = false
        self.OnUpdateCounter = 0
    end
end


function NugComboBar.PLAYER_TARGET_CHANGED(self, event)
    self:UNIT_COMBO_POINTS(event, allowedUnit)
end
function NugComboBar.PLAYER_REGEN_ENABLED(self)
    self:UNIT_COMBO_POINTS(event, allowedUnit, nil, true)
end
function NugComboBar.PLAYER_REGEN_DISABLED(self)
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
    if btype and self.bar[btype] then self.bar[btype](self.bar) end
    self.bar:Show()
end

function NugComboBar.DisableBar(self)
    if not self.bar then return end
    self.bar.enabled = false
    self.bar:Small()
    self.bar:Hide()
end


local comboPointsBefore = 0
function NugComboBar.UNIT_COMBO_POINTS(self, event, unit, ptype, forced)
    if unit ~= allowedUnit then return end
    -- local arg1, arg2
    local comboPoints, arg1, arg2 = GetComboPoints(unit);
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


    for i = 1, self.MAX_POINTS do
        if i <= comboPoints then
            self.p[i]:Activate()
        end
        if i > comboPoints then
            self.p[i]:Deactivate()
        end
    end
    -- print("progress", progress)
    -- print (comboPoints == defaultValue, (progress == nil or progress == defaultProgress), not UnitAffectingCombat("player"), not showEmpty)
    if  not showAlways and
        comboPoints == defaultValue and
        (progress == nil or progress == defaultProgress) and
        (not UnitAffectingCombat("player") or not showEmpty)
        then
            local hidden = self:GetAlpha() == 0
            if hideSlowly then
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
        self:SetAlpha(1)
    end

    comboPointsBefore = comboPoints

    -- if event ~= -1 then
    --     tframe.started = true
    --     tframe.unit = unit
    --     tframe.ptype = ptype
    --     tframe:SetScript("OnUpdate", tfunc)
    -- end
end

function NugComboBar.SetColor(point, r, g, b)
    NugComboBarDB.colors[point] = {r,g,b}
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
    self:SetScript("OnDragStart",function(self) self:StartMoving() end)
    self:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing();
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
            for i=1,#self.points do
                NugComboBar.SetColor(i,r,g,b)
            end
        else
            NugComboBar.SetColor(color,r,g,b)
        end
    end
    ColorPickerFrame.cancelFunc = ColorPickerFrame.func
    ColorPickerFrame:Show()
end

function NugComboBar.Set3DPreset(self, preset)
    for _, point in pairs(self.point) do
        point:SetPreset(preset)
    end
end

function NugComboBar.Reinitialize(self)
    NugComboBar:ADDON_LOADED(nil, "NugComboBar")
    local cfgreg = LibStub("AceConfigRegistry-3.0", true)
    if cfgreg then cfgreg:NotifyChange("NugComboBar-General") end
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
        NugComboBar:SetAlpha(1)
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
        NugComboBar:UNIT_COMBO_POINTS("SETTINGS_CHANGED","player")
    end,
    ["showalways"] = function(v)
        NugComboBarDB.showAlways = not NugComboBarDB.showAlways
        showAlways = NugComboBarDB.showAlways
        NugComboBar:UNIT_COMBO_POINTS("SETTINGS_CHANGED","player")
    end,
    ["hideslowly"] = function(v)
        NugComboBarDB.hideSlowly = not NugComboBarDB.hideSlowly
        hideSlowly = NugComboBarDB.hideSlowly
    end,
    ["toggleblizz"] = function(v)
        NugComboBarDB.disableBlizz = not NugComboBarDB.disableBlizz
        NugComboBar.toggleBlizz()
    end,
    ["scale"] = function(v)
        local num = tonumber(v)
        if num then 
            NugComboBarDB.scale = num; NugComboBar:SetScale(NugComboBarDB.scale);
        else print ("Current scale is: ".. NugComboBarDB.scale)
        end
    end,
    ["disable"] = function(v)
        if not NugComboBarDB_Character.charspec then return end
        if NugComboBarDB.disabled then
            NugComboBarDB.disabled = nil
        else
            NugComboBarDB.disabled = true
        end
        NugComboBar:Reinitialize()
        -- print ("NCB> Disabled for current class. Changes will take effect after /reload")
    end,
    ["enable"] = function(v)
        NugComboBarDB_Global.disabled[select(2,UnitClass("player"))] = nil
        print ("NCB> Enabled for current class. Changes will take effect after /reload")
    end,
    ["changecolor"] = function(v)
        local num = tonumber(v)
        if num then 
            NugComboBar:ShowColorPicker(num)
        end
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
        if NugComboBarDB_Character.specspec[spec] then
            NugComboBarDB_Character.specspec[spec] = nil
        else
            NugComboBarDB_Character.specspec[spec] = true
        end

        NugComboBar:Reinitialize()
    end,
    ["toggle3d"] = function(v)
        NugComboBarDB.enable3d = not NugComboBarDB.enable3d
        print (string.format("NCB> 3D mode is %s, it will take effect after /reload", NugComboBarDB.enable3d and "enabled" or "disabled"))
    end,
    ["preset3d"] = function(v)
        if not NugComboBar.presets[v] then
            return print(string.format("Preset '%s' does not exist", v))
        end
        NugComboBarDB.preset3d = v
        NugComboBar:Set3DPreset(v)
    end,
    ["gui"] = function(v)
        LoadAddOn('NugComboBarGUI')
        InterfaceOptionsFrame_OpenToCategory("NugComboBar")
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
          |cff55ff55/ncb changecolor|r <1-6, 0 = all>
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


function NugComboBar.toggleBlizz()
    local class = select(2,UnitClass("player"))
    if NugComboBarDB.disableBlizz then
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
    else
        if class == "ROGUE" or class == "DRUID" then
            ComboFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
            ComboFrame:RegisterEvent("UNIT_COMBO_POINTS")
            ComboFrame_Update()
        end
        if class == "WARLOCK" then
            WarlockPowerFrame.Show = WarlockPowerFrame._Show
            WarlockPowerFrame:Show()
            WarlockPowerFrame_OnLoad(WarlockPowerFrame)
            -- WarlockPowerFrame_Update()
        end
        if class == "PALADIN" then
            PaladinPowerBar.Show = PaladinPowerBar._Show
            PaladinPowerBar:Show()
            PaladinPowerBar_OnLoad(PaladinPowerBar)
            PaladinPowerBar_Update(PaladinPowerBar)
        end
        if class == "PRIEST" then
            PriestBarFrame.Show = PriestBarFrame._Show
            PriestBarFrame:Show()
            PriestBarFrame.spec = nil
            PriestBarFrame_OnLoad(PriestBarFrame)
        end
        if class == "MONK" then
            MonkHarmonyBar.Show = MonkHarmonyBar._Show
            MonkHarmonyBar:Show()
            MonkHarmonyBar_OnLoad(MonkHarmonyBar)
        end
    end
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
    self:Hide()
end