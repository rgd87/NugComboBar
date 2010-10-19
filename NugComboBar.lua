NugComboBar = CreateFrame("Frame",nil, UIParent)

local user
NugComboBarDB = {}

local MAX_POINTS = MAX_COMBO_POINTS
local GetComboPoints = GetComboPoints
local allowedUnit = "player"
local showEmpty = false


NugComboBar:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

NugComboBar:RegisterEvent("ADDON_LOADED")

local scanAura
local filter = "HELPFUL"
local GetAuraStack = function(unit)
    local name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitAura(allowedUnit, scanAura, nil, filter)
    if caster ~= "player" then count = 0 end
    return (count or 0)
end

local GetShards = function(unit)
    return UnitPower(unit, SPELL_POWER_SOUL_SHARDS)
end

local GetHolyPower = function(unit)
    return UnitPower(unit, SPELL_POWER_HOLY_POWER)
end

function NugComboBar.ADDON_LOADED(self,event,arg1)
    if arg1 == "NugComboBar" then
        local class = select(2,UnitClass("player"))
        if class == "ROGUE" or class == "DRUID" then
            self:RegisterEvent("UNIT_COMBO_POINTS")
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
        elseif class == "PALADIN" then
            MAX_POINTS = 3
            self:RegisterEvent("UNIT_POWER")
            self.UNIT_POWER = function(self,event,unit,ptype)
                if ptype ~= "HOLY_POWER" or unit ~= "player" then return end
                self.UNIT_COMBO_POINTS(self,event,unit,ptype)
            end
            GetComboPoints = GetHolyPower
        elseif class == "SHAMAN" then
            MAX_POINTS = 5
            self:RegisterEvent("UNIT_AURA")
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            scanAura = GetSpellInfo(53817) -- Maelstrom Weapon
            allowedUnit = "player"
            GetComboPoints = GetAuraStack
        elseif class == "WARLOCK" then
            MAX_POINTS = 3
            self:RegisterEvent("UNIT_POWER")
            self.UNIT_POWER = function(self,event,unit,ptype)
                if ptype ~= "SOUL_SHARDS" or unit ~= "player" then return end
                self.UNIT_COMBO_POINTS(self,event,unit,ptype)
            end
            GetComboPoints = GetShards
            showEmpty = true
        elseif class == "WARRIOR" then
            MAX_POINTS = 3
            self:RegisterEvent("UNIT_AURA")
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            scanAura = GetSpellInfo(7386) -- Evangelism
            filter = "HARMFUL"
            allowedUnit = "target"
            GetComboPoints = GetAuraStack
        elseif class == "PRIEST" then
            MAX_POINTS = 5
            self:RegisterEvent("UNIT_AURA")
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            scanAura = GetSpellInfo(81661) -- Evangelism
            allowedUnit = "player"
            GetComboPoints = GetAuraStack
            --self:RegisterEvent("PLAYER_TARGET_CHANGED")
            --scanAura = GetSpellInfo(47930) -- Grace
            --allowedUnit = "target"
        else
            return
        end
        NugComboBar.MAX_POINTS = MAX_POINTS
        
        NugComboBarDB_Global = NugComboBarDB_Global or {}
        NugComboBarDB_Character = NugComboBarDB_Character or {}
        NugComboBarDB_Global.charspec = NugComboBarDB_Global.charspec or {}
        user = UnitName("player").."@"..GetRealmName()
        if NugComboBarDB_Global.charspec[user] then
        setmetatable(NugComboBarDB,{__index = function(t,k) return NugComboBarDB_Character[k] end, __newindex = function(t,k,v) rawset(NugComboBarDB_Character,k,v) end})
        else
        setmetatable(NugComboBarDB,{__index = function(t,k) return NugComboBarDB_Global[k] end, __newindex = function(t,k,v) rawset(NugComboBarDB_Global,k,v) end})
        end
        
        NugComboBarDB.point = NugComboBarDB.point or "CENTER"
        NugComboBarDB.x = NugComboBarDB.x or 0
        NugComboBarDB.y = NugComboBarDB.y or 0
        NugComboBarDB.anchorpoint = NugComboBarDB.anchorpoint or "LEFT"
        NugComboBarDB.scale = NugComboBarDB.scale or 1
        if NugComboBarDB.animation == nil then NugComboBarDB.animation = false end
