NugComboBar = CreateFrame("Frame",nil, UIParent)

local user
NugComboBarDB = {}

local MAX_POINTS = MAX_COMBO_POINTS
local GetComboPoints = GetComboPoints
local allowedUnit = "player"
local showEmpty = false
--~ local init

NugComboBar:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

NugComboBar:RegisterEvent("ADDON_LOADED")

local scanAura
local GetAuraStack = function(unit)
    local name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitAura(allowedUnit, scanAura, nil, "HELPFUL")
    if caster ~= "player" then count = 0 end
    return (count or 0)
end

local GetShards = function(unit)
    return UnitPower(unit, SHARD_BAR_POWER_INDEX)
end

local GetHolyPower = function(unit)
    return UnitPower(unit, HOLY_POWER_INDEX)
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
        NugComboBarDB.scale = NugComboBarDB.scale or 1
        if NugComboBarDB.animation == nil then NugComboBarDB.animation = false end
--~         if NugComboBarDB.showEmpty == nil then NugComboBarDB.showEmpty = false end
        NugComboBarDB.colors = NugComboBarDB.colors or { {0.81,0.04,0.97},{0.81,0.04,0.97},{0.81,0.04,0.97},{0.81,0.04,0.97},{0.97,0,0.8} }
        
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
        
        self.MakeOptions()
    end
end
function NugComboBar.PLAYER_LOGIN(self, event)
    self:Create()
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
        if i <= comboPoints and not self.p[i].active then
            self.p[i]:Activate()
        end
        if i > comboPoints and self.p[i].active then
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
    local offset = 5 - MAX_POINTS
    if point-offset > 0 then NugComboBar.p[point-offset]:SetColor(r,g,b) end
end


function NugComboBar.MakeOptions(self)
    local opt = {
		type = 'group',
        name = "NugComboBar",
        args = {},
	}
    opt.args.general = {
        type = "group",
        name = "NCB Options "..(NugComboBarDB_Global.charspec[user] and string.format("(%s)",user) or "(Global)"),
        order = 1,
        args = {
            btns = {
                type = "group",
                name = "Position",
                guiInline = true,
                order = 1,
                args = {
                    unlock = {
                        type = "execute",
                        name = "(Un)lock",
                        func = function () local s = NugComboBar:IsMouseEnabled(); NugComboBar:EnableMouse(not s) end
                    },
                    lock = {
                        type = "execute",
                        name = "Charspec",
                        desc = "Toggle character specific options for this toon",
                        func = function () NugComboBar.SlashCmd("charspec") end
                    },
                }
            },
            showGeneral = {
                type = "group",
                name = "General",
                guiInline = true,
                order = 2,
                args = {
                    scale = {
                        name = "Scale",
                        type = "range",
                        desc = "Change scale",
                        get = function(info) return NugComboBarDB.scale end,
                        set = function(info, s) NugComboBarDB.scale = s; NugComboBar:SetScale(NugComboBarDB.scale); end,
                        min = 0.4,
                        max = 2,
                        step = 0.01,
                    },
--~                     anim = {
--~                         type = "toggle",
--~                         name = "Show Empty",
--~                         desc = "toggle",
--~                         get = function(info)
--~                             return NugComboBarDB.showEmpty
--~                         end,
--~                         set = function(info, s)
--~                             NugComboBarDB.showEmpty = s
--~                         end,
--~                     },
                }
            },
            showColor = {
                type = "group",
                name = "Colors",
                guiInline = true,
                order = 3,
                args = {
                    color1 = {
                        name = "1st",
                        type = 'color',
                        desc = "Color of first point",
                        get = function(info)
                            local r,g,b = unpack(NugComboBarDB.colors[1])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor(1,r,g,b)
                        end,
                    },
                    color2 = {
                        name = "2nd",
                        type = 'color',
                        desc = "Color of second point",
                        get = function(info)
                            local r,g,b = unpack(NugComboBarDB.colors[2])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor(2,r,g,b)
                        end,
                    },
                    color3 = {
                        name = "3rd",
                        type = 'color',
                        desc = "Color of third point",
                        get = function(info)
                            local r,g,b = unpack(NugComboBarDB.colors[3])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor(3,r,g,b)
                        end,
                    },
                    color4 = {
                        name = "4th",
                        type = 'color',
                        desc = "Color of fourth point",
                        get = function(info)
                            local r,g,b = unpack(NugComboBarDB.colors[4])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor(4,r,g,b)
                        end,
                    },
                    color5 = {
                        name = "5th",
                        type = 'color',
                        desc = "Color of fifth point",
                        get = function(info)
                            local r,g,b = unpack(NugComboBarDB.colors[5])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor(5,r,g,b)
                        end,
                    },
                    color = {
                        name = "ALL Points",
                        type = 'color',
                        desc = "Color of all Points",
                        get = function(info)
                            local r,g,b = unpack(NugComboBarDB.colors[1])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            for i=1,5 do
                                NugComboBar.SetColor(i,r,g,b)
                            end
                        end,
                    },
                },
            },
        },
    }
    
    local Config = LibStub("AceConfigRegistry-3.0")
    local Dialog = LibStub("AceConfigDialog-3.0")
    Config:RegisterOptionsTable("NugComboBar", opt)
    Config:RegisterOptionsTable("NugComboBar-Bliz", {name = "NugComboBar",type = 'group',args = {} })
    Dialog:SetDefaultSize("NugComboBar-Bliz", 600, 400)
    
    Config:RegisterOptionsTable("NugComboBar-General", opt.args.general)
    Dialog:AddToBlizOptions("NugComboBar-General", "NugComboBar")
        
