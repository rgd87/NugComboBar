NugComboBar = CreateFrame("Frame",nil, UIParent)

local user
NugComboBarDB = {}

local OriginalGetComboPoints = GetComboPoints
local GetComboPoints = OriginalGetComboPoints
local allowedUnit = "player"
local allowedCaster = "player"
local showEmpty
local hideSlowly

NugComboBar:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

NugComboBar:RegisterEvent("ADDON_LOADED")

local scanAura
local filter = "HELPFUL"
local GetAuraStack = function(unit)
    if not scanAura then return 0 end
    local name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitAura(allowedUnit, scanAura, nil, filter)
    if allowedCaster and caster ~= allowedCaster then count = 0 end
    return (count or 0)
end

local GetShards = function(unit)
    return UnitPower(unit, SPELL_POWER_SOUL_SHARDS)
end
local GetBurningEmbers = function(unit)
    local maxPower = UnitPowerMax("player", SPELL_POWER_BURNING_EMBERS, true)
    local power = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true)
    local numEmbers = floor(power / MAX_POWER_PER_EMBER)
    local progress = math.fmod(power, MAX_POWER_PER_EMBER)
    return numEmbers, progress
end
local GetChi = function(unit)
    return UnitPower(unit, SPELL_POWER_LIGHT_FORCE)
end
local GetHolyPower = function(unit)
    return UnitPower(unit, SPELL_POWER_HOLY_POWER)
end
local GetShadowOrbs = function(unit)
    return UnitPower(unit, SPELL_POWER_SHADOW_ORBS)
end