--~         if NugComboBarDB.showEmpty == nil then NugComboBarDB.showEmpty = false end
        NugComboBarDB.colors = NugComboBarDB.colors or { {0.96,0.30,0.32},{0.96,0.30,0.32},{0.96,0.30,0.32},{0.96,0.30,0.32},{0.96,0.30,0.32} }
        --NugComboBarDB.colors[6] = NugComboBarDB.colors[6] or {0.96,0.30,0.32}
        
        self:RegisterEvent("PLAYER_LOGIN")
        
--~         self:RegisterEvent("UPDATE_STEALTH")
--~         self:RegisterEvent("PLAYER_REGEN_ENABLED")
--~         self:RegisterEvent("PLAYER_REGEN_DISABLED")
--~         self:RegisterEvent("UNIT_DISPLAYPOWER")
--~         self.UNIT_DISPLAYPOWER = self.UPDATE_STEALTH
--~         self.PLAYER_REGEN_ENABLED = self.UPDATE_STEALTH
--~         self.PLAYER_REGEN_DISABLED = self.UPDATE_STEALTH
    
        SLASH_NCBSLASH1 = "/ncb";
        SLASH_NCBSLASH2 = "/nugcombobar";
        SlashCmdList["NCBSLASH"] = NugComboBar.SlashCmd
    end
end
function NugComboBar.PLAYER_LOGIN(self, event)
    self:Create()
    self:SetAlpha(0)
    self:SetScale(NugComboBarDB.scale)
    self:CreateAnchor()
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

function NugComboBar.PLAYER_TARGET_CHANGED(self, event)
    self:UNIT_COMBO_POINTS(event, allowedUnit)
end

function NugComboBar.UNIT_COMBO_POINTS(self, event, unit, ptype)
    if unit ~= allowedUnit then return end
    local comboPoints = GetComboPoints(unit);
    
    for i = 1,MAX_POINTS do
        if i <= comboPoints then
            self.p[i]:Activate()
        end
        if i > comboPoints then
            self.p[i]:Deactivate()
        end
    end
    
    if comboPoints == 0 and not showEmpty then
        self:SetAlpha(0)
    else
        self:SetAlpha(1)
    end

end

function NugComboBar.SetColor(point, r, g, b)
    NugComboBarDB.colors[point] = {r,g,b}
    --if point == 6 and NugComboBar.allowBGColor then
    --    NugComboBar.bg:SetVertexColor(r,g,b)
    --else
    local offset = 5 - MAX_POINTS
    if point-offset > 0 then NugComboBar.p[point-offset]:SetColor(r,g,b) end
    --end
end

local ActivateFunc = function(self)
    if self:GetAlpha() == 1 then return end
    if self.dag:IsPlaying() then self.dag:Stop() end
    self.aag:Play()
    self.glow2:Play()
end
local DeactivateFunc = function(self)
    if self:GetAlpha() == 0 then return end
    if self.aag:IsPlaying() then self.aag:Stop() end
    self.dag:Play()
end
local SetColorFunc = function(self,r,g,b)
    self.t:SetVertexColor(r,g,b)
    self.g:SetVertexColor(r,g,b)
    self.g2:SetVertexColor(r,g,b)
end

function NugComboBar.CreateAnchor(frame)
    local self = CreateFrame("Frame",nil,UIParent)
    self:SetWidth(10)
    self:SetHeight(frame:GetHeight())
    self:SetBackdrop{
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 0,
        insets = {left = -2, right = -2, top = -2, bottom = -2},
    }
	self:SetBackdropColor(0.6, 0, 0, 0.7)
    
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

