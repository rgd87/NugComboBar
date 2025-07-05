local addonName, ns = ...

local NugComboBar = CreateFrame("Frame", "NugComboBar", UIParent)

local user
local flags
local allowedUnit = "player"
local allowedCaster = "player"
local allowedTargetUnit = "player"
local fadeAfter = 6
local combatFade = true -- whether to fade in combat
local defaultValue = 0
local defaultProgress = 0
local currentSpec = -1
local playerClass
local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local isDefaultSkin = nil
local enablePrettyRunes = nil
local UnitAura = UnitAura
local GetSpellCharges = GetSpellCharges
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local GetRuneCooldown = GetRuneCooldown
local tsort = table.sort
local math_max = math.max
local math_min = math.min
local dummy = function() return 0 end
local GetComboPoints = dummy
local LoadAddOn = LoadAddOn or C_AddOns.LoadAddOn

local GlobalGetSpecialization = C_SpecializationInfo and C_SpecializationInfo.GetSpecialization or _G.GetSpecialization
local function GetSpecializationWithFallback()
    local spec = GlobalGetSpecialization()
    if spec == 5 then -- spec below lvl 10
        return 1
        -- windwalker 3
    end
    return spec
end

--- Compatibility with Classic
local APILevel = math.floor(select(4,GetBuildInfo())/10000)
-- local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IsInPetBattle = APILevel <= 4 and function() end or C_PetBattles.IsInBattle
local GetSpecialization
if APILevel <= 4 then
    GetSpecialization = function() return 1 end
else
    GetSpecialization = GetSpecializationWithFallback
end

local configs = {}
local currentConfigName
local currentTriggerState = {}

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



local defaults = {
    global = {
        enable3d = false,
        disableBlizz = false,
        disableBlizzNP = false,
        enablePrettyRunes = true,
        classConfig = {
            ROGUE = { "ComboPointsRogue", "ComboPointsRogue", "ComboPointsAndShadowdance" },
            DRUID = { "ShapeshiftDruid", "ComboPointsDruid", "ShapeshiftDruid", "ComboPointsDruid" },
            PALADIN = { "HolyPower", "HolyPower", "HolyPower" },
            MONK = { "PurifyingBrew", "Teachings", "Chi" },
            WARLOCK = { "SoulShards", "SoulShards", "SoulShards" },
            DEMONHUNTER = { "Disabled", "SoulFragments" },
            DEATHKNIGHT = { "Runes", "Runes", "Runes" },
            MAGE = { "ArcaneCharges", "Fireblast", "Icicles" },
            WARRIOR = { "Disabled", "Meatcleaver", "ShieldBlock" },
            SHAMAN = { "Icefury", "MaelstromWeapon", "Disabled" },
            HUNTER = { "Disabled", "Disabled", "Disabled" },
            PRIEST = { "Disabled", "Disabled", "Disabled" },
            EVOKER = { "Essence", "Essence", "Essence" },
        },
        specProfiles = {
            ROGUE = { "Default", "Default", "Default" },
            DRUID = { "Default", "Default", "Default", "Default" },
            PALADIN = { "Default", "Default", "Default" },
            MONK = { "Default", "Default", "Default" },
            WARLOCK = { "Default", "Default", "Default" },
            DEMONHUNTER = { "Default", "Default" },
            DEATHKNIGHT = { "Default", "Default", "Default" },
            MAGE = { "Default", "Default", "Default" },
            WARRIOR = { "Default", "Default", "Default" },
            SHAMAN = { "Default", "Default", "Default" },
            HUNTER = { "Default", "Default", "Default" },
            PRIEST = { "Default", "Default", "Default" },
            EVOKER = { "Default", "Default", "Default" },
        }
    },
    profile = {
        apoint = "CENTER",
        parent = "UIParent",
        point = "CENTER", --to
        x = 0, y = 0,
        anchorpoint = "LEFT",
        frameparent = nil, -- for SetParent
        scale = 1.3,
        showEmpty = false,
        enableFullColor = false,
        hideSlowly = true,
        colors = {
            ['*'] = {1, 0.33, 0.74}, -- points
            ["full"] = { 1, 0.7, 0.2 },
            ["bar1"] = { 0.9,0.1,0.1 },
            ["bar2"] = { 0.71, 0.16, 0 },
            ["layer2"] = { 0.74, 0.06, 0 },
            ["row2"] = { 0.80, 0.23, 0.79 },
        },
        glowIntensity = 0.7,
        preset3d = "glowPurple",
        preset3dlayer2 = "glowArcshot",
        preset3dpointbar2 = "void",
        bar2_x = 13,
        bar2_y = -20,
        classThemes = false,
        colors3d = true,
        showAlways = false,
        onlyCombat = false,
        secondLayer = true,
        disableProgress = false,
        cooldownOnTop = false,
        chargeCooldown = true,
        animationLevel = 2,
        alpha = 1,
        nameplateAttach = false,
        nameplateAttachTarget = false,
        nameplateOffsetX = 0,
        nameplateOffsetY = 0,
        hideWithoutTarget = false,
        vertical = false,
        overrideLayout = false,
        soundChannel = "SFX",
        soundNameFull = "none",
        soundNameFullCustom = "Interface\\AddOns\\YourSound.mp3",
    },
}
NugComboBar.defaults = defaults

if APILevel <= 2 then
    defaults.global.classConfig = {
        ROGUE = { "ComboPointsRogueClassic", "ComboPointsRogueClassic", "ComboPointsRogueClassic" },
        DRUID = { "ShapeshiftDruid", "ComboPointsDruid", "ShapeshiftDruid", "ComboPointsDruid" },
        PALADIN = { "Disabled", "Disabled", "Disabled" },
        MONK = { "Disabled", "Disabled", "Disabled" },
        WARLOCK = { "Disabled", "Disabled", "Disabled" },
        DEMONHUNTER = { "Disabled", "Disabled" },
        DEATHKNIGHT = { "Disabled", "Disabled", "Disabled" },
        MAGE = { "ArcaneBlastClassic", "ArcaneBlastClassic", "ArcaneBlastClassic" },
        WARRIOR = { "Disabled", "Disabled", "Disabled" },
        SHAMAN = { "Disabled", "Disabled", "Disabled" },
        HUNTER = { "Disabled", "Disabled", "Disabled" },
        PRIEST = { "Disabled", "Disabled", "Disabled" },
    }
    if APILevel == 1 then -- Now there's Arcane Blast in SoD
        -- defaults.global.classConfig.MAGE = { "ArcaneBlastSoD", "ArcaneBlastSoD", "ArcaneBlastSoD" }
        defaults.global.classConfig.SHAMAN = { "MaelstromWeapon", "MaelstromWeapon", "MaelstromWeapon" }
    end
