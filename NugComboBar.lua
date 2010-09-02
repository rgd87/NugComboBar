NugComboBar = CreateFrame("Frame",nil, UIParent)

local FADE_IN = 0.3;
local FADE_OUT = 0.5;
local HIGHLIGHT_FADE_IN = 0.4;
local SHINE_FADE_IN = 0.3;
local SHINE_FADE_OUT = 0.4;
local FRAME_LAST_NUM_POINTS = 0;

local user
local prevPoints
NugComboBarDB = {}

local MAX_POINTS = MAX_COMBO_POINTS
local GetComboPoints = GetComboPoints
local allowedUnit = "player"
local showEmpty = false
local init

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

function NugComboBar.ADDON_LOADED(self,event,arg1)
    if arg1 == "NugComboBar" then
        local class = select(2,UnitClass("player"))
        if class == "ROGUE" or class == "DRUID" then
            self:RegisterEvent("UNIT_COMBO_POINTS")
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
        elseif class == "PRIEST" then
            MAX_POINTS = 3
            self:RegisterEvent("UNIT_AURA")
            --self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self.UNIT_AURA = self.UNIT_COMBO_POINTS
            scanAura = GetSpellInfo(63731) -- Serendipity
            --scanAura = GetSpellInfo(47930) -- Grace
            --allowedUnit = "target"
            GetComboPoints = GetAuraStack
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
            init = function(self)
                self:UNIT_COMBO_POINTS("INIT","player")
            end
            showEmpty = true
--~             self:RegisterEvent("UNIT_AURA")
--~             self.UNIT_AURA = self.UNIT_COMBO_POINTS
--~             scanAura = GetSpellInfo(47383) -- Molten Core
--~             GetComboPoints = GetAuraStack
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
        if not NugComboBarDB.animation then NugComboBarDB.animation = false end
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
    if init then init(self) end
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
	local comboPoint, comboPointHighlight, fadeInfo;
    --print(event,comboPoints,unit)
    if ( comboPoints > 0) then
		if ( not self:IsVisible() ) then
			self:Show();
			UIFrameFadeIn(self, FADE_IN);
		end

		for i=1, MAX_POINTS do
            comboPointAnim = _G["NugComboBarPoint"..i.."Animation"]
			comboPointHighlight = _G["NugComboBarPoint"..i.."Highlight"]
			comboPointShine = _G["NugComboBarPoint"..i.."Shine"]
			if ( i <= comboPoints ) then
				if ( i > FRAME_LAST_NUM_POINTS ) then
					local fadeInfo = {};
					fadeInfo.mode = "IN";
					fadeInfo.timeToFade = HIGHLIGHT_FADE_IN;
					fadeInfo.finishedFunc = function(frame) NugComboBar.ShineFadeIn(frame) end;
					fadeInfo.finishedArg1 = comboPointShine;
                    if NugComboBarDB.animation then
                        comboPointAnim:Show()
                        UIFrameFadeIn(comboPointAnim, 1.3)
                    end
					UIFrameFade(comboPointHighlight, fadeInfo);
				end
			else
                comboPointAnim:Hide()
                comboPointAnim:SetAlpha(0);
				comboPointHighlight:SetAlpha(0);
				comboPointShine:SetAlpha(0);
			end
		end
	else
		NugComboBarPoint1Highlight:SetAlpha(0);
		NugComboBarPoint1Shine:SetAlpha(0);
        NugComboBarPoint1Animation:SetAlpha(0);
		if not showEmpty then self:Hide() end
	end
	FRAME_LAST_NUM_POINTS = comboPoints;
end

function NugComboBar.ShineFadeIn(frame)
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = SHINE_FADE_IN;
	fadeInfo.finishedFunc = function(frameName) NugComboBar.ShineFadeOut(frameName) end;
	fadeInfo.finishedArg1 = frame:GetName();
	UIFrameFade(frame, fadeInfo);
end

function NugComboBar.ShineFadeOut(frameName)
	UIFrameFadeOut(_G[frameName], SHINE_FADE_OUT);
end

function NugComboBar.SetColor(point, r, g, b)
    NugComboBarDB.colors[point] = {r,g,b}
    _G["NugComboBarPoint"..point.."Highlight"]:SetVertexColor(r,g,b);
    _G["NugComboBarPoint"..point.."Animation"].tex:SetVertexColor(r,g,b);
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
                    anim = {
                        type = "toggle",
                        name = "Fiery animation",
                        desc = "toggle",
                        get = function(info)
                            return NugComboBarDB.animation
                        end,
                        set = function(info, s)
                            NugComboBarDB.animation = s
                            for i=1, MAX_POINTS do
                                comboPointAnim = _G["NugComboBarPoint"..i.."Animation"]
                                if NugComboBarDB.animation then
                                    comboPointAnim:Show()
                                    UIFrameFadeIn(comboPointAnim, HIGHLIGHT_FADE_IN)
                                else
                                    comboPointAnim:Hide()
                                    comboPointAnim:SetAlpha(0)
                                end
                            end
                        end,
                    },
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