function NugComboBar.Create(self)
    self:SetFrameStrata("MEDIUM")
    local w = (MAX_POINTS == 3) and 256-70-30 or 256-30
    self:SetWidth(w)
    self:SetHeight(64)
    self:SetPoint("CENTER",UIParent,"CENTER",0,0)
    
    
    local bgt = self:CreateTexture(nil,"BACKGROUND")
    bgt:SetTexture("Interface\\Addons\\NugComboBar\\tex\\ncbu_bg"..MAX_POINTS)
    bgt:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
    bgt:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",256,-64)
    
    local prev = self
    local offsetX = 35
    local offsetY = 3.2
    local color_offset = 5 - MAX_POINTS
    self.p = {}
    for i=1,MAX_POINTS do
        local size = (MAX_POINTS == i) and 32 or 23
        local tex = (MAX_POINTS == i) and [[Interface\Addons\NugComboBar\tex\ncbu_point5]] or [[Interface\Addons\NugComboBar\tex\ncbu_point]]
        local mul = (MAX_POINTS == i) and 1.8 or 1.55
        local mul2 = (MAX_POINTS == i) and 2 or 2
        local glowAlpha = (MAX_POINTS == i) and 0.85 or 0.85
        local f = CreateFrame("Frame","NugComboBarPoint"..i,self)
        f:SetHeight(size); f:SetWidth(size);
        local t = f:CreateTexture(nil,"ARTWORK")
        t:SetTexture(tex)
        t:SetAllPoints(f)
        f.t = t
        
        if i == 1 then
            f:SetPoint("CENTER",prev,"LEFT",offsetX,offsetY)
        else
            f:SetPoint("CENTER",prev,"CENTER",offsetX,offsetY)
        end
        offsetX = (MAX_POINTS == i+1) and 46 or 34.5
        offsetY = (MAX_POINTS == i+1) and -3 or 0
        
        local g = f:CreateTexture(nil,"OVERLAY")
        g:SetHeight(size*mul); g:SetWidth(size*mul);
        g:SetTexture[[Interface\Addons\NugComboBar\tex\ncbu_point_glow]]
        g:SetPoint("CENTER",f,"CENTER",0,0)
        g:SetAlpha(glowAlpha)
        f.g = g
        
        local f2 = CreateFrame("Frame",nil,f)
        f2:SetHeight(size*mul2); f2:SetWidth(size*mul2);
        local g2 = f2:CreateTexture(nil,"OVERLAY")
        g2:SetAllPoints(f2)
        g2:SetTexture[[Interface\Addons\NugComboBar\tex\ncbu_glow2]]
        f2:SetPoint("CENTER",f,"CENTER",0,0)
        f.g2 = g2
        
        f2:SetAlpha(0)
        f:SetAlpha(0)
        
        local g2aag = f2:CreateAnimationGroup()
        local g2a = g2aag:CreateAnimation("Alpha")
        g2a:SetStartDelay(0.2)
        g2a:SetChange(1)
        g2a:SetDuration(0.3)
        g2a:SetOrder(1)
        local g2d = g2aag:CreateAnimation("Alpha")
        g2d:SetChange(-1)
        g2d:SetDuration(0.7)
        g2d:SetOrder(2)
        f.glow2 = g2aag
        
        f.SetColor = SetColorFunc
        f:SetColor(unpack(NugComboBarDB.colors[i+color_offset]))
        
        prev = f
        
        local aag = f:CreateAnimationGroup()
        f.aag = aag
        local a1 = aag:CreateAnimation("Alpha")
        a1:SetChange(1)
        a1:SetDuration(0.4)
        a1:SetOrder(1)
        aag:SetScript("OnFinished",function(self)
            self:GetParent():SetAlpha(1)
        end)


        local dag = f:CreateAnimationGroup()
        f.dag = dag
        local d1 = dag:CreateAnimation("Alpha")
        d1:SetChange(-1)
        d1:SetDuration(0.5)
        d1:SetOrder(1)
        dag:SetScript("OnFinished",function(self)
            self:GetParent():SetAlpha(0)
        end)
        
        
        f.Activate = ActivateFunc
        f.Deactivate = DeactivateFunc
        self.p[i] = f
    end    
    return self
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
    if not k or k == "help" then print([[Usage:
      |cff00ff00/ncb charspec|r
      |cff00ff00/ncb lock|r
      |cff00ff00/ncb unlock|r
      |cff00ff00/ncb scale|r <0.3 - 2.0>
      |cff00ff00/ncb changecolor|r <1-5, 0 = all>
      |cff00ff00/ncb anchorpoint|r <left | right>
      |cff00ff00/ncb reset|r]]
    )end
    if k == "unlock" then
        NugComboBar.anchor:Show()
    end
    if k == "lock" then
        NugComboBar.anchor:Hide()
    end
    if k == "reset" then
        NugComboBar.anchor:ClearAllPoints()
        NugComboBar.anchor:SetPoint("CENTER",UIParent,"CENTER",0,0)
    end
    if k == "anchorpoint" then
        local ap = v:upper()
        if ap ~= "RIGHT" and ap ~="LEFT" then print ("Current anchor point is: "..NugComboBarDB.anchorpoint); return end
        NugComboBarDB.anchorpoint = ap
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