end
if APILevel == 3 then
    defaults.global.classConfig = {
        ROGUE = { "ComboPointsRogueClassic", "ComboPointsRogueClassic", "ComboPointsRogueClassic" },
        DRUID = { "ShapeshiftDruid", "ComboPointsDruid", "ShapeshiftDruid", "ComboPointsDruid" },
        PALADIN = { "Disabled", "Disabled", "Disabled" },
        MONK = { "Disabled", "Disabled", "Disabled" },
        WARLOCK = { "Disabled", "Disabled", "Disabled" },
        DEMONHUNTER = { "Disabled", "Disabled" },
        DEATHKNIGHT = { "Disabled", "Disabled", "Disabled" },
        MAGE = { "ArcaneBlastClassic", "ArcaneBlastClassic", "ArcaneBlastClassic" },
        WARRIOR = { "Disabled", "Disabled", "Disabled" },
        SHAMAN = { "MaelstromWeapon", "MaelstromWeapon", "MaelstromWeapon" },
        HUNTER = { "Disabled", "Disabled", "Disabled" },
        PRIEST = { "Disabled", "Disabled", "Disabled" },
    }
end
if APILevel == 4 then
    defaults.global.classConfig = {
        ROGUE = { "ComboPointsRogueClassic", "ComboPointsRogueClassic", "ComboPointsRogueClassic" },
        DRUID = { "ShapeshiftDruid", "ComboPointsDruid", "ShapeshiftDruid", "ComboPointsDruid" },
        PALADIN = { "HolyPower", "HolyPower", "HolyPower" },
        MONK = { "Disabled", "Disabled", "Disabled" },
        WARLOCK = { "SoulShards", "SoulShards", "SoulShards" },
        DEMONHUNTER = { "Disabled", "Disabled" },
        DEATHKNIGHT = { "Disabled", "Disabled", "Disabled" },
        MAGE = { "ArcaneBlastClassic", "ArcaneBlastClassic", "ArcaneBlastClassic" },
        WARRIOR = { "Disabled", "Disabled", "Disabled" },
        SHAMAN = { "MaelstromWeapon", "MaelstromWeapon", "MaelstromWeapon" },
        HUNTER = { "Disabled", "Disabled", "Disabled" },
        PRIEST = { "ShadowOrbs", "ShadowOrbs", "ShadowOrbs" },
    }
end
if APILevel == 5 then
    defaults.global.classConfig = {
        ROGUE = { "ComboPointsAnticipation", "ComboPointsAnticipation", "ComboPointsAnticipation" },
        DRUID = { "ShapeshiftDruid", "ComboPointsDruid", "ShapeshiftDruid", "ComboPointsDruid" },
        PALADIN = { "HolyPower", "HolyPower", "HolyPower" },
        MONK = { "Chi", "Chi", "Chi" },
        WARLOCK = { "SoulShards", "SoulShards", "SoulShards" },
        DEMONHUNTER = { "Disabled", "Disabled" },
        DEATHKNIGHT = { "Disabled", "Disabled", "Disabled" },
        MAGE = { "ArcaneBlastClassic", "ArcaneBlastClassic", "ArcaneBlastClassic" },
        WARRIOR = { "TasteForBlood", "Meatcleaver", "Disabled" },
        SHAMAN = { "MaelstromWeapon", "MaelstromWeapon", "MaelstromWeapon" },
        HUNTER = { "Disabled", "Disabled", "Disabled" },
        PRIEST = { "ShadowOrbs", "ShadowOrbs", "ShadowOrbs" },
    }
end

function NugComboBar:LoadClassSettings()
        local class = select(2,UnitClass("player"))
        self.MAX_POINTS = 0
        self.isTempDisabled = nil
        if self.bar then self.bar:SetColor(unpack(self.db.profile.colors.bar1)) end

        self:RegisterEvent("SPELLS_CHANGED")
end
function NugComboBar:SPELLS_CHANGED()
    local spec = GetSpecialization()
    local class = select(2,UnitClass("player"))

    local currentProfile = self.db:GetCurrentProfile()
    local newSpecProfile = self.db.global.specProfiles[class][spec] or "Default"
    if not self.db.profiles[newSpecProfile] then
        self.db.global.specProfiles[class][spec] = "Default"
        newSpecProfile = "Default"
    end
    if newSpecProfile ~= currentProfile then
        self.db:SetProfile(newSpecProfile)
    end

    local newConfigName = self.db.global.classConfig[class][spec] or "Disabled"

    -- If using missing config reset to default
    if newConfigName ~= "Disabled" and not configs[newConfigName] then
        self.db.global.classConfig[class][spec] = defaults.global.classConfig[class][spec]
        newConfigName = self.db.global.classConfig[class][spec] or "Disabled"
    end

    if newConfigName == "Disabled" then
        self:ResetConfig()
        self:Disable()
        currentConfigName = nil
        return
    else
        self:Enable()
    end

    local currentConfig = configs[currentConfigName]

    local needUpdate
    local changedConfig = currentConfigName ~= newConfigName
    if changedConfig then
        needUpdate = true
    else
        local newTriggerState = self:GetTriggerState(currentConfig)
        needUpdate = not self:IsTriggerStateEqual(currentTriggerState, newTriggerState)
    end

    if needUpdate then
        self:SelectConfig(newConfigName)
        self:Update()
    end
end

NugComboBar.SkinVersion = 600
do
    function NugComboBar.ADDON_LOADED(self,event,arg1)
        if arg1 == addonName then
            NugComboBarDB_Global = NugComboBarDB_Global or {}
            NugComboBarDB_Character = NugComboBarDB_Character or {}

            self:DoMigrations(NugComboBarDB_Global)
            self.db = LibStub("AceDB-3.0"):New("NugComboBarDB_Global", defaults, "Default") -- Create a DB using defaults and using a shared default profile
            NugComboBarDB = self.db

            self.db.RegisterCallback(self, "OnProfileChanged", "Reconfigure")
            self.db.RegisterCallback(self, "OnProfileCopied", "Reconfigure")
            self.db.RegisterCallback(self, "OnProfileReset", "Reconfigure")

            playerClass = select(2,UnitClass("player"))

            self:RegisterEvent("PLAYER_LOGIN")
            -- self:RegisterEvent("PLAYER_LOGOUT")

            if self.db.global.disableBlizz then NugComboBar.disableBlizzFrames() end
            -- if self.db.global.disableBlizzNP then NugComboBar.disableBlizzNameplates() end

            local f = CreateFrame('Frame', nil, SettingsPanel or InterfaceOptionsFrame) -- helper frame to load GUI and to watch specialization changes
            f:SetScript('OnShow', function(self)
                self:SetScript('OnShow', nil)

                LoadAddOn('NugComboBarGUI')
            end)

            SLASH_NCBSLASH1 = "/ncb";
            SLASH_NCBSLASH2 = "/nugcombobar";
            SLASH_NCBSLASH3 = "/NugComboBar";
            SlashCmdList["NCBSLASH"] = NugComboBar.SlashCmd

        end
    end
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
    -- return PixelUtil.GetNearestPixelSize(size, NugComboBar:GetEffectiveScale(), size) -- No PixelUtil on classic
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

        local profile = self.db.profile

        if profile.frameparent and _G[profile.frameparent] then
             NugComboBar:SetParent(_G[profile.frameparent])
        end

        local presets = NugComboBar.presets
        if not presets[profile.preset3dlayer2] then
            profile.preset3dlayer2 = defaults.preset3dlayer2
            if not presets[profile.preset3dlayer2] then
                profile.preset3dlayer2 = next(presets)
            end
        end

        if not NugComboBar.soundFiles[profile.soundNameFull] then
            profile.soundNameFull = "none"
        end

        enablePrettyRunes = self.db.global.enablePrettyRunes
        self:SetAlpha(0)
        self:SetScale(profile.scale)

        self.eventProxy = CreateFrame("Frame", nil, self)
        self.eventProxy:SetScript("OnEvent", function(proxy, event, ...)
            return proxy[event](NugComboBar, event, ...)
        end)

        self.flags = setmetatable({}, {
            __index = function(t,k)
                return NugComboBar.db.profile[k]
            end
        })
        flags = self.flags

        self:LoadClassSettings()
        if initial then
            self:CreateAnchor()
        else
            self.anchor:ClearAllPoints()
            self.anchor:SetPoint(profile.apoint, profile.parent, profile.point,profile.x,profile.y)
        end

        self:UpdatePosition()

        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
        if APILevel >= 5 then
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

