NugComboBar = CreateFrame("Frame",nil, UIParent)

local user
NugComboBarDB = {}

--default rogue setup
NugComboBar.MAX_POINTS = 5
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

local GetHolyPower = function(unit)
    return UnitPower(unit, SPELL_POWER_HOLY_POWER)
end

function NugComboBar:LoadClassSettings()
        local class = select(2,UnitClass("player"))
        if class == "ROGUE" then
            self:RegisterEvent("UNIT_COMBO_POINTS")
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            local GetComboPoints = OriginalGetComboPoints
        elseif class == "DRUID" then
            self:RegisterEvent("PLAYER_TARGET_CHANGED") -- required for both
            local cat = function()
                self:UnregisterEvent("UNIT_AURA")
                self:ConvertTo5()
                self:RegisterEvent("UNIT_COMBO_POINTS")
                GetComboPoints = OriginalGetComboPoints
                allowedUnit = "player"
                self:UNIT_COMBO_POINTS(nil,allowedUnit)
            end
            local bear = function()
                self:UnregisterEvent("UNIT_COMBO_POINTS")
                self:ConvertTo3()
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
            self:ConvertTo3()
            self:RegisterEvent("UNIT_POWER")
            self.UNIT_POWER = function(self,event,unit,ptype)
                if ptype ~= "HOLY_POWER" or unit ~= "player" then return end
                self.UNIT_COMBO_POINTS(self,event,unit,ptype)
            end
            GetComboPoints = GetHolyPower
        elseif class == "SHAMAN" then
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
            self:ConvertTo3()
            self:RegisterEvent("UNIT_POWER")
            self.UNIT_POWER = function(self,event,unit,ptype)
                if ptype ~= "SOUL_SHARDS" or unit ~= "player" then return end
                self.UNIT_COMBO_POINTS(self,event,unit,ptype)
            end
            GetComboPoints = GetShards
            showEmpty = true
        --elseif class == "WARRIOR" then     -- example of how to add harmful stacking spell display for target
        --    self:ConvertTo3()
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
                self:RegisterEvent("UNIT_AURA")
                scanAura = GetSpellInfo(82925) -- Ready, Set, Aim...
                allowedUnit = "player"
                allowedCaster = "player"
                GetComboPoints = function (unit)
                    if not scanAura then return 0 end
                    if UnitAura(allowedUnit, GetSpellInfo(82926), nil, filter) then return 5 end -- Fire! proc buff
                    local name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitAura(allowedUnit, scanAura, nil, filter)
                    if allowedCaster and caster ~= allowedCaster then count = 0 end
                    return (count or 0)
                end
            end
            local bm = function()
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
            self:RegisterEvent("UNIT_AURA")
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            scanAura = GetSpellInfo(91342) -- Shadow Infusion
            filter = "HELPFUL"
            allowedUnit = "pet"
            allowedCaster = "player"
            GetComboPoints = GetAuraStack
        elseif class == "PRIEST" then
            self:RegisterEvent("UNIT_AURA")
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            allowedUnit = "player"
            GetComboPoints = GetAuraStack
            local shadow_orbs = function()
                self:ConvertTo3()
                scanAura = GetSpellInfo(77487) -- Shadow Orbs
            end
            local evangelism = function()
                self:ConvertTo5()
                scanAura = GetSpellInfo(81661) -- Evangelism
            end
            self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
            self.ACTIVE_TALENT_GROUP_CHANGED = function(self)
                if IsSpellKnown(15407) -- MF
                then shadow_orbs()
                else evangelism()
                end
            end
            self:ACTIVE_TALENT_GROUP_CHANGED()
        -- elseif class == "MAGE" then 
        --      self:RegisterEvent("UNIT_AURA") 
        --      self.UNIT_AURA = self.UNIT_COMBO_POINTS 
        --      scanAura = GetSpellInfo(36032) -- Arcane Blast Buff 
        --      filter = "HARMFUL" 
        --      allowedUnit = "player" 
        --      GetComboPoints = GetAuraStack
        else
            return
        end
end