function NugComboBar:LoadClassSettings()
        local class = select(2,UnitClass("player"))
        self.MAX_POINTS = nil
        if class == "ROGUE" then
            self:SetMaxPoints(5)
            self:RegisterEvent("UNIT_COMBO_POINTS")
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            local GetComboPoints = OriginalGetComboPoints
        elseif class == "DRUID" then
            self:RegisterEvent("PLAYER_TARGET_CHANGED") -- required for both
            local cat = function()
                self:UnregisterEvent("UNIT_AURA")
                self:SetMaxPoints(5)
                self:RegisterEvent("UNIT_COMBO_POINTS")
                GetComboPoints = OriginalGetComboPoints
                allowedUnit = "player"
                self:UNIT_COMBO_POINTS(nil,allowedUnit)
            end
            local bear = function()
                self:UnregisterEvent("UNIT_COMBO_POINTS")
                self:SetMaxPoints(3)
                self:RegisterEvent("UNIT_AURA")
                self.UNIT_AURA = self.UNIT_COMBO_POINTS
                scanAura = GetSpellInfo(33745) -- Lacerate
                filter = "HARMFUL"
                allowedUnit = "target"
                allowedCaster = "player"
                GetComboPoints = GetAuraStack
                self:UNIT_AURA(nil,allowedUnit)
            end
            self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
            self.UPDATE_SHAPESHIFT_FORM = function(self)
                if GetShapeshiftFormID() == BEAR_FORM
                then bear()
                else cat()
                end
            end
            self:UPDATE_SHAPESHIFT_FORM()
        elseif class == "PALADIN" then
            self:SetMaxPoints(5, "PALADIN")
            self:RegisterEvent("UNIT_POWER")
            self.UNIT_POWER = function(self,event,unit,ptype)
                if ptype ~= "HOLY_POWER" or unit ~= "player" then return end
                self.UNIT_COMBO_POINTS(self,event,unit,ptype)
            end
            GetComboPoints = GetHolyPower
        elseif class == "MONK" then
            self:SetMaxPoints(4)
            self:RegisterEvent("UNIT_POWER")
            self.UNIT_POWER = function(self,event,unit,ptype)
                if ptype ~= "LIGHT_FORCE" or ptype == "DARK_FORCE" or unit ~= "player" then return end
                self.UNIT_COMBO_POINTS(self,event,unit,ptype)
            end
            GetComboPoints = GetChi
            self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
            self:RegisterEvent("PLAYER_TALENT_UPDATE")
            self.ACTIVE_TALENT_GROUP_CHANGED = function(self, event)
                if IsSpellKnown(115396)  -- Ascension
                    then self:SetMaxPoints(5)
                    else self:SetMaxPoints(4)
                end
                self:UNIT_COMBO_POINTS(nil,"player")
            end
            self.PLAYER_TALENT_UPDATE = self.ACTIVE_TALENT_GROUP_CHANGED
            self:ACTIVE_TALENT_GROUP_CHANGED()
        elseif class == "SHAMAN" then
            self:SetMaxPoints(5)
            self:RegisterEvent("UNIT_AURA")
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            scanAura = GetSpellInfo(53817) -- Maelstrom Weapon
            allowedUnit = "player"
            local LShield = GetSpellInfo(324) -- Lightning Shield
            local GetLightningShield = function(unit)
                local _,_,_, count, _,_,_, caster = UnitAura("player", LShield, nil, "HELPFUL")
                return (count and count - 4 or 0)
            end
            self.ACTIVE_TALENT_GROUP_CHANGED = function(self)
                if IsSpellKnown(51490) -- Thunderstorm
                then GetComboPoints = GetLightningShield
                else GetComboPoints = GetAuraStack
                end
                self:UNIT_AURA(nil,allowedUnit)
            end
            self:ACTIVE_TALENT_GROUP_CHANGED()
        elseif class == "WARLOCK" then
            self:SetMaxPoints(3)
            self:RegisterEvent("UNIT_POWER")
            self.UNIT_POWER = function(self,event,unit,ptype)
                if unit ~= "player" then return end
                if ptype == "SOUL_SHARDS" or ptype == "BURNING_EMBERS" then
                    self.UNIT_COMBO_POINTS(self,event,unit,ptype)
                end
            end
            GetComboPoints = GetShards
            showEmpty = true
            self:RegisterEvent("GLYPH_UPDATED")
            self:RegisterEvent("GLYPH_ADDED")
            self:RegisterEvent("GLYPH_REMOVED")
            self:RegisterEvent("SPELLS_CHANGED")
            self.SPELLS_CHANGED = function(self, event)
                local spec = GetSpecialization()
                if      spec == SPEC_WARLOCK_DESTRUCTION then
                    self:EnableBar(0,10)
                    self:SetMaxPoints(3)
                    GetComboPoints = GetBurningEmbers
                    self:UNIT_POWER(nil,allowedUnit, "BURNING_EMBERS")
                elseif  spec == SPEC_WARLOCK_AFFLICTION and IsPlayerSpell(WARLOCK_SOULBURN) then
                    self:DisableBar()
                    local maxshards = UnitPowerMax( "player", SPELL_POWER_SOUL_SHARDS )
                    self:SetMaxPoints(maxshards)
                    GetComboPoints = GetShards
                    self:UNIT_POWER(nil,allowedUnit, "SOUL_SHARDS" )
                end
            end
            self.GLYPH_UPDATED = self.SPELLS_CHANGED
            self.GLYPH_ADDED = self.GLYPH_UPDATED
            self.GLYPH_REMOVED = self.GLYPH_UPDATED
            self:SPELLS_CHANGED()
        --elseif class == "WARRIOR" then     -- example of how to add harmful stacking spell display for target
        --    self:SetMaxPoints(3)
        --    self:RegisterEvent("UNIT_AURA")
        --    self:RegisterEvent("PLAYER_TARGET_CHANGED")
        --    self.UNIT_AURA = self.UNIT_COMBO_POINTS
        --    scanAura = GetSpellInfo(7386) -- Sunder Armor
        --    filter = "HARMFUL"
        --    allowedUnit = "target"
        --    allowedCaster = nil
        --    GetComboPoints = GetAuraStack
        elseif class == "HUNTER" then
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            GetComboPoints = GetAuraStack
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
            self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
            self.ACTIVE_TALENT_GROUP_CHANGED = function(self)
                if IsSpellKnown(19434) then return mm() end -- Aimed Shot
                if IsSpellKnown(19577) then return bm() end -- Intimidation
                self:UnregisterEvent("UNIT_AURA")
            end
            self:ACTIVE_TALENT_GROUP_CHANGED()
        elseif class == "DEATHKNIGHT" then
            self:SetMaxPoints(5)
            self:RegisterEvent("UNIT_AURA")
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            scanAura = GetSpellInfo(91342) -- Shadow Infusion
            filter = "HELPFUL"
            allowedUnit = "pet"
            allowedCaster = "player"
            GetComboPoints = GetAuraStack
        elseif class == "PRIEST" then
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
    point = "CENTER",
    x = 0, y = 0,
    anchorpoint = "LEFT",
    scale = 1.0,
    showEmpty = false,
    hideSlowly = true,
    disableBlizz = false,
    colors = {
        {0.77,0.26,0.29},
        {0.77,0.26,0.29},
        {0.77,0.26,0.29},
        {0.77,0.26,0.29},
        {0.77,0.26,0.29},
        {0.77,0.26,0.29},
    },
    enable3d = true,
    preset3d = "glow_funnelPurple",
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