function NugComboBar:Reconfigure()
    self:UpdatePosition()

    local profile = self.db.profile
    self:SetScale(profile.scale)

    self.forceHidden = false

    if currentConfigName then
        self:SelectConfig(currentConfigName)
        self:Update() -- will update alpha
    end

    -- colors & col 3d & glow int:
    --               Fixed by SetColor inside SetMaxPoints
    -- NugComboBar:Set3DPreset()
    -- bar2 offset: Inside skin.lua Will get updated by SetMaxPoints,
    --              but only if frame was actually reconstructed by config switch
    -- disable progress: Reselect config
    -- -- cd on top -- Nothing?
end


local fadeTime = 1
local fader = CreateFrame("Frame")
local HideTimer = function(self, time)
    self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
    if self.OnUpdateCounter < fadeAfter then return end

    local ncb = NugComboBar
    local a = math_max(0, 1-((self.OnUpdateCounter - fadeAfter) / fadeTime))
    ncb:SetAlpha(NugComboBar.db.profile.alpha*a)
    if self.OnUpdateCounter >= fadeAfter + fadeTime then
        self:SetScript("OnUpdate",nil)
        ncb:SetAlpha(0)
        ncb.hiding = false
        self.OnUpdateCounter = 0
    end
end


function NugComboBar.PLAYER_TARGET_CHANGED(self, event)
    if self.db.profile.nameplateAttachTarget then
        local targetFrame = C_NamePlate.GetNamePlateForUnit("target")

        local isAttackable = UnitCanAttack("player", "target")
        local isFriendly = (UnitReaction("target", "player") or 0) > 4

        if targetFrame and isAttackable and not isFriendly then
            self:Show()
            self:ClearAllPoints()
            self:SetPoint("BOTTOM", targetFrame, "TOP", self.db.profile.nameplateOffsetX, self.db.profile.nameplateOffsetY)
        else
            self:Hide()
        end
    elseif self.db.profile.hideWithoutTarget and not self:IsDisabled() then
            self.forceHidden = not UnitExists("target")
            self:Update()
    end
end

function NugComboBar.CheckComboPoints(self)
	if GetComboPoints ~= dummy  then
    	self:UNIT_COMBO_POINTS(nil, allowedUnit, nil)
	end
end


NugComboBar.ShowCooldownCharge = function(self, arg1, arg2, point) point.cd:Hide() end -- dummy to not break Valeera with NCB 7.1.4

function NugComboBar.EnableBar(self, min, max, btype, isTimer, isReversed)
    if not self.bar then return end
    if self.db.profile.disableProgress then return end

    self.bar.enabled = true
    if min and max then
        self.bar:SetMinMaxValues(min, max)
    end
    self.bar.isReversed = isReversed
    self.bar.max = max
    if not flags.chargeCooldown then
    	if not btype or btype == "Small" then
            self.bar:SetWidth(pixelperfect(45))
            self.bar:SetHeight(pixelperfect(4))
    	end
    	if type(btype) == "number" then
            self.bar:SetWidth(pixelperfect(btype))
            self.bar:SetHeight(pixelperfect(4))
    	end
    end
	if isTimer then
		self.bar:SetScript("OnUpdate", AuraTimerOnUpdate)
	end
	return true
end

function NugComboBar.DisableBar(self)
    if not self.bar then return end
    self.bar:SetScript("OnUpdate", nil)
    self.bar.enabled = false
    self.bar:Hide()
end

local function AnticipationIn(point, i)
    local r,g,b = unpack(NugComboBar:GetColor("layer2"))
    point:SetColor(r,g,b)
    point.anticipationColor = true
    point:SetPreset(NugComboBar:Get3DPreset("preset3dlayer2"))
end

local function AnticipationOut(point, i)
    local r,g,b = unpack(NugComboBar:GetColor(i))
    point:SetColor(r,g,b)
    point.anticipationColor = false
    point:SetPreset(NugComboBar:Get3DPreset("preset3d"))
end

function NugComboBar:GetPoint(i)
    return self.p[i]
end

function NugComboBar:SelectPoint(i)
    local point = self:GetPoint(i)
    if not point.Select then return end
    point:Select()
    point.isSelected = true
end

function NugComboBar:DeselectPoint(i)
    local point = self:GetPoint(i)
    if not point.Deselect then return end
    if point.isSelected then
        AnticipationOut(point, i)
    end
    point:Deselect()
    point.isSelected = nil
end

function NugComboBar:DeselectAllPoints()
    for i = 1, self.MAX_POINTS do
        local point = self.p[i]
        if point.isSelected then
            AnticipationOut(point, i)
        end
    end
    for i, point in ipairs(self.point) do
        if point.Deselect then
            point:Deselect()
            point.isSelected = nil
        end
    end
end


local comboPointsBefore = 0
local targetBefore

function NugComboBar.UNIT_COMBO_POINTS(self, event, unit, ...)
    if unit ~= allowedUnit then return end
    self:Update(unit, ...)
end