function NugComboBar.ADDON_LOADED(self,event,arg1)
    if arg1 == "NugComboBar" then
        SLASH_NCBSLASH1 = "/ncb";
        SLASH_NCBSLASH2 = "/nugcombobar";
        SlashCmdList["NCBSLASH"] = NugComboBar.SlashCmd
        
        NugComboBarDB_Global = NugComboBarDB_Global or {}
        NugComboBarDB_Character = NugComboBarDB_Character or {}
        local _,class = UnitClass("player")
        NugComboBarDB_Global.disabled = NugComboBarDB_Global.disabled or {}
        if NugComboBarDB_Global.disabled[class] then return end
        NugComboBarDB_Global.charspec = NugComboBarDB_Global.charspec or {}
        user = UnitName("player").."@"..GetRealmName()
        if NugComboBarDB_Global.charspec[user] then
        setmetatable(NugComboBarDB,{
            __index = function(t,k) return NugComboBarDB_Character[k] end,
            __newindex = function(t,k,v) rawset(NugComboBarDB_Character,k,v) end
        })
        else
        setmetatable(NugComboBarDB,{
            __index = function(t,k) return NugComboBarDB_Global[k] end,
            __newindex =function(t,k,v) rawset(NugComboBarDB_Global,k,v) end
            })
        end
        
        NugComboBarDB.point = NugComboBarDB.point or "CENTER"
        NugComboBarDB.x = NugComboBarDB.x or 0
        NugComboBarDB.y = NugComboBarDB.y or 0
        NugComboBarDB.anchorpoint = NugComboBarDB.anchorpoint or "LEFT"
        NugComboBarDB.scale = NugComboBarDB.scale or 1
        if NugComboBarDB.animation == nil then NugComboBarDB.animation = false end
        if NugComboBarDB.showEmpty == nil then NugComboBarDB.showEmpty = false end
        if NugComboBarDB.hideSlowly == nil then NugComboBarDB.hideSlowly = true end
        if NugComboBarDB.disableBlizz == nil then NugComboBarDB.disableBlizz = false end
        NugComboBarDB.colors = NugComboBarDB.colors or { {0.6,0,0.96},{0.6,0,0.96},{0.6,0,0.96},{0.6,0,0.96},{0.79,0,0.96} }
        --NugComboBarDB.colors[6] = NugComboBarDB.colors[6] or {0.96,0.30,0.32}

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
function NugComboBar.PLAYER_LOGIN(self, event)
    self:Create()
    self:LoadClassSettings()
    if showEmpty == nil then showEmpty = NugComboBarDB.showEmpty end;
    if hideSlowly == nil then hideSlowly = NugComboBarDB.hideSlowly end;
    self:SetAlpha(0)
    self:SetScale(NugComboBarDB.scale)
    self:CreateAnchor()

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
-- end
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

local comboPointsBefore = 0
function NugComboBar.UNIT_COMBO_POINTS(self, event, unit, ptype)
    if unit ~= allowedUnit then return end
    local comboPoints = GetComboPoints(unit);
    
    for i = 1,#self.p do
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
end

function NugComboBar.SetColor(point, r, g, b)
    NugComboBarDB.colors[point] = {r,g,b}
    --if point == 6 and NugComboBar.allowBGColor then
    --    NugComboBar.bg:SetVertexColor(r,g,b)
    --else
    local offset = NugComboBar.MAX_POINTS - 5
    NugComboBar.p[point+offset]:SetColor(r,g,b)
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
            for i=1,5 do
                NugComboBar.SetColor(i,r,g,b)
            end
        else
            NugComboBar.SetColor(color,r,g,b)
        end
    end
    ColorPickerFrame.cancelFunc = ColorPickerFrame.func
    ColorPickerFrame:Show()
end