function NugComboBar.ADDON_LOADED(self,event,arg1, forced)
    if arg1 == "NugComboBar" then
        SLASH_NCBSLASH1 = "/ncb";
        SLASH_NCBSLASH2 = "/nugcombobar";
        SLASH_NCBSLASH3 = "/NugComboBar";
        SlashCmdList["NCBSLASH"] = NugComboBar.SlashCmd
        
        NugComboBarDB_Global = NugComboBarDB_Global or {}
        NugComboBarDB_Character = NugComboBarDB_Character or {}
        local _,class = UnitClass("player")
        NugComboBarDB_Global.disabled = NugComboBarDB_Global.disabled or {}
        if NugComboBarDB_Global.disabled[class] then return end
        NugComboBarDB_Global.charspec = NugComboBarDB_Global.charspec or {}
        user = UnitName("player").."@"..GetRealmName()

        if NugComboBarDB_Global.charspec[user] then
            NugComboBarDB = NugComboBarDB_Character
        else
            NugComboBarDB = NugComboBarDB_Global
        end

        SetupDefaults(NugComboBarDB, defaults)

        self:RegisterEvent("PLAYER_LOGIN")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self.PLAYER_ENTERING_WORLD = self.PLAYER_TARGET_CHANGED -- Update on looading screen to clear after battlegrounds
        
--~         self:RegisterEvent("UPDATE_STEALTH")
--~         self:RegisterEvent("PLAYER_REGEN_ENABLED")
--~         self:RegisterEvent("PLAYER_REGEN_DISABLED")
--~         self:RegisterEvent("UNIT_DISPLAYPOWER")
--~         self.UNIT_DISPLAYPOWER = self.UPDATE_STEALTH
--~         self.PLAYER_REGEN_ENABLED = self.UPDATE_STEALTH
--~         self.PLAYER_REGEN_DISABLED = self.UPDATE_STEALTH
    end
end
function NugComboBar.PLAYER_LOGIN(self, event, forced)
    if not forced then self:Create() end
    self:LoadClassSettings()
    if showEmpty == nil then showEmpty = NugComboBarDB.showEmpty end;
    if hideSlowly == nil then hideSlowly = NugComboBarDB.hideSlowly end;
    self:SetAlpha(0)
    self:SetScale(NugComboBarDB.scale)
    if not forced then
        self:CreateAnchor()
    else
        self.anchor:ClearAllPoints()
        self.anchor:SetPoint(NugComboBarDB.point,UIParent,NugComboBarDB.point,NugComboBarDB.x,NugComboBarDB.y)
    end

    NugComboBar.toggleBlizz()

    --self:AttachAnimationGroup()
    self:UNIT_COMBO_POINTS("INIT","player")
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
local HideTimer = function(self, time)
    self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
    if self.OnUpdateCounter < 4 then return end

    local a = 5 - self.OnUpdateCounter
    self:SetAlpha(a)
    if self.OnUpdateCounter >= 5 then
        self:SetScript("OnUpdate",nil)
        self:SetAlpha(0)
        self.Hiding = false
        self.OnUpdateCounter = 0
    end
end


function NugComboBar.PLAYER_TARGET_CHANGED(self, event)
    self:UNIT_COMBO_POINTS(event, allowedUnit)
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

function NugComboBar.EnableBar(self, min, max)
    if not self.bar then return end
    if min and max then self.bar:SetMinMaxValues(min, max) end
    self.bar:Show()
end

function NugComboBar.DisableBar(self)
    if not self.bar then return end
    self.bar:Hide()
end