function NugComboBar:Update(unit, ...)
    local profile = self.db.profile
    if flags.onlyCombat and not UnitAffectingCombat("player") then
        self:Hide()
        return
    else
        if not profile.nameplateAttachTarget then
            self:Show()
        else
            self:PLAYER_TARGET_CHANGED()
        end
    end -- usually frame is set to 0 alpha

    local animationLevel = self.db.profile.animationLevel
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

	    if flags.soundFullEnabled then
			-- print(comboPoints, self.MAX_POINTS, comboPoints ~= comboPointsBefore)
	        if  comboPoints == self.MAX_POINTS and
	            comboPoints ~= comboPointsBefore and
	            -- comboPointsBefore ~= 0 then
	            UnitGUID(allowedTargetUnit) == targetBefore then
                    local sound = NugComboBar.soundFiles[profile.soundNameFull]
                    if sound == "custom" then
                        sound = profile.soundNameFullCustom
                        PlaySoundFile(sound, profile.soundChannel)
                    else
                        if type(sound) == "number" then
                            PlaySound(sound, profile.soundChannel)
                        end
                    end
	        end
	        targetBefore = UnitGUID(allowedTargetUnit)
	    end

        if flags.isRuneTracker and isDefaultSkin then
            local runeIndex, isEnergize = ...
            self:UpdateRunes(runeIndex, isEnergize)
        else
            local isFull = comboPoints == self.MAX_POINTS
    	    for i = 1, self.MAX_POINTS do
                local point = self.p[i]

                if self.db.profile.enableFullColor then
                    local r,g,b = unpack(NugComboBar:GetColor(isFull and "full" or i))
                    point:SetColor(r,g,b)
                end

    	        if i <= comboPoints then
                    point:Activate(animationLevel)
                    if flags.secondLayer then
                        if point.isSelected then
                            if comboPoints == i then
                                AnticipationIn(point, i)
                            else
                                AnticipationOut(point, i)
                            end
                        end
                    end
    	        end
    	        if i > comboPoints then
    	            point:Deactivate(animationLevel)
    	        end

                if flags.secondLayer then
                    if secondLayerPoints then -- Anticipation stuff
                        if i <= secondLayerPoints then
                            if  (point.currentPreset and point.currentPreset ~= profile.preset3dlayer2)
                                or
                                (not point.anticipationColor) then

                                point:Reappear(animationLevel, AnticipationIn, i)
                            end
                        else
                            if  not point.isSelected and
                                ((point.currentPreset and point.currentPreset ~= profile.preset3d)
                                or
                                (point.anticipationColor)) then

                                if i <= comboPoints then
                                    point:Reappear(animationLevel, AnticipationOut, i)
                                else
                                    AnticipationOut(point, i)
                                end
                            end
                        end
                    end
                end
    	    end
        end

        if flags.chargeCooldown and not flags.chargeCooldownOnSecondBar then
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
	            point:Activate(animationLevel)
	        end
	        if i > secondBarPoints then
	            point:Deactivate(animationLevel)
	        end

	    end

        if flags.chargeCooldown and flags.chargeCooldownOnSecondBar then
            if isDefaultSkin then
                if secondBarPoints ~= self.MAX_POINTS2 then
                    local point = self.p[self.MAX_POINTS+secondBarPoints+1]
                    NugComboBar:MoveCharger(point)
                end
            end
        end

	    end

    local forceHide = IsInPetBattle() or self.forceHidden or self.isDisabled
    if forceHide or
        (
            not flags.showAlways and
            comboPoints == defaultValue and -- or (defaultValue == -1 and lastChangeTime < GetTime() - 9)) and
            (progress == nil or progress == defaultProgress) and
            (not UnitAffectingCombat("player") or not flags.showEmpty)
        )
        then
            local hidden = self:GetAlpha() == 0
            if flags.hideSlowly and not forceHide then
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
        self:SetAlpha(profile.alpha)
    end

    comboPointsBefore = comboPoints
end

function NugComboBar.SetColor(point, r, g, b)
    if b then
        NugComboBar.db.profile.colors[point] = {r,g,b}
    else
        local clr = NugComboBar.db.profile.colors[point]
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

function NugComboBar.CreateAnchor(frame)
    local self = CreateFrame("Frame",nil,UIParent)
    self:SetWidth(10)
    self:SetHeight(frame:GetHeight())

    local t = self:CreateTexture(nil, "ARTWORK")
    t:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    t:SetAllPoints(self)
    t:SetVertexColor(1, 0, 0, 0.8)
    self:SetFrameStrata("HIGH")

    local profile = NugComboBar.db.profile

    self:SetPoint(profile.apoint, profile.parent, profile.point,profile.x,profile.y)
    frame.anchor = self

    self:EnableMouse(true)
    self:RegisterForDrag("LeftButton")
    self:SetMovable(true)
    self:SetScript("OnDragStart",function(self) self:StartMoving(); self:SetUserPlaced(false) end)
    self:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing();
        self:SetUserPlaced(false)
        local parent
        local profile = NugComboBar.db.profile
        profile.apoint, parent, profile.point, profile.x, profile.y = self:GetPoint(1)
        profile.parent = "UIParent"
    end)

    self:Hide()
end

----------------------
-- CLASS THEMES
----------------------
function NugComboBar:GetCurrentTheme()
    local theme
    if isDefaultSkin and self.db.profile.classThemes then
        local classTable = self.themes[playerClass]
        if not classTable then return end
        -- local modeCategory = self.db.global.enable3d and "mode3d" or "mode2d"
        local modeCategory = "mode2d"
        local specThemes = classTable[modeCategory]
        if not specThemes then return end
        local spec = GetSpecialization()
        theme = specThemes[spec] or specThemes[0]
    end
    return theme
end

function NugComboBar:GetColor(key)
    local theme = self:GetCurrentTheme()
    local overridenColor
    if theme then
        if theme.colors then
            overridenColor = theme.colors[key] or theme.colors["normal"]
        end
    end

    if overridenColor then
        return overridenColor
    else
        local profileColors = self.db.profile.colors
        return profileColors[key]
    end
end

function NugComboBar:Get3DPreset(presetType)
    local theme = self:GetCurrentTheme()
    local overridenPreset
    if theme then
        overridenPreset = theme[presetType]
    end

    if overridenPreset then
        return overridenPreset
    else
        local preset = self.db.profile[presetType]
        if not NugComboBar.presets[preset] then -- filled in skin.lua currently
            self.db.profile[presetType] = defaults.profile[presetType]
            preset = defaults.profile[presetType]
        end
        return preset
    end
end

-----------------------

function NugComboBar:UpdatePosition()
    local playerNameplateEnabled = GetCVar("nameplateShowSelf") == "1"
    local profile = self.db.profile
    if profile.nameplateAttachTarget then
        self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
        self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    elseif playerNameplateEnabled and profile.nameplateAttach then
        if C_NamePlate.GetNamePlateForUnit("player") then
            NugComboBar:NAME_PLATE_UNIT_ADDED(nil, "player")
        else
            NugComboBar:NAME_PLATE_UNIT_REMOVED(nil, "player")
        end
        self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
        self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    else
        local p1 = profile.anchorpoint
        local p2
        if      p1 == "LEFT" then p2 = "RIGHT"
        elseif  p1 == "RIGHT" then p2 = "LEFT"
        elseif  p1 == "TOP" then p2 = "BOTTOM"
        end
        self:ClearAllPoints()
        self:SetPoint(p1, self.anchor, p2, 0, 0)

        self.anchor:ClearAllPoints()
        self.anchor:SetPoint(profile.apoint, profile.parent, profile.point,profile.x,profile.y)

        self:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
        self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
    end
end



