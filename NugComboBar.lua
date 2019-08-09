local addonName, ns = ...

local NugComboBar = CreateFrame("Frame", "NugComboBar", UIParent)

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
local playerClass
local EPT = Enum.PowerType
local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local Enum_PowerType_ComboPoints = EPT.ComboPoints
local Enum_PowerType_Chi = EPT.Chi
local Enum_PowerType_HolyPower = EPT.HolyPower
local Enum_PowerType_SoulShards = EPT.SoulShards
local Enum_PowerType_ArcaneCharges = EPT.ArcaneCharges
local chargeCooldown
local chargeCooldownOnSecondBar
local isDefaultSkin = nil

local UnitAura = UnitAura
local GetSpellCharges = GetSpellCharges
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local tsort = table.sort

--- Compatibility with Classic
local isClassic = select(4,GetBuildInfo()) <= 19999
local IsInPetBattle = isClassic and function() end or C_PetBattles.IsInBattle
local GetSpecialization = isClassic and function() return nil end or _G.GetSpecialization


NugComboBar:SetScript("OnEvent", function(self, event, ...)
	return self[event](self, event, ...)
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

local AuraTimerOnUpdate = function(self, time)
    self._elapsed = (self._elapsed or 0) + time
    if self._elapsed < 0.03 then return end
    self._elapsed = 0

    if not self.startTime then return end
    local progress
    if self.isReversed then
        progress = self.duration - (GetTime() - self.startTime)
    else
        progress = self.duration - ( (self.startTime+self.duration) - GetTime())
    end
    self:SetValue(progress)
end
local dummy = function() return 0 end

if isClassic then
    local OriginalGetComboPoints = _G.GetComboPoints
    RogueGetComboPoints = function(unit)
        return OriginalGetComboPoints(unit, "target")
    end
else
    RogueGetComboPoints = function(unit)
        return UnitPower("player", 4)
    end
end

local makeDruidCP = function(anticipation, subtlety, maxFill, maxCP)
	local secondRowCount = 0

	return function(unit)
		local cp = RogueGetComboPoints(unit)
		if maxFill and cp == maxCP then
			return cp, nil, nil, cp, secondRowCount
		end
		return cp, nil, nil, 0, secondRowCount
	end
end



-- local min = math.min
-- local max = math.max
function NugComboBar:LoadClassSettings()
        local class = select(2,UnitClass("player"))
        self.MAX_POINTS = nil
        self.isTempDisabled = nil
        soundFullEnabled = false
        if self.bar then self.bar:SetColor(unpack(NugComboBarDB.colors.bar1)) end
        if class == "ROGUE" then
            soundFullEnabled = true

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

            if isClassic then
                self:RegisterEvent("PLAYER_TARGET_CHANGED")
            end


            self.SPELL_UPDATE_COOLDOWN = function(self, event)
                self:UNIT_COMBO_POINTS(nil, "player")
            end
            self.SPELL_UPDATE_CHARGES = self.SPELL_UPDATE_COOLDOWN

            GetComboPoints = RogueGetComboPoints

            self:SetMaxPoints(5)
            self:RegisterEvent("UNIT_POWER_FREQUENT")
            self.UNIT_POWER_FREQUENT = function(self,event,unit,ptype)
                if unit ~= "player" then return end
                if ptype == "COMBO_POINTS" then
                    return self.UNIT_COMBO_POINTS(self,event,unit,ptype)
                end
            end
            self:RegisterEvent("SPELLS_CHANGED")
            self.SPELLS_CHANGED = function(self, event)
                local isSub = (GetSpecialization() == 3) and IsPlayerSpell(185313)
                local isAnticipation = IsPlayerSpell(114015)
                local maxCP = IsPlayerSpell(193531) and 6 or 5 -- Deeper Stratagem
				local maxFill = NugComboBarDB.maxFill
                GetComboPoints = makeRCP(isAnticipation, isSub, maxFill, maxCP)--  RogueGetComboPoints
                if isSub and NugComboBarDB.shadowDance then
                    local maxShadowDance = IsPlayerSpell(238104) and 3 or 2
                    local barSetup = "ROGUE"..maxCP..maxShadowDance
                    self:SetMaxPoints(maxCP, barSetup, maxShadowDance)
                    self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
                    self:RegisterEvent("SPELL_UPDATE_CHARGES")
					self:EnableBar(0, 6, 90, "Timer")
                    chargeCooldown = NugComboBarDB.chargeCooldown
                    chargeCooldownOnSecondBar = true
                else
					self:DisableBar()
                    self:SetMaxPoints(maxCP)
                    self:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
                    self:UnregisterEvent("SPELL_UPDATE_CHARGES")
                end
            end
            self:SPELLS_CHANGED()
        elseif class == "DRUID" then
            self:RegisterEvent("PLAYER_TARGET_CHANGED") -- required for both
            self:SetMaxPoints(5)

            local enablePulverize = false

            local reset = function()
                defaultValue = 0
                soundFullEnabled = false
                hideSlowly = NugComboBarDB.hideSlowly
                showEmpty = NugComboBarDB.showEmpty
            end

            self.UNIT_POWER_FREQUENT = function(self,event,unit,ptype)
                if unit ~= "player" then return end
                if ptype == "COMBO_POINTS" then
                    return self.UNIT_COMBO_POINTS(self,event,unit,ptype)
                end
            end
            self.UNIT_AURA = self.UNIT_COMBO_POINTS

            local solar_aura = 164545
            local lunar_aura = 164547
            local GetEmpowerments = function(unit)
                local _,_, solar = FindAura("player", solar_aura, "HELPFUL")
                local _,_, lunar = FindAura("player", lunar_aura, "HELPFUL")
                lunar = lunar or 0
                solar = solar or 0
                return lunar, nil, nil, 0, solar
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

            local empowerments = function()
                self:SetMaxPoints(3, "MOONKIN", 3)
                GetComboPoints = GetEmpowerments
                self:RegisterEvent("UNIT_AURA")
                -- self:RegisterEvent("SPELL_UPDATE_CHARGES")
                -- local charges, maxCharges, start, duration = GetSpellCharges(78674)
                -- self:SetMaxPoints(maxCharges)
                -- defaultValue = 3
                -- -- self:EnableBar(0, duration, "Small")
                -- -- if self.bar then self.bar:SetScript("OnUpdate", AuraTimerOnUpdate) end
                -- GetComboPoints = function()
                --     local charges, maxCharges, start, duration = GetSpellCharges(78674)
                --     return charges, start, duration
                -- end
                -- self.SPELL_UPDATE_CHARGES = function(self, event, arg1)
                --     self:UNIT_COMBO_POINTS(nil, allowedUnit)
                -- end
                -- self:SPELL_UPDATE_CHARGES()
            end

            local cat = function()
                self:SetMaxPoints(5)
                soundFullEnabled = true
                allowedTargetUnit = "player"
                self:RegisterEvent("UNIT_POWER_FREQUENT")
				local maxFill = NugComboBarDB.maxFill
                GetComboPoints = makeDruidCP(nil, nil, maxFill, 5)
                allowedUnit = "player"
                self:UNIT_COMBO_POINTS(nil,allowedUnit)
            end

            local disable = function()
                -- self:SetMaxPoints(3)
                -- self:RegisterEvent("UNIT_AURA")
                self.UNIT_AURA = self.UNIT_COMBO_POINTS
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
                -- self:RegisterEvent("PLAYER_TARGET_CHANGED")
                self.UNIT_AURA = self.UNIT_COMBO_POINTS
                soundFullEnabled = true
                GetComboPoints = GetAuraStack(192090, "HARMFUL", "target") -- Lacerate`
                self:UNIT_COMBO_POINTS(nil,allowedUnit)
            end

            self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
            self.UPDATE_SHAPESHIFT_FORM = function(self)
                self:UnregisterEvent("UNIT_AURA")
                self:UnregisterEvent("UNIT_POWER_FREQUENT")
                -- self:UnregisterEvent("PLAYER_TARGET_CHANGED") -- it should be always on to hideWithoutTarget to work
                self:UnregisterEvent("PLAYER_TOTEM_UPDATE")
                local spec = GetSpecialization()
                local form = GetShapeshiftFormID()
                reset()
                if form == BEAR_FORM then
                    if spec == 3 and enablePulverize and IsPlayerSpell(80313) --pulverize
                        then pulverize()
                        else disable()
                    end
                elseif form == CAT_FORM then
                    cat()
                -- elseif spec == 1 then
                    -- empowerments()
                else
                    disable()
                end
            end
            self:UPDATE_SHAPESHIFT_FORM()
        else
            self:SetMaxPoints(2)
            self:Disable()
            return
        end
end

local defaults = {
    apoint = "CENTER",
    parent = "UIParent",
    point = "CENTER", --to
    x = 0, y = 0,
    anchorpoint = "LEFT",
    frameparent = nil, -- for SetParent
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
        ["bar2"] = { 0.9,0.1,0.4 },
        ["layer2"] = { 0.74, 0.06, 0 },
		["row2"] = { 0.80, 0.23, 0.79 },
    },
    glowIntensity = 0.7,
    enable3d = true,
    preset3d = "glowPurple",
    preset3dlayer2 = "glowArcshot",
    preset3dpointbar2 = "void",
	bar2_x = 13,
	bar2_y = -20,
	enableFullRuneTracker = true,
    classThemes = false,
    secondLayer = true,
    colors3d = true,
    showAlways = false,
    onlyCombat = false,
    disableProgress = false,
    chargeCooldown = true,
    adjustX = 2.05,
    adjustY = 2.1,
    alpha = 1,
    nameplateAttach = false,
    nameplateAttachTarget = false,
    nameplateOffsetX = 0,
    nameplateOffsetY = 0,
    special1 = false,
    maxFill = false,
    hideWithoutTarget = false,
    vertical = false,
    overrideLayout = false,
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
                NugComboBarDBSource = NugComboBarDB_Character
            else
                NugComboBarDBSource = NugComboBarDB_Global
            end

            if not NugComboBarDBSource.apoint and NugComboBarDBSource.point then NugComboBarDBSource.apoint = NugComboBarDBSource.point end
            SetupDefaults(NugComboBarDBSource, defaults)
            if not NugComboBarDB_Global.adjustX then NugComboBarDB_Global.adjustX = defaults.adjustX end
            if not NugComboBarDB_Global.adjustY then NugComboBarDB_Global.adjustY = defaults.adjustY end

            NugComboBarDB = NugComboBarDBSource
            NugComboBar.db = NugComboBarDB

            NugComboBar.isDisabled = nil
            if type(NugComboBarDBSource.disabled) == "table" then NugComboBarDBSource.disabled = nil end --old format bugfix
            NugComboBarDB_Global.disabled = nil
            if NugComboBarDB.disabled then
                NugComboBar.isDisabled = true
                NugComboBar:SuperDisable()
            end

            playerClass = select(2,UnitClass("player"))

            self:RegisterEvent("PLAYER_LOGIN")
            self:RegisterEvent("PLAYER_LOGOUT")

            if NugComboBarDB.disableBlizz then NugComboBar.disableBlizzFrames() end

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
    ["gm_chatwarning"] = SOUNDKIT.GM_CHAT_WARNING,
    ["coldblood"] = 6774,
    ["alarmclockwarning3"] = SOUNDKIT.ALARM_CLOCK_WARNING_3,
    ["auctionwindowopen"] = SOUNDKIT.AUCTION_WINDOW_OPEN,
    ["wispwhat1"] = 6343,
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
    [trim(16/9)] = { 0.83, 0.83 },
    [trim(4/3)] = { 2.5, 2.5 },
}

function NugComboBar:IsDefaultSkin(set)
    if set then
        isDefaultSkin = set
    else
        return isDefaultSkin
    end
end

local pmult = 1
function NugComboBar.pixelperfect(size)
    return floor(size/pmult + 0.5)*pmult
end
local pixelperfect = NugComboBar.pixelperfect

do
    local initial = true
    function NugComboBar.PLAYER_LOGIN(self, event)
        if NugComboBar.isDisabled then return end

        local res = GetCVar("gxWindowedResolution") --select(GetCurrentResolution(), GetScreenResolutions())
        if res then
            local w,h = string.match(res, "(%d+)x(%d+)")
            pmult = (768/h) / UIParent:GetScale()
        end

        isDefaultSkin = NugComboBar:IsDefaultSkin()

        if initial then self:Create() end
        -- Always calling :Create will allow switching to vertical without reload?

        if NugComboBarDB.frameparent and _G[NugComboBarDB.frameparent] then
             NugComboBar:SetParent(_G[NugComboBarDB.frameparent])
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

        local presets = NugComboBar.presets
        if not presets[NugComboBarDB.preset3dlayer2] then
            NugComboBarDB.preset3dlayer2 = defaults.preset3dlayer2
            if not presets[NugComboBarDB.preset3dlayer2] then
                NugComboBarDB.preset3dlayer2 = next(presets)
            end
        end

        if not NugComboBar.soundFiles[NugComboBarDB.soundNameFull] then
            NugComboBarDB.soundNameFull = "none"
        end



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

        self:SetScale(NugComboBarDB.scale)

        self:LoadClassSettings()
        if initial then
            self:CreateAnchor()
        else
            self.anchor:ClearAllPoints()
            self.anchor:SetPoint(NugComboBarDB.apoint, NugComboBarDB.parent, NugComboBarDB.point,NugComboBarDB.x,NugComboBarDB.y)
        end

        if NugComboBarDB.nameplateAttachTarget then
            -- self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
            self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        else
            self.Commands.anchorpoint(NugComboBarDB.anchorpoint)
            self:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
            self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        end

        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
        if not isClassic then
            self:RegisterEvent("PET_BATTLE_OPENING_START")
            self:RegisterEvent("PET_BATTLE_CLOSE")
        end
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

    if NugComboBarDB.nameplateAttachTarget then
        local targetFrame = C_NamePlate.GetNamePlateForUnit("target")

        if targetFrame then
            self:Show()
            self:ClearAllPoints()
            self:SetPoint("BOTTOM", targetFrame, "TOP", NugComboBarDB.nameplateOffsetX, NugComboBarDB.nameplateOffsetY)
        else
            self:Hide()
        end
    end

    if not UnitExists("target") and NugComboBarDB.hideWithoutTarget and playerClass ~= "DEATHKNIGHT" then
        self:Hide()
    end
end

function NugComboBar.CheckComboPoints(self)
	if not self.isDisabled then
    	self:UNIT_COMBO_POINTS(nil, allowedUnit, nil)
	end
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

NugComboBar.ShowCooldownCharge = function(self, arg1, arg2, point) point.cd:Hide() end -- dummy to not break Valeera with NCB 7.1.4

function NugComboBar.EnableBar(self, min, max, btype, isTimer, isReversed)
    if not self.bar then return end
    self.bar.enabled = true
    if min and max then
        self.bar:SetMinMaxValues(min, max)
    end
    self.bar.isReversed = isReversed
    self.bar.max = max
    if not chargeCooldown then
    	if not btype or btype == "Small" then
    		self.bar:SetWidth(45)
    	end
    	if type(btype) == "number" then
    		self.bar:SetWidth(btype)
    	end
    end
	if isTimer then
		self.bar:SetScript("OnUpdate", AuraTimerOnUpdate)
	end
    -- self.bar:Show()
	return true
end

function NugComboBar.DisableBar(self)
    if not self.bar then return end
    self.bar.enabled = false
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
function NugComboBar.UNIT_COMBO_POINTS(self, event, unit, ...)
    if unit ~= allowedUnit then return end

    if onlyCombat and not UnitAffectingCombat("player") then
        self:Hide()
        return
    else
        if not NugComboBarDB.nameplateAttachTarget then
            self:Show()
        end
    end -- usually frame is set to 0 alpha
    -- local arg1, arg2
    local comboPoints, arg1, arg2, secondLayerPoints, secondBarPoints = GetComboPoints(unit);
    local progress = not arg2 and arg1 or nil

	    if self.bar and self.bar.enabled then
            if arg1 then
	            self.bar:Show()
	            if arg2 then
	                local startTime, duration = arg1, arg2
	                self.bar.startTime = startTime
	                self.bar.duration = duration
	                self.bar:SetMinMaxValues(0, duration)
	            else
	                self.bar:SetValue(progress)
	            end
	        else
	            self.bar:Hide()
	        end
	    end

	    if soundFullEnabled then
			-- print(comboPoints, self.MAX_POINTS, comboPoints ~= comboPointsBefore)
	        if  comboPoints == self.MAX_POINTS and
	            comboPoints ~= comboPointsBefore and
	            -- comboPointsBefore ~= 0 then
	            UnitGUID(allowedTargetUnit) == targetBefore then
                    local sound = NugComboBar.soundFiles[NugComboBarDB.soundNameFull]
                    if sound == "custom" then
                        sound = NugComboBarDB.soundNameFullCustom
                        PlaySoundFile(sound, NugComboBarDB.soundChannel)
                    else
                        if type(sound) == "number" then
                            PlaySound(sound, NugComboBarDB.soundChannel)
                        end
                    end
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

        if chargeCooldown and not chargeCooldownOnSecondBar then
            if isDefaultSkin then
                if comboPoints ~= self.MAX_POINTS then
                    local point = self.p[comboPoints+1]
                    if point then
                        NugComboBar:MoveCharger(point)
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

        if chargeCooldown and chargeCooldownOnSecondBar then
            if isDefaultSkin then
                if secondBarPoints ~= self.MAX_POINTS2 then
                    local point = self.p[self.MAX_POINTS+secondBarPoints+1]
                    NugComboBar:MoveCharger(point)
                end
            end
        end

	    end

    -- print("progress", progress)
    -- print (comboPoints, defaultValue, comboPoints == defaultValue, (progress == nil or progress == defaultProgress), not UnitAffectingCombat("player"), not showEmpty)
    local forceHide = IsInPetBattle() or self.isTempDisabled
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
    if point == "bar2" then
        local self = NugComboBar
        if self.MAX_POINTS2 then
            for i = 1, self.MAX_POINTS2 do
                local point = self.p[i+self.MAX_POINTS]
                point:SetColor(r,g,b)
            end
        end
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
    frame.anchor = self
    frame.RestoreStaticPosition = function(self)
        local p1 = NugComboBarDB.anchorpoint
        local p2
        if      p1 == "LEFT" then p2 = "RIGHT"
        elseif  p1 == "RIGHT" then p2 = "LEFT"
        elseif  p1 == "TOP" then p2 = "BOTTOM"
        end
        self:SetPoint(p1, self.anchor, p2, 0, 0)
    end
    frame:RestoreStaticPosition()



    self:EnableMouse(true)
    self:RegisterForDrag("LeftButton")
    self:SetMovable(true)
    self:SetScript("OnDragStart",function(self) self:StartMoving(); self:SetUserPlaced(false) end)
    self:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing();
        self:SetUserPlaced(false)
        local parent
        NugComboBarDB.apoint, parent, NugComboBarDB.point, NugComboBarDB.x, NugComboBarDB.y = self:GetPoint(1)
        NugComboBarDB.parent = "UIParent"
    end)

    self:Hide()
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
		NugComboBar:Show()
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
        NugComboBarDB.nameplateOffsetX = 0
        NugComboBarDB.nameplateOffsetY = 0
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
	["bar2offset"] = function(a,b)
		if type(a) == "string" then
			local p = ParseOpts(a)
	        NugComboBarDB.bar2_x = p["x"] or NugComboBarDB.bar2_x
	        NugComboBarDB.bar2_y = p["y"] or NugComboBarDB.bar2_y
		else
			NugComboBarDB.bar2_x = a or NugComboBarDB.bar2_x
	        NugComboBarDB.bar2_y = b or NugComboBarDB.bar2_y
		end
		NugComboBar:Reinitialize()
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
    ["toggleblizznp"] = function(v)
        NugComboBarDB.disableBlizzNP = not NugComboBarDB.disableBlizzNP
        print ("NCB> Changes will take effect after /reload")
    end,
    ["special"] = function(v)
        NugComboBarDB.special1 = not NugComboBarDB.special1
        print ("NCB Special = ", NugComboBarDB.special1)
    end,
    ["nameplateattach"] = function(v)
        NugComboBarDB.nameplateAttach = not NugComboBarDB.nameplateAttach
        NugComboBarDB.nameplateAttachTarget = false
        NugComboBar:Reinitialize()
    end,
    ["nameplateattachtarget"] = function(v)
        NugComboBarDB.nameplateAttachTarget = not NugComboBarDB.nameplateAttachTarget
        NugComboBarDB.nameplateAttach = false
        NugComboBar:Reinitialize()
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
	["chargecooldown"] = function(v)
		NugComboBarDB.chargeCooldown = not NugComboBarDB.chargeCooldown
        NugComboBar:Reinitialize()
    end,
	["maxfill"] = function(v)
		NugComboBarDB.maxFill = not NugComboBarDB.maxFill
        NugComboBar:Reinitialize()
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
    ["overridelayout"] = function(newLayout)
        if not newLayout or newLayout == "none" or newLayout == "Default" then newLayout = false end
        NugComboBarDB.overrideLayout = newLayout
        NugComboBar:Reinitialize()
    end,

    ["setparent"] = function(v)
        if _G[v] then
            NugComboBarDB.frameparent = v
            NugComboBar:SetParent(_G[v])
        end
    end,
}

local helpMessage = {
    "|cff55ffff/ncb gui|r",
    "|cff55ff55/ncb charspec|r",
    "|cff55ff55/ncb lock|r",
    "|cff55ff55/ncb unlock|r",
    "|cff55ff55/ncb toggle3d|r",
    "|cff55ff55/ncb preset3d <preset>|r",
    "|cff55ff55/ncb scale|r <0.3 - 2.0>",
    "|cff55ff55/ncb changecolor|r <1-6, 0 = all, -1 = 2nd bar>",
    "|cff55ff55/ncb anchorpoint|r <left | right | top >",
    "|cff55ff55/ncb showempty|r",
    "|cff55ff55/ncb hideslowly|r",
    "|cff55ff55/ncb vertical|r",
    "|cff55ff55/ncb hidewotarget|r",
    "|cff55ff55/ncb toggleblizz|r",
    "|cff55ff55/ncb disable|enable|r (for current class)",
    "|cff55ff55/ncb setpos|r point=CENTER parent=UIParent to=CENTER x=0 y=0",
    "|cff55ff55/ncb reset|r",
}

function NugComboBar.SlashCmd(msg)
    local k,v = string.match(msg, "([%w%+%-%=]+) ?(.*)")
    if not k or k == "help" then
        print("Usage:")
        for k,v in ipairs(helpMessage) do
            print(" - ",v)
        end
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

local HideBlizzFrame = function(frame)
	frame:UnregisterAllEvents()
	frame:Hide()
	frame._Show = frame.Show
	frame.Show = frame.Hide
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", UIParent, "BOTTOMRIGHT", 100, -100)
end

function NugComboBar.disableBlizzFrames()
    local class = select(2,UnitClass("player"))
        if class == "ROGUE" or class == "DRUID" then
            ComboFrame:UnregisterAllEvents()
            ComboFrame:Hide()
        end
end

function NugComboBar:OnSpecChanged()
    local spec = GetSpecialization()
    if currentSpec ~= spec then
        currentSpec = spec
        NugComboBar:Reinitialize()
    end
end

function NugComboBar:Disable()
	self.UNIT_AURA = self.UNIT_COMBO_POINTS
	GetComboPoints = dummy -- disable
	local old1 = showEmpty
	local old2 = hideSlowly
	showEmpty = false
	hideSlowly = false
	self:UNIT_COMBO_POINTS(nil,allowedUnit)
	showEmpty = old1
	hideSlowly = old2
	-- self:UnregisterEvent("UNIT_AURA")
	-- self:UnregisterEvent("UNIT_POWER_UPDATE")
	-- self:UnregisterEvent("SPELL_UPDATE_CHARGES")
	-- self:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
	self.isTempDisabled = true

	self:DisableBar()
    if self.anchor then self.anchor:Hide() end
    self:SetAlpha(0)
	self:Hide()
end

function NugComboBar:SuperDisable()
    self:UnregisterAllEvents()
    self:DisableBar()
    if self.anchor then self.anchor:Hide() end
    self:SetAlpha(0)
end

function NugComboBar.NAME_PLATE_UNIT_ADDED(self, event, unit)
    if NugComboBarDB.nameplateAttachTarget then
        if UnitIsUnit(unit, "target") then
            self:PLAYER_TARGET_CHANGED()
        end
    end

end