local comboPointsBefore = 0
function NugComboBar.UNIT_COMBO_POINTS(self, event, unit, ptype)
    if unit ~= allowedUnit then return end     
    local comboPoints, barProgress = GetComboPoints(unit);
    if barProgress and self.bar then
        self.bar:SetValue(barProgress)
    end


    for i = 1,self.MAX_POINTS do
        if i <= comboPoints then
            self.p[i]:Activate()
        end
        if i > comboPoints then
            self.p[i]:Deactivate()
        end
    end
    
    if comboPoints == 0 and not showEmpty then
        if comboPointsBefore ~= 0 and hideSlowly then
            self:SetScript("OnUpdate", HideTimer)
            self.Hiding = true
            -- if not self.HideAnim:IsPlaying() then self.HideAnim:Play() end
        else
            if not self.Hiding then self:SetAlpha(0) end
        end
    else
        if hideSlowly then
            self:SetScript("OnUpdate", nil)
            self.Hiding = false
        end
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
    --if point == 6 and NugComboBar.allowBGColor then
    --    NugComboBar.bg:SetVertexColor(r,g,b)
    --else
    --local offset = NugComboBar.MAX_POINTS - 5
    NugComboBar.p[point]:SetColor(r,g,b)
    --end
end

--~ function NugComboBar.AttachAnimationGroup(self)
--~     local ag = self:CreateAnimationGroup()
--~     local a1 = ag:CreateAnimation("Rotation")
--~     a1:SetDegrees(90)
--~     a1:SetDuration(0.1)
--~     a1:SetOrder(1)
--~     a1.ag = ag
--~     a1:SetScript("OnFinished",function(self)
--~         self.ag:Pause();
--~     end)
--~     self.rag = ag
--~     ag:Play()
--~ end

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
    
    self:SetPoint(NugComboBarDB.point,UIParent,NugComboBarDB.point,NugComboBarDB.x,NugComboBarDB.y)
    local p1 = NugComboBarDB.anchorpoint
    local p2 = (p1 == "LEFT") and "RIGHT" or "LEFT"
    frame:SetPoint("TOP"..p1,self,"TOP"..p2,0,0)
    
    
    self:EnableMouse(true)
    self:RegisterForDrag("LeftButton")
    self:SetMovable(true)
    self:SetScript("OnDragStart",function(self) self:StartMoving() end)
    self:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing();
        _,_, NugComboBarDB.point, NugComboBarDB.x, NugComboBarDB.y = self:GetPoint(1)
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
        if ap ~= "RIGHT" and ap ~="LEFT" then print ("Current anchor point is: "..NugComboBarDB.anchorpoint); return end
        NugComboBarDB.anchorpoint = ap
        local p1 = NugComboBarDB.anchorpoint
        local p2 = (p1 == "LEFT") and "RIGHT" or "LEFT"
        NugComboBar:ClearAllPoints()
        NugComboBar:SetPoint("TOP"..p1,NugComboBar.anchor,"TOP"..p2,0,0)
    end,
    ["showempty"] = function(v)
        NugComboBarDB.showEmpty = not NugComboBarDB.showEmpty
        showEmpty = NugComboBarDB.showEmpty
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
        NugComboBarDB_Global.disabled[select(2,UnitClass("player"))] = true
        print ("NCB> Disabled for current class. Changes will take effect after /reload")
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
        if NugComboBarDB_Global.charspec[user] then NugComboBarDB_Global.charspec[user] = nil
        else NugComboBarDB_Global.charspec[user] = true
        end
--~         ReloadUI()
        NugComboBar:ADDON_LOADED(nil, "NugComboBar")
        NugComboBar:PLAYER_LOGIN(nil, true)
        NugComboBar:PLAYER_ENTERING_WORLD(nil)
        if NugComboBar.anchor:IsVisible() then
            NugComboBar.Commands.unlock()
        end
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
        InterfaceOptionsFrame_OpenToCategory("NugComboBar")
    end
}

function NugComboBar.SlashCmd(msg)
    k,v = string.match(msg, "([%w%+%-%=]+) ?(.*)")
    if not k or k == "help" then 
        if NugComboBarDB_Global.disabled[select(2,UnitClass("player"))] then
            print("|cffffaaaaNCB is disabled for this class!|r")
        end
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