function NugComboBar.ShowColorPicker(self,color)
    ColorPickerFrame:Hide()
    local upcolor = (color > 0) and color or 5
    NugComboBar.colorPickerColor = color

    if ColorPickerFrame.SetupColorPickerAndShow then
        local r2, g2, b2 = unpack(NugComboBar.db.profile.colors[upcolor])

        local SaveColor = function(colorID,r,g,b)
            if colorID == 0 then
                for i=1,#self.point do
                    NugComboBar.SetColor(i, r,g,b)
                end
            elseif colorID == -1 then
                for i=1, self.MAX_POINTS2 do
                    local index = i+self.MAX_POINTS
                    NugComboBar.SetColor(index, r,g,b)
                end
            else
                NugComboBar.SetColor(colorID, r,g,b)
            end
        end

        local info = {
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                local a = ColorPickerFrame:GetColorAlpha()
                SaveColor(color, r, g, b)
            end,

            hasOpacity = false,
            -- opacityFunc = function()
            --     local r, g, b = ColorPickerFrame:GetColorRGB()
            --     local a = ColorPickerFrame:GetColorAlpha()
            --     ColorCallback(self, r, g, b, a, true)
            -- end,
            opacity = 1,

            cancelFunc = function()
                SaveColor(color, r2, g2, b2)
            end,

            r = r2,
            g = g2,
            b = b2,
        }

        ColorPickerFrame:SetupColorPickerAndShow(info)
    else
        ColorPickerFrame:SetColorRGB(unpack(NugComboBar.db.profile.colors[upcolor]))
        ColorPickerFrame.hasOpacity = false
        ColorPickerFrame.previousValues = {unpack(NugComboBar.db.profile.colors[upcolor])} -- otherwise we'll get reference to changed table
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
end

function NugComboBar.Set3DPreset(self, preset, preset2)
    local e1 = preset or self.db.profile.preset3d
    local e2 = preset2 or self.db.profile.preset3dpointbar2
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

function NugComboBar:NotifyGUI()
    if LibStub then
        local cfgreg = LibStub("AceConfigRegistry-3.0", true)
        if cfgreg then cfgreg:NotifyChange("NugComboBar-General") end
    end
end
function NugComboBar.Reinitialize(self)
    self:NotifyGUI()
    NugComboBar:Reconfigure()
end

local ParseOpts = function(str)
    local fields = {}
    for opt,args in string.gmatch(str,"(%w*)%s*=%s*([%w%,%-%_%.%:%\\%']+)") do
        fields[opt:lower()] = tonumber(args) or args
    end
    return fields
end

local function InterfaceOptionsFrame_OpenToCategory(categoryIDOrFrame)
	if type(categoryIDOrFrame) == "table" then
		local categoryID = categoryIDOrFrame.name;
		return Settings.OpenToCategory(categoryID);
	else
		return Settings.OpenToCategory(categoryIDOrFrame);
	end
end