--~     SlashCmdList["NCBSLASH"] = function() InterfaceOptionsFrame_OpenToFrame("NugComboBar") end;
--~     SlashCmdList["NCBSLASH"] = function() LibStub("AceConfigDialog-3.0"):Open("NugComboBar") end;
end



local ActivateFunc = function(self)
    if self.dag:IsPlaying() then self.dag:Stop() end
    self:Show()
    self.active = true
    self.aag:Play()
end
local DeactivateFunc = function(self)
    if self.aag:IsPlaying() then self.aag:Stop() end
    self.active = false
    self.dag:Play()
end
local SetColorFunc = function(self,r,g,b)
    self.t:SetVertexColor(r,g,b)
    self.g:SetVertexColor(r,g,b)
    self.g2:SetVertexColor(r,g,b)
end


function NugComboBar.Create(self)
    self:SetFrameStrata("MEDIUM")
    self:SetWidth(256)
    self:SetHeight(64)
    
    local bgt = self:CreateTexture(nil,"BACKGROUND")
    bgt:SetTexture("Interface\\Addons\\NugComboBar\\tex\\ncbu_bg"..MAX_POINTS)
    bgt:SetAllPoints(self)
    
    local prev = self
    local offsetX = -93.4
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
        
        
        f:SetPoint("CENTER",prev,"CENTER",offsetX,offsetY)
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
            f:SetAlpha(1)
        end)
        aag:SetScript("OnPlay",function(self)
            f.glow2:Play()
        end)


        local dag = f:CreateAnimationGroup()
        f.dag = dag
        local d1 = dag:CreateAnimation("Alpha")
        d1:SetChange(-1)
        d1:SetDuration(0.5)
        d1:SetOrder(1)
        dag:SetScript("OnFinished",function(self)
            f:SetAlpha(0)
            f:Hide()
        end)
        
        
        f.Activate = ActivateFunc
        f.Deactivate = DeactivateFunc
        self.p[i] = f
    end
    
    
    
    self:EnableMouse(false)
    self:RegisterForDrag("LeftButton")
    self:SetMovable(true)
    self:SetScript("OnDragStart",function(self) self:StartMoving() end)
    self:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing();
        _,_, NugComboBarDB.point, NugComboBarDB.x, NugComboBarDB.y = self:GetPoint(1)
    end)
    
    
    self:SetScale(NugComboBarDB.scale)
    self:SetPoint(NugComboBarDB.point,UIParent,NugComboBarDB.point,NugComboBarDB.x,NugComboBarDB.y)
    return self
end



function NugComboBar.SlashCmd(msg)
    local NCBString = "|cffff7777NCB: |r"
    k,v = string.match(msg, "([%w%+%-%=]+) ?(.*)")
    if not k or k == "help" then print([[Usage:
      |cff00ff00/ncb menu|r
      |cff00ff00/ncb charspec|r
      |cff00ff00/ncb lock|r
      |cff00ff00/ncb unlock|r
      |cff00ff00/ncb reset|r]]
    )end
    if k == "menu" then
        InterfaceOptionsFrame_OpenToCategory("NugComboBar")
    end
    if k == "unlock" then
        NugComboBar:EnableMouse(true)
    end
    if k == "lock" then
        NugComboBar:EnableMouse(false)
    end
    if k == "reset" then
        NugComboBar:ClearAllPoints()
        NugComboBar:SetPoint("CENTER",UIParent,"CENTER",0,0)
    end
    if k == "charspec" then
        if NugComboBarDB_Global.charspec[user] then NugComboBarDB_Global.charspec[user] = nil
        else NugComboBarDB_Global.charspec[user] = true
        end
--~         ReloadUI()
        print (NCBString..(NugComboBarDB_Global.charspec[user] and "Enabled" or "Disabled").." character specific options for this toon. Will take effect after ui reload.",0.7,1,0.7)
    end
end