function NugComboBar.Create(self)
    local fr = self
    fr:SetFrameStrata("MEDIUM")
    fr:SetWidth(140)
    fr:SetHeight(32)

    local ft = fr:CreateTexture("NugComboBarBackground","BACKGROUND")
    ft:SetTexture[[Interface\Addons\NugComboBar\NCBBackground]]
    if MAX_POINTS == 3 then
        ft:SetTexture[[Interface\Addons\NugComboBar\NCBBackground3]]
    end
    ft:SetTexCoord(0, 140/256, 0, 1)
    ft:SetAllPoints(fr)

    for i=1,MAX_POINTS do
        local size = 14
        if i == MAX_POINTS then size = 18 end
        local offsetX = 24
        if i == 4 then offsetX = 23 end
        if i == MAX_POINTS then offsetX = 27 end
        local offsetY = 0
        local f = CreateFrame("Frame","NugComboBarPoint"..i,fr)
        
        f:SetWidth(size)
        f:SetHeight(size)
        
        if i == 1 then
            f:SetPoint("LEFT",fr,"LEFT",12,2)
        else
            f:SetPoint("CENTER","NugComboBarPoint"..(i-1),"CENTER",offsetX,offsetY)
        end
        
        local h = f:CreateTexture("NugComboBarPoint"..i.."Highlight","ARTWORK")
        h:SetTexture[[Interface\Addons\NugComboBar\NCBPoint]]
        
        h:SetWidth(size-1)
        h:SetHeight(size-1)
            
        h:SetAlpha(0)
        h:SetPoint("CENTER",f,"CENTER",0,0)
        h:SetVertexColor(unpack(NugComboBarDB.colors[i]))
        
        local s = f:CreateTexture("NugComboBarPoint"..i.."Shine","OVERLAY")
        s:SetTexture[[Interface\Addons\NugComboBar\NCBShine]]
        
        s:SetWidth(size+3)
        s:SetHeight(size+3)
    
        s:SetAlpha(0)
        s:SetBlendMode("ADD")
        s:SetPoint("CENTER",f,"CENTER",0,0)
        
        
        local a = CreateFrame("Frame","NugComboBarPoint"..i.."Animation",f)
        
        local asize = 30
        if i == MAX_POINTS then asize = asize * 1.1 end
        a:SetWidth(asize)
        a:SetHeight(asize*1.5)
        
        a:SetPoint("CENTER",f,"CENTER",1.5,7)
        
        local h = a:CreateTexture(nil,"ARTWORK")
        h:SetTexture("Interface\\AddOns\\NugComboBar\\fireballanimation1")
        h:SetBlendMode("BLEND")
        h:SetTexCoord(0,0.08333,0,1)
        h:SetAllPoints(a)
        h:SetVertexColor(unpack(NugComboBarDB.colors[i]))
        
        a.tex = h
        a.tex.texcoord = 0 + (0.08333 * i * 2)
        
        local FrameOnUpdate = function (self, time)
            self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
            if self.OnUpdateCounter < 0.06 then return end
            self.OnUpdateCounter = 0
            self.tex:SetTexCoord(self.tex.texcoord, self.tex.texcoord + 0.08333,0,1)
            self.tex.texcoord = self.tex.texcoord + 0.08333
            if self.tex.texcoord > 0.99 then self.tex.texcoord = 0; end
        end
        a:SetScript("OnUpdate",FrameOnUpdate)
        a:Hide()
        a:SetAlpha(0)
    end    
    
    fr:EnableMouse(false)
    fr:RegisterForDrag("LeftButton")
    fr:SetMovable(true)
    fr:SetScript("OnDragStart",function(self) self:StartMoving() end)
    fr:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing();
        _,_, NugComboBarDB.point, NugComboBarDB.x, NugComboBarDB.y = self:GetPoint(1)
    end)
    
    
    fr:SetScale(NugComboBarDB.scale)
    fr:SetPoint(NugComboBarDB.point,UIParent,NugComboBarDB.point,NugComboBarDB.x,NugComboBarDB.y)
    fr:Hide()
    return fr
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