NugComboBar.Commands = {
    ["unlock"] = function(v)
		NugComboBar:Show()
        NugComboBar.anchor:Show()
        NugComboBar:SetAlpha(NugComboBar.db.profile.alpha)
        for i=1,NugComboBar.MAX_POINTS do
            NugComboBar.p[i]:Activate()
        end
    end,
    ["lock"] = function(v)
        NugComboBar.anchor:Hide()
        NugComboBar:Update()
    end,
    ["reset"] = function(v)
        NugComboBar.anchor:ClearAllPoints()
        NugComboBar.anchor:SetPoint("CENTER",UIParent,"CENTER",0,0)
        NugComboBar.db.profile.nameplateOffsetX = 0
        NugComboBar.db.profile.nameplateOffsetY = 0
    end,
    ["anchorpoint"] = function(v)
        local ap = v:upper()
        if ap ~= "RIGHT" and ap ~="LEFT" and ap ~= "TOP" then print ("Current anchor point is: "..NugComboBar.db.profile.anchorpoint); return end
        NugComboBar.db.profile.anchorpoint = ap
        NugComboBar:UpdatePosition()
    end,
	["bar2offset"] = function(a,b)
		if type(a) == "string" then
			local p = ParseOpts(a)
	        NugComboBar.db.profile.bar2_x = p["x"] or NugComboBar.db.profile.bar2_x
	        NugComboBar.db.profile.bar2_y = p["y"] or NugComboBar.db.profile.bar2_y
		else
			NugComboBar.db.profile.bar2_x = a or NugComboBar.db.profile.bar2_x
	        NugComboBar.db.profile.bar2_y = b or NugComboBar.db.profile.bar2_y
		end
		NugComboBar:Reinitialize()
	end,
    ["showempty"] = function(v)
        NugComboBar.db.profile.showEmpty = not NugComboBar.db.profile.showEmpty
        NugComboBar:PLAYER_TARGET_CHANGED()
    end,
    ["showalways"] = function(v)
        NugComboBar.db.profile.showAlways = not NugComboBar.db.profile.showAlways
        NugComboBar:PLAYER_TARGET_CHANGED()
    end,
    ["onlycombat"] = function(v)
        NugComboBar.db.profile.onlyCombat = not NugComboBar.db.profile.onlyCombat
        NugComboBar:PLAYER_TARGET_CHANGED()
    end,
    ["hideslowly"] = function(v)
        NugComboBar.db.profile.hideSlowly = not NugComboBar.db.profile.hideSlowly
    end,
    ["toggleblizz"] = function(v)
        NugComboBar.db.global.disableBlizz = not NugComboBar.db.global.disableBlizz
        print ("NCB> Changes will take effect after /reload")
    end,
    ["toggleblizznp"] = function(v)
        NugComboBar.db.global.disableBlizzNP = not NugComboBar.db.global.disableBlizzNP
        print ("NCB> Changes will take effect after /reload")
    end,
    ["nameplateattach"] = function(v)
        NugComboBar.db.profile.nameplateAttach = not NugComboBar.db.profile.nameplateAttach
        NugComboBar.db.profile.nameplateAttachTarget = false
        NugComboBar:Reinitialize()
    end,
    ["nameplateattachtarget"] = function(v)
        NugComboBar.db.profile.nameplateAttachTarget = not NugComboBar.db.profile.nameplateAttachTarget
        NugComboBar.db.profile.nameplateAttach = false
        NugComboBar:Reinitialize()
    end,
    ["scale"] = function(v)
        local num = tonumber(v)
        if num then
            NugComboBar.db.profile.scale = num; NugComboBar:SetScale(NugComboBar.db.profile.scale);
        else print ("Current scale is: ".. NugComboBar.db.profile.scale)
        end
    end,
    ["alpha"] = function(v)
        local num = tonumber(v)
        if num then
            NugComboBar.db.profile.alpha = num; NugComboBar:SetAlpha(NugComboBar.db.profile.alpha);
        else print ("Current alpha is: ".. NugComboBar.db.profile.alpha)
        end
    end,
	["chargecooldown"] = function(v)
		NugComboBar.db.profile.chargeCooldown = not NugComboBar.db.profile.chargeCooldown
        NugComboBar:Reinitialize()
    end,
	["maxfill"] = function(v)
		NugComboBar.db.profile.maxFill = not NugComboBar.db.profile.maxFill
        NugComboBar:Reinitialize()
    end,
    ["changecolor"] = function(v)
        local num = tonumber(v)
        if num then
            NugComboBar:ShowColorPicker(num)
        end
    end,
    ["hidewotarget"] = function(v)
        NugComboBar.db.profile.hideWithoutTarget = not NugComboBar.db.profile.hideWithoutTarget
        NugComboBar.forceHidden = false
        NugComboBar:PLAYER_TARGET_CHANGED()
    end,
    ["secondlayer"] = function(v)
        NugComboBar.db.profile.secondLayer = not NugComboBar.db.profile.secondLayer
    end,
    ["toggleprogress"] = function(v)
        NugComboBar.db.profile.disableProgress = not NugComboBar.db.profile.disableProgress
        if NugComboBar.db.profile.disableProgress then
            NugComboBar.EnableBar_ = NugComboBar.EnableBar
            NugComboBar.EnableBar = NugComboBar.DisableBar
            NugComboBar:DisableBar()
        else
            NugComboBar.EnableBar = NugComboBar.EnableBar_
            NugComboBar:LoadClassSettings()
        end
    end,
    ["toggle3d"] = function(v)
        NugComboBar.db.global.enable3d = not NugComboBar.db.global.enable3d
    end,
    ["classthemes"] = function(v)
        NugComboBar.db.profile.classThemes = not NugComboBar.db.profile.classThemes
        NugComboBar:Reinitialize()
    end,
    ["preset3d"] = function(v)
        if not NugComboBar.presets[v] then
            return print(string.format("Preset '%s' does not exist", v))
        end
        NugComboBar.db.profile.preset3d = v
        NugComboBar:Set3DPreset(v)
    end,
    ["preset3dlayer2"] = function(v)
        if not NugComboBar.presets[v] then
            return print(string.format("Preset '%s' does not exist", v))
        end
        NugComboBar.db.profile.preset3dlayer2 = v
    end,
    ["preset3dpointbar2"] = function(v)
        if not NugComboBar.presets[v] then
            return print(string.format("Preset '%s' does not exist", v))
        end
        NugComboBar.db.profile.preset3dpointbar2 = v
        NugComboBar:Set3DPreset()
    end,
    ["colors3d"] = function(v)
        NugComboBar.db.profile.colors3d = not NugComboBar.db.profile.colors3d
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
        NugComboBar.db.global.vertical = not NugComboBar.db.global.vertical
        ReloadUI()
    end,
    ["playsound"] = function(v)
        if not NugComboBar.soundFiles[v] then
            return print(string.format("Sound '%s' does not exist", v))
        end
        NugComboBar.db.profile.soundNameFull = v
    end,
    ["setpos"] = function(v)
        local p = ParseOpts(v)
        NugComboBar.db.profile.apoint = p["point"] or NugComboBar.db.profile.apoint
        NugComboBar.db.profile.parent = p["parent"] or NugComboBar.db.profile.parent
        NugComboBar.db.profile.point = p["to"] or NugComboBar.db.profile.point
        NugComboBar.db.profile.x = p["x"] or NugComboBar.db.profile.x
        NugComboBar.db.profile.y = p["y"] or NugComboBar.db.profile.y
        local pos = NugComboBar.db.profile
        NugComboBar.anchor:SetPoint(pos.apoint, pos.parent, pos.point, pos.x, pos.y)
    end,
    ["overridelayout"] = function(newLayout)
        if not newLayout or newLayout == "none" or newLayout == "Default" then newLayout = false end
        NugComboBar.db.profile.overrideLayout = newLayout
        NugComboBar:Reinitialize()
    end,

    ["setparent"] = function(v)
        if _G[v] then
            NugComboBar.db.profile.frameparent = v
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
end

local HideBlizzFrame = function(frame, nosetup)
    if not frame then return end
	frame:UnregisterAllEvents()
	frame:Hide()
	hooksecurefunc(frame, "Show", function(self)
        self:Hide()
    end)
    if not nosetup then
        hooksecurefunc(frame, "Setup", function(self)
            self:Hide()
            self:UnregisterAllEvents()
        end)
    end
	-- frame:ClearAllPoints()
	-- frame:SetPoint("TOPLEFT", UIParent, "BOTTOMRIGHT", 100, -100)
end

function NugComboBar.disableBlizzFrames()
    local class = select(2,UnitClass("player"))
    if APILevel >= 5 then
        if class == "ROGUE" or class == "DRUID" then
            HideBlizzFrame(ComboPointPlayerFrame)
            HideBlizzFrame(RogueComboPointBarFrame)
        end
        if class == "WARLOCK" then
            HideBlizzFrame(WarlockPowerFrame)
        end
        if class == "PALADIN" then
			HideBlizzFrame(PaladinPowerBarFrame)
        end
        if class == "MAGE" then
			HideBlizzFrame(MageArcaneChargesFrame)
        end
        if class == "MONK" then
			MonkHarmonyBarFrame:UpdateMaxPower()
			HideBlizzFrame(MonkHarmonyBarFrame)
        end
		if class == "DEATHKNIGHT" then
			HideBlizzFrame(RuneFrame, true)
        end
    elseif APILevel <= 2 then
        if class == "ROGUE" or class == "DRUID" then
            ComboFrame:UnregisterAllEvents()
            ComboFrame:Hide()
        end
    end
end

function NugComboBar.disableBlizzNameplates()
    local class = select(2,UnitClass("player"))
        if class == "ROGUE" or class == "DRUID" then
            ClassNameplateBarRogueDruidFrame:UnregisterAllEvents()
            ClassNameplateBarRogueDruidFrame:HideNameplateBar()
        end
        if class == "WARLOCK" then
            ClassNameplateBarWarlockFrame:UnregisterAllEvents()
            ClassNameplateBarWarlockFrame:HideNameplateBar()
        end
        if class == "PALADIN" then
            ClassNameplateBarPaladinFrame:UnregisterAllEvents()
            ClassNameplateBarPaladinFrame:HideNameplateBar()
        end
        if class == "MAGE" then
            ClassNameplateBarMageFrame:UnregisterAllEvents()
            ClassNameplateBarMageFrame:HideNameplateBar()
        end
        if class == "MONK" then
            ClassNameplateBarWindwalkerMonkFrame:UnregisterAllEvents()
            ClassNameplateBarWindwalkerMonkFrame:HideNameplateBar()
        end
		if class == "DEATHKNIGHT" then
            DeathKnightResourceOverlayFrame:UnregisterAllEvents()
            DeathKnightResourceOverlayFrame:HideNameplateBar()
        end
end


function NugComboBar:Disable()
	-- self.UNIT_AURA = self.UNIT_COMBO_POINTS
	GetComboPoints = dummy -- disable
	-- local old1 = showEmpty
	-- local old2 = hideSlowly
	-- showEmpty = false
	-- hideSlowly = false
	-- self:UNIT_COMBO_POINTS(nil,allowedUnit)
	-- showEmpty = old1
	-- hideSlowly = old2

    -- self.isTempDisabled = true

    self.isDisabled = true

	self:DisableBar()
    if self.anchor then self.anchor:Hide() end
    self:SetAlpha(0)
	self:Hide()
end

function NugComboBar:Enable()
    self.isDisabled = false
end
function NugComboBar:IsDisabled()
    return self.isDisabled
end

function NugComboBar:SuperDisable()
    self:UnregisterAllEvents()
    self:DisableBar()
    if self.anchor then self.anchor:Hide() end
    self:SetAlpha(0)
end

local function RuneChargeOnUpdate(self, time)
	local now = GetTime()
	local frame = self.frame
    local runeStart = frame.runeStart or now
	local elapsed = now - runeStart
	local progress = elapsed/frame.runeDuration
	if progress < 0 then progress = 0 end
    if progress > 1 then progress = 1 end

    if enablePrettyRunes then
        local pmp = math_min(math_max( progress*progress*progress+0.1, 0), 1)
        self.playermodel:SetAlpha(pmp)--progress*0.8)
        self:SetAlpha(progress ~= 0 and 0.9 or 0)
        self.bgmodel:SetAlpha(progress)

    else
        if progress == 0 then
            self:SetAlpha(0)
        else
            self:SetAlpha(1)
        end
        self:SetValue(progress)
    end