function NugComboBar.SlashCmd(msg)
    local NCBString = "|cffff7777NCB: |r"
    k,v = string.match(msg, "([%w%+%-%=]+) ?(.*)")
    if not k or k == "help" then 
    if NugComboBarDB_Global.disabled[select(2,UnitClass("player"))] then
        print("|cffffaaaaNCB is disabled for this class!|r")
    end
    print([[Usage:
      |cff55ff55/ncb charspec|r
      |cff55ff55/ncb lock|r
      |cff55ff55/ncb unlock|r
      |cff55ff55/ncb scale|r <0.3 - 2.0>
      |cff55ff55/ncb changecolor|r <1-5, 0 = all> (in 3pt mode use 3-5)
      |cff55ff55/ncb anchorpoint|r <left | right>
      |cff55ff55/ncb showempty|r
      |cff55ff55/ncb hideslowly|r
      |cff55ff55/ncb toggleblizz|r
      |cff55ff55/ncb disable|enable|r (for current class)
      |cff55ff55/ncb reset|r]]
    )end
    if k == "unlock" then
        NugComboBar.anchor:Show()
        NugComboBar:SetAlpha(1)
        for i=1,#NugComboBar.p do
            NugComboBar.p[i]:Activate()
        end
    end
    if k == "lock" then
        NugComboBar.anchor:Hide()
        NugComboBar:UNIT_COMBO_POINTS(nil, allowedUnit)
    end
    if k == "reset" then
        NugComboBar.anchor:ClearAllPoints()
        NugComboBar.anchor:SetPoint("CENTER",UIParent,"CENTER",0,0)
    end
    if k == "anchorpoint" then
        local ap = v:upper()
        if ap ~= "RIGHT" and ap ~="LEFT" then print ("Current anchor point is: "..NugComboBarDB.anchorpoint); return end
        NugComboBarDB.anchorpoint = ap
        local p1 = NugComboBarDB.anchorpoint
        local p2 = (p1 == "LEFT") and "RIGHT" or "LEFT"
        NugComboBar:ClearAllPoints()
        NugComboBar:SetPoint("TOP"..p1,NugComboBar.anchor,"TOP"..p2,0,0)
    end
    if k == "showempty" then
        NugComboBarDB.showEmpty = not NugComboBarDB.showEmpty
        showEmpty = NugComboBarDB.showEmpty
        NugComboBar:UNIT_COMBO_POINTS("SETTINGS_CHANGED","player")
    end
    if k == "hideslowly" then
        NugComboBarDB.hideSlowly = not NugComboBarDB.hideSlowly
        hideSlowly = NugComboBarDB.hideSlowly
    end
    if k == "toggleblizz" then
        NugComboBarDB.disableBlizz = not NugComboBarDB.disableBlizz
        NugComboBar.toggleBlizz()
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
    if k == "disable" then
        NugComboBarDB_Global.disabled[select(2,UnitClass("player"))] = true
        print ("NCB> Disabled for current class. Changes will take effect after /reload")
    end
    if k == "enable" then
        NugComboBarDB_Global.disabled[select(2,UnitClass("player"))] = nil
        print ("NCB> Enabled for current class. Changes will take effect after /reload")
    end
    if k == "scale" then
        local num = tonumber(v)
        if num then 
            NugComboBarDB.scale = num; NugComboBar:SetScale(NugComboBarDB.scale);
        else print ("Current scale is: ".. NugComboBarDB.scale)
        end
    end
    if k == "changecolor" then
        local num = tonumber(v)
        if num then 
            NugComboBar:ShowColorPicker(num)
        end
    end
    if k == "charspec" then
        if NugComboBarDB_Global.charspec[user] then NugComboBarDB_Global.charspec[user] = nil
        else NugComboBarDB_Global.charspec[user] = true
        end
--~         ReloadUI()
        print (NCBString..(NugComboBarDB_Global.charspec[user] and "Enabled" or "Disabled").." character specific options for this toon. Will take effect after ui reload.",0.7,1,0.7)
    end
end


function NugComboBar.toggleBlizz()
    local class = select(2,UnitClass("player"))
    if NugComboBarDB.disableBlizz then
        if class == "ROGUE" or class == "DRUID" then
            ComboFrame:UnregisterAllEvents()
            ComboFrame:Hide()
        end
        if class == "WARLOCK" then
            ShardBarFrame:UnregisterAllEvents()
            ShardBarFrame:Hide()
            ShardBarFrame._Show = ShardBarFrame.Show
            ShardBarFrame.Show = ShardBarFrame.Hide
        end
        if class == "PALADIN" then
            PaladinPowerBar:UnregisterAllEvents()
            PaladinPowerBar:Hide()
            PaladinPowerBar._Show = PaladinPowerBar.Show
            PaladinPowerBar.Show = PaladinPowerBar.Hide
        end
    else
        if class == "ROGUE" or class == "DRUID" then
            ComboFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
            ComboFrame:RegisterEvent("UNIT_COMBO_POINTS")
            ComboFrame_Update()
        end
        if class == "WARLOCK" then
            ShardBarFrame.Show = ShardBarFrame._Show
            ShardBarFrame:Show()
            ShardBar_OnLoad(ShardBarFrame)
            ShardBar_Update()
        end
        if class == "PALADIN" then
            PaladinPowerBar.Show = PaladinPowerBar._Show
            PaladinPowerBar:Show()
            PaladinPowerBar_OnLoad(PaladinPowerBar)
            PaladinPowerBar_Update(PaladinPowerBar)
        end
    end
end