end



function NugComboBar:UpdateSingleRune(point, index, start, duration, runeReady)
    self:EnsureRuneChargeFrame(point)
	if runeReady then
        point:Activate(self.db.profile.animationLevel)
        point.RuneChargeFrame:Hide()
	else
        point.runeStart = start
        point.runeDuration = duration

        point:Deactivate(self.db.profile.animationLevel)
        point.RuneChargeFrame:SetScript("OnUpdate", RuneChargeOnUpdate)
        point.RuneChargeFrame:Show()
	end
end


local runeSortFunc = function(a,b)
    if a[3] and not b[3] then -- if a.isReady and not b.isReady then
        return true
    elseif not a[3] and not b[3] then -- elseif not a.isReady and not b.isReady then
        return a[1] < b[1]
    end
end
function NugComboBar:UpdateRunes(index, isEnergize)
        if not self.runeTable then
            self.runeTable = {
                {0, 1, false}, --start, duration, ready
                {0, 1, false},
                {0, 1, false},
                {0, 1, false},
                {0, 1, false},
                {0, 1, false},
            }
        end
        local runeTable = self.runeTable
        for i=1, 6 do
            local r = runeTable[i]
            r[1], r[2], r[3] = GetRuneCooldown(i);
            if not r[1] then return end
        end
        tsort(runeTable, runeSortFunc)

        -- print("------")
        for i=1, 6 do
            local start, duration, isReady = unpack(runeTable[i])
            local point = self.p[i]
            -- print(i, start, duration, isReady)
            self:UpdateSingleRune(point, i, start, duration, isReady)
        end
end



function NugComboBar:EnsureRuneChargeFrame(point)

    if point.RuneChargeFrame then
        local existingRuneFrameIsPretty = point.RuneChargeFrame.SetPreset ~= nil
        if enablePrettyRunes ~= existingRuneFrameIsPretty then
            point.RuneChargeFrame:Hide()
            point.RuneChargeFrame = enablePrettyRunes and point._RuneChargeFramePretty or point._RuneChargeFrameNormal
        end
    end

    if not point.RuneChargeFrame then

        local f
        if enablePrettyRunes then
            local t = point.bg
            local ts = t.settings
            f = self:Create3DPoint(point.id.."rcf", ts)

            if NugComboBar.db.global.vertical then
                f:SetPoint("CENTER", t, "BOTTOMLEFT", -ts.poffset_y, ts.poffset_x)
            else
                f:SetPoint("CENTER", t, "TOPLEFT", ts.poffset_x, ts.poffset_y)
            end
            f.bg = t
            f:SetPreset("_RuneCharger2")

            point._RuneChargeFramePretty = f

            f.bgmodel:SetFrameLevel(0)
        else

            f = self:CreatePixelBar()
            f:SetWidth(pixelperfect(18))
            f:SetColor(unpack(NugComboBar.db.profile.colors.bar1))
            f:SetMinMaxValues(0,1)
            f:ClearAllPoints()
            f:SetPoint("TOP", point, "CENTER", 0, -16)

            point._RuneChargeFrameNormal = f
        end

        f.frame = point
        point.RuneChargeFrame = f
    end

    if not enablePrettyRunes then
        point._RuneChargeFrameNormal:ClearAllPoints()
        if NugComboBar.db.profile.cooldownOnTop then
            point._RuneChargeFrameNormal:SetPoint("BOTTOM", point, "TOP", 0,-17)
        else
            point._RuneChargeFrameNormal:SetPoint("TOP", point, "BOTTOM", 0,17)
        end
    end
end


function NugComboBar.NAME_PLATE_UNIT_ADDED(self, event, unit)
    if self.db.profile.nameplateAttachTarget then
        if UnitIsUnit(unit, "target") then
            self:PLAYER_TARGET_CHANGED()
        end
    end

    if self.db.profile.nameplateAttach then
        if UnitIsUnit(unit, "player") then
            local frame = GetNamePlateForUnit(unit)
            self:ClearAllPoints()
            self:SetPoint("TOP", frame, "BOTTOM", self.db.profile.nameplateOffsetX, self.db.profile.nameplateOffsetY)
        end
    end
end

function NugComboBar.NAME_PLATE_UNIT_REMOVED(self, event, unit)
    if self.db.profile.nameplateAttachTarget then
        if UnitIsUnit(unit, "target") then
            self:Hide()
        end
    end

    if self.db.profile.nameplateAttach then
        if UnitIsUnit(unit, "player") then
            local frame = GetNamePlateForUnit(unit)
            self:ClearAllPoints()
            self:SetPoint("TOP", UIParent, "BOTTOM", 0,-500)
        end
    end
end


function NugComboBar:RegisterConfig(name, config, class, specIndex)
    config.class = class
    config.specIndex = specIndex
    configs[name] = config
end

function NugComboBar:GetAvailableConfigsForSpec(specIndex)
    local _, class = UnitClass("player")
    local avConfigs = {}
    for name, config in pairs(configs) do
        if config.class == class and (config.specIndex == specIndex or config.specIndex == nil) then
            avConfigs[name] = name
        end
    end
    avConfigs["Disabled"] = "Disabled"
    return avConfigs
end

function NugComboBar:IsTriggerStateEqual(state1, state2)
    if #state1 ~= #state2 then return false end
    for i,v in ipairs(state1) do
        if state2[i] ~= v then return false end
    end
    return true
end

function NugComboBar:GetTriggerState(config)
    if not config.triggers then return {} end
    local state = {}
    for i, func in ipairs(config.triggers) do
        table.insert(state, func())
    end
    return state
end

function NugComboBar:ResetConfig()
    table.wipe(self.flags)
    self.eventProxy:UnregisterAllEvents()
    self.eventProxy:SetScript("OnUpdate", nil)
    self:DisableBar()
end

function NugComboBar:SelectConfig(name)
    self:ResetConfig()
    self:ApplyConfig(name)
    currentConfigName = name
    local newConfig = configs[name]
    currentTriggerState = self:GetTriggerState(newConfig)
end

function NugComboBar:ApplyConfig(name)
    local config = configs[name]
    local spec = GetSpecialization()
    config.setup(self, spec)
end

function NugComboBar:SetDefaultValue(value)
    defaultValue = value
end

function NugComboBar:SetSourceUnit(unit)
    allowedUnit = unit
end

function NugComboBar:SetTargetUnit(unit)
    allowedTargetUnit = unit
end

function NugComboBar:SetPointGetter(func)
    GetComboPoints = func
end



do
    local IsClean = function(db)
        local ignoredProperies = {
            specspec = true,
            charspec = true,
        }
        local propeties = 0
        for k,v in pairs(db) do
            if not ignoredProperies[k] then
                propeties = propeties + 1
            end
        end
        return propeties == 0
    end
    local CURRENT_DB_VERSION = 2
    function NugComboBar:DoMigrations(db)
        if IsClean(db) or db.DB_VERSION == CURRENT_DB_VERSION then -- skip if db is empty or current
            db.DB_VERSION = CURRENT_DB_VERSION
            return
        end

        if db.DB_VERSION == nil then
            -- if non-default preset selected
            if db.preset3d or db.preset3dpointbar2 then
                db.enable3d = true -- keep 3d mode
            else
                -- otherwise switching to 2d mode with new default colors
                print("[NugComboBar] Updated 2D mode is the new default. Migrating your settings...")
                db.enable3d = false
                if db.colors then
                    for i,c in ipairs(db.colors) do
                        db.colors[i] = {1, 0.33, 0.74}
                    end
                end
            end

            db.DB_VERSION = 1
        end

        if db.DB_VERSION == 1 then
            print('|cffff99bb[NugComboBar]|r === 8.3.3 Update Changes ===')
            print(' -- New texture that scales up much bettar. New default scale is 1.3')
            print(' -- Profiles that can be assigned to each individual spec. This replaces the old system and some per-character settings may be lost.')
            print(' -- Some specs now have an option to pick from several available things to track.')

            db.global = {}
            db.global.enable3d = db.enable3d
            db.global.disableBlizz = db.disableBlizz
            db.global.disableBlizzNP = db.disableBlizzNP
            db.global.enablePrettyRunes = db.enablePrettyRunes
            db.global.vertical = db.vertical

            db.profiles = {
                Default = {}
            }
            local default_profile = db.profiles["Default"]
            local CopyProfile = function(old, new)
                new.apoint = old.apoint
                new.parent = old.parent
                new.point = old.point
                new.x = old.x
                new.y = old.y
                new.anchorpoint = old.anchorpoint
                new.frameparent = old.frameparent
                new.scale = old.scale
                new.showEmpty = old.showEmpty
                new.hideSlowly = old.hideSlowly
                new.colors = old.colors
                new.glowIntensity = old.glowIntensity
                new.preset3d = old.preset3d
                new.preset3dlayer2 = old.preset3dlayer2
                new.preset3dpointbar2 = old.preset3dpointbar2
                new.bar2_x = old.bar2_x
                new.bar2_y = old.bar2_y
                new.classThemes = old.classThemes
                new.colors3d = old.colors3d
                new.showAlways = old.showAlways
                new.onlyCombat = old.onlyCombat
                new.disableProgress = old.disableProgress
                new.cooldownOnTop = old.cooldownOnTop
                new.chargeCooldown = old.chargeCooldown
                new.alpha = old.alpha
                new.nameplateAttach = old.nameplateAttach
                new.nameplateAttachTarget = old.nameplateAttachTarget
                new.nameplateOffsetX = old.nameplateOffsetX
                new.nameplateOffsetY = old.nameplateOffsetY
                new.hideWithoutTarget = old.hideWithoutTarget
                -- new.vertical = old.vertical
                new.overrideLayout = old.overrideLayout
                new.soundChannel = old.soundChannel
                new.soundNameFull = old.soundNameFull
                new.soundNameFullCustom = old.soundNameFullCustom
                -- -- new.disabled = old.disabled

                old.enable3d = nil
                old.disableBlizz = nil
                old.disableBlizzNP = nil
                old.enablePrettyRunes = nil
                old.vertical = nil

                old.apoint = nil
                old.parent = nil
                old.point = nil
                old.x = nil
                old.y = nil
                old.anchoropint = nil
                old.frameparent = nil
                old.scale = nil
                old.showEmpty = nil
                old.hideSlowly = nil
                old.colors = nil
                old.glowIntensity = nil
                old.preset3d = nil
                old.preset3dlayer2 = nil
                old.preset3dpointbar2 = nil
                old.bar2_x = nil
                old.bar2_y = nil
                old.classThemes = nil
                old.colors3d = nil
                old.showAlways = nil
                old.onlyCombat = nil
                old.disableProgress = nil
                old.cooldownOnTop = nil
                old.chargeCooldown = nil
                old.alpha = nil
                old.nameplateAttach = nil
                old.nameplateAttachTarget = nil
                old.nameplateOffsetX = nil
                old.nameplateOffsetY = nil
                old.hideWithoutTarget = nil
                old.vertical = nil
                old.overrideLayout = nil
                old.soundChannel = nil
                old.soundNameFull = nil
                old.soundNameFullCustom = nil
                old.disabled = nil
            end

            CopyProfile(db, default_profile)
            if NugComboBarDB_Character.charspec and NugComboBarDB_Character.DB_VERSION == 1 then
                local pKey = UnitName("player").." - "..GetRealmName()
                db.profiles[pKey] = {}
                CopyProfile(NugComboBarDB_Character, db.profiles[pKey])
                NugComboBarDB_Character.charspec = nil
            end

            db.DB_VERSION = 2
        end
    end
end


function NugComboBar.rgb2hsv (r, g, b)
    local rabs, gabs, babs, rr, gg, bb, h, s, v, diff, diffc, percentRoundFn
    rabs = r
    gabs = g
    babs = b
    v = math.max(rabs, gabs, babs)
    diff = v - math.min(rabs, gabs, babs);
    diffc = function(c) return (v - c) / 6 / diff + 1 / 2 end
    -- percentRoundFn = function(num) return math.floor(num * 100) / 100 end
    if (diff == 0) then
        h = 0
        s = 0
    else
        s = diff / v;
        rr = diffc(rabs);
        gg = diffc(gabs);
        bb = diffc(babs);

        if (rabs == v) then
            h = bb - gg;
        elseif (gabs == v) then
            h = (1 / 3) + rr - bb;
        elseif (babs == v) then
            h = (2 / 3) + gg - rr;
        end
        if (h < 0) then
            h = h + 1;
        elseif (h > 1) then
            h = h - 1;
        end
    end
    return h, s, v
end

function NugComboBar.hsv2rgb(h,s,v)
    local r,g,b
    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);
    local rem = i % 6
    if rem == 0 then
        r = v; g = t; b = p;
    elseif rem == 1 then
        r = q; g = v; b = p;
    elseif rem == 2 then
        r = p; g = v; b = t;
    elseif rem == 3 then
        r = p; g = q; b = v;
    elseif rem == 4 then
        r = t; g = p; b = v;
    elseif rem == 5 then
        r = v; g = p; b = q;
    end

    return r,g,b
end
