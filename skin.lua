local aX, aY = 0,0-- values to fix model display on different aspect ratios 
--default aspect ratio is 16:9
local resolution4x3 = {
    ["800x600"] = true,
    ["1024x768"] = true,
    ["1280x960"] = true,
    ["1440x1080"] = true,
    ["1600x1200"] = true,
}
local resolution16x10 = {
    ["1280x800"] = true,
    ["1440x900"] = true,
    ["1920x1200"] = true,
    ["1680x1050"] = true,
    ["2560x1600"] = true,
}
local resolution5x4 = {
    ["1280x1024"] = true,
    ["2560x2048"] = true,
}
local resolution5x2 = {
 ["2560x1024"] = true,
}

local res = GetCVar("gxResolution")
if res then
    if resolution4x3[res] then
        aX, aY = 6, 6
    elseif resolution16x10[res] then
        aX, aY = 2, 2
    elseif resolution5x4[res] then
        aX, aY = 7, 7
    elseif resolution5x2[res] then
        aX, aY = -11, -5
    end
end

-- function NugComboBar.Skin3DAdjustOffset(self, newoffset)
--     local prev
--     for i=1,NugComboBar.MAX_POINTS do
--         local point = self.p[i]
--         point:Show()
--         if prev
--             then f:SetPoint("CENTER", prev, "CENTER", 50+newoffset, 0)
--             else f:SetPoint("LEFT", self, "LEFT", 0, 0)
--         end
--         prev = point
--     end 
-- end

-- local spells = {
--         purple1 = { model = "spells\\seedofcorruption_state.mdx", scale = 1 },
--         purple2 = { model = "spells\\gouge_precast_state_hand.mdx", scale = 3 }, -- good, warlock, rogue

--         funnel1 = { model = "spells\\manafunnel_impact_chest.mdx", scale = 1.8 }, -- monk
--         funnel2 = { model = "lifetap_state_chest.mdx      funnel3 = { model = "spells\\soulfunnel_impact_chest.mdx", scale = 3 },
--         funnel4 = { model = "spells\\healrag_state_chest.mdx", scale = 1.8 },

--         green1 = { model = "spells\\nature_precast_chest.mdx", scale = 2.5 },
--         spark1 = { model = "spells\\dispel_low_recursive.mdx", scale = 30 }, 
--         spark2 = { model = "spells\\detectmagic_recursive.mdx", scale = 30 },
--         fire1 = { model = "spells\\fire_blue_precast_uber_hand.mdx", scale = 5 }, --blue
--         fire2 = { model = "spells\\fire_precast_uber_hand.mdx", scale = 5 }, --orange
--         fire3 = { model = "spells\\fel_fire_precast_hand.mdx", scale = 5 }, --green

        -- electric1 = { model = "spells\\lightningboltivus_missile.mdx", scale = .3 }, --blue long
        -- electric2 = { model = "spells\\lightning_precast_low_hand.mdx", scale = 6 }, --blue
        -- electric3 = { model = "spells\\lightning_fel_precast_low_hand.mdx", scale = 6 }, --green
        -- electric4 = { model = "spells\\wrath_precast_hand.mdx", scale = 6 }, --green long

        -- spin1 = { model = "spells\\blessingoffreedom_state.mdx", scale = 1 }, --paladin
    -- }
NugComboBar.presets = {
    ["glowPurple"] = {
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 5 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
    },
    ["funnelPurple"] = {
        { "spells\\soulfunnel_impact_chest.mdx", 1.7 },
        { "spells\\soulfunnel_impact_chest.mdx", 1.7 },
        { "spells\\soulfunnel_impact_chest.mdx", 1.7 },
        { "spells\\soulfunnel_impact_chest.mdx", 1.7 },
        { "spells\\soulfunnel_impact_chest.mdx", 1.7 },
        { "spells\\soulfunnel_impact_chest.mdx", 3 },
        { "spells\\soulfunnel_impact_chest.mdx", 1.7 },
        { "spells\\soulfunnel_impact_chest.mdx", 1.7 },
    },
    ["glow_funnelPurple"] = {
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\soulfunnel_impact_chest.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
    },
    ["funnelRed"] = {
        { "spells\\healrag_state_chest.mdx", 1.7 },
        { "spells\\healrag_state_chest.mdx", 1.7 },
        { "spells\\healrag_state_chest.mdx", 1.7 },
        { "spells\\healrag_state_chest.mdx", 1.7 },
        { "spells\\healrag_state_chest.mdx", 1.7 },
        { "spells\\healrag_state_chest.mdx", 3 },
        { "spells\\healrag_state_chest.mdx", 1.7 },
        { "spells\\healrag_state_chest.mdx", 1.7 },
    },
    ["funnelGreen"] = {
        { "spells\\lifetap_state_chest.mdx", 1.7 },
        { "spells\\lifetap_state_chest.mdx", 1.7 },
        { "spells\\lifetap_state_chest.mdx", 1.7 },
        { "spells\\lifetap_state_chest.mdx", 1.7 },
        { "spells\\lifetap_state_chest.mdx", 1.7 },
        { "spells\\lifetap_state_chest.mdx", 3 },
        { "spells\\lifetap_state_chest.mdx", 1.7 },
        { "spells\\lifetap_state_chest.mdx", 1.7 },
    },
    ["funnelBlue"] = {
        { "spells\\manafunnel_impact_chest.mdx", 1.7 },
        { "spells\\manafunnel_impact_chest.mdx", 1.7 },
        { "spells\\manafunnel_impact_chest.mdx", 1.7 },
        { "spells\\manafunnel_impact_chest.mdx", 1.7 },
        { "spells\\manafunnel_impact_chest.mdx", 1.7 },
        { "spells\\manafunnel_impact_chest.mdx", 3 },
        { "spells\\manafunnel_impact_chest.mdx", 1.7 },
        { "spells\\manafunnel_impact_chest.mdx", 1.7 },
    },
    ["glowFreedom"] = {
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\blessingoffreedom_state.mdx", 1 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
        { "spells\\gouge_precast_state_hand.mdx", 3 },
    },
    ["fireBlue"] = {
        { "spells\\fire_blue_precast_uber_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fire_blue_precast_uber_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fire_blue_precast_uber_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fire_blue_precast_uber_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fire_blue_precast_uber_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fire_blue_precast_uber_hand.mdx", 5.5, 0, 0.0017 },
        { "spells\\fire_blue_precast_uber_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fire_blue_precast_uber_hand.mdx", 4, 0, 0.0015 },
    },
    ["fireOrange"] = {
        { "spells\\fire_precast_uber_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fire_precast_uber_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fire_precast_uber_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fire_precast_uber_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fire_precast_uber_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fire_precast_uber_hand.mdx", 5.5, 0, 0.0017 },
        { "spells\\fire_precast_uber_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fire_precast_uber_hand.mdx", 4, 0, 0.0015 },
    },
    ["fireGreen"] = {
        { "spells\\fel_fire_precast_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fel_fire_precast_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fel_fire_precast_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fel_fire_precast_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fel_fire_precast_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fel_fire_precast_hand.mdx", 5.5, 0, 0.0017 },
        { "spells\\fel_fire_precast_hand.mdx", 4, 0, 0.0015 },
        { "spells\\fel_fire_precast_hand.mdx", 4, 0, 0.0015 },
    },
    -- ["electricBlue"] = {
    --     { "spells\\lightningboltivus_missile.mdx", .25 },
    --     { "spells\\lightningboltivus_missile.mdx", .25 },
    --     { "spells\\lightningboltivus_missile.mdx", .25 },
    --     { "spells\\lightningboltivus_missile.mdx", .25 },
    --     { "spells\\lightningboltivus_missile.mdx", .25 },
    --     { "spells\\lightningboltivus_missile.mdx", .4 },
    --     { "spells\\lightningboltivus_missile.mdx", .25 },
    --     { "spells\\lightningboltivus_missile.mdx", .25 },
    -- },
}


local barBottom = false

local ActivateFunc = function(self)
    if self:GetAlpha() == 1 then return end
    if self.dag:IsPlaying() then self.dag:Stop() end
    self.aag:Play()
    if self.glow2 then self.glow2:Play() end
end
local DeactivateFunc = function(self)
    if self:GetAlpha() == 0 then return end
    if self.aag:IsPlaying() then self.aag:Stop() end
    self.dag:Play()
end
local SetColorFunc = function(self,r,g,b)
    self.t:SetVertexColor(r,g,b)
    if self.ani then self.ani.tex:SetVertexColor(r,g,b) end
end
local SetPresetFunc = function ( self, name )
    local ps = NugComboBar.presets[name]
    if not ps then return false end
    local settings = ps[self.id]
    local model, scale, ox, oy = unpack(settings)
    self:SetModel(model)
    self:SetModelScale(0.01*scale)
    ox = ox or 0
    oy = oy or 0
    local x,y,z = unpack(self.position)
    self:SetPosition(x+ox, y+oy, z)
    return true
end

local pointtex = {
    [1] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {0, 26/256, 0, 1},
        width = 26, height = 32,
        psize = 14,
        poffset_x = 19, poffset_y = -14,
    },
    [2] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {26/256, 50/256, 0, 1},
        width = 24, height = 32,
        psize = 14,
        poffset_x = 17, poffset_y = -14,
    },
    [3] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {50/256, 74/256, 0, 1},
        width = 24, height = 32,
        psize = 14,
        poffset_x = 17, poffset_y = -14,
    },
    [4] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {74/256, 98/256, 0, 1},
        width = 24, height = 32,
        psize = 14,
        poffset_x = 17, poffset_y = -14,
    },
    [5] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {26/256, 50/256, 0, 1},
        width = 24, height = 32,
        psize = 14,
        poffset_x = 17, poffset_y = -14,
    },
    [6] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {98/256, 140/256, 0, 1},
        width = 42, height = 32,
        psize = 18,
        poffset_x = 20, poffset_y = -14,
    },

    --reversed textures for paladin
    [7] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {196/256, 221/256, 0, 1},
        width = 25, height = 32,
        offset_x = -13, drawlayer = 1,
        psize = 14,
        poffset_x = 17, poffset_y = -14,
    },

    [8] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {221/256, 1, 0, 1},
        width = 35, height = 32,
        psize = 14,
        poffset_x = 16, poffset_y = -14,
    },

    ["bar"] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\UI-CastingBar-Border-Small",
        coords = {11/128, 92/128, 7/32, 24/32},
        width = 81, height = 17,
    },
}

local mappings = {
    [2] = { 1, 6 },
    [3] = { 1, 2, 6 },
    [4] = { 1, 2, 3, 6 },
    [5] = { 1, 2, 3, 4, 6 },
    [6] = { 1, 2, 3, 4, 5, 6 },
    ["PALADIN"] = { 1, 2, 6, 7, 8 },
    ["ARCANE"] = { 1, 2, 3, 6, 7, 8 },
}


function NugComboBar.SetMaxPoints(self, n, special)
    if NugComboBar.MAX_POINTS == n then return end
    NugComboBar.MAX_POINTS = n

    for _, point in pairs(self.point) do
        point:SetAlpha(0)
        point:Hide()
        point.bg:Hide()
        point.bg:ClearAllPoints()
    end

    self.point_map = mappings[special or n]

    local prevt
    local framesize = 0
    for i=1,NugComboBar.MAX_POINTS do
        local point = self.p[i]
        local popts = point.bg.settings
        point:Show()
        point.bg:Show()
        framesize = framesize + popts.width
        point.bg:SetPoint("TOPLEFT", prevt or self, prevt and "TOPRIGHT" or "TOPLEFT", popts.offset_x or 0, 0)
        prevt = point.bg

        point:SetColor(unpack(NugComboBarDB.colors[i])) --+color_offset
        if not (point:SetPreset(NugComboBarDB.preset3d)) then
            NugComboBarDB.preset3d = NugComboBar.defaults.preset3d
            point:SetPreset(NugComboBarDB.preset3d)
        end
    end
    self:SetWidth(framesize)
end



function NugComboBar.Create2DPoint(self, id, opts)
    local size = opts.psize
    local tex = [[Interface\Addons\NugComboBar\tex\ncbc_point]]
    local f = CreateFrame("Frame","NugComboBarPoint"..id,self)
    f:SetHeight(size); f:SetWidth(size);
    
    local t1 = f:CreateTexture(nil,"ARTWORK")
    t1:SetTexture(tex)
    t1:SetAllPoints(f)
    f.t = t1



    local f2 = CreateFrame("Frame",nil,f)
    f2:SetHeight(size+3); f2:SetWidth(size+3);
    local g2 = f2:CreateTexture(nil,"OVERLAY")
    g2:SetAllPoints(f2)
    g2:SetTexture[[Interface\Addons\NugComboBar\tex\ncbc_point_shine]]
    f2:SetPoint("CENTER",f,"CENTER",3,2)
    
    f2:SetAlpha(0)
    
    local g2aag = f2:CreateAnimationGroup()
    local g2a = g2aag:CreateAnimation("Alpha")
    g2a:SetStartDelay(0.18)
    g2a:SetChange(1)
    g2a:SetDuration(0.3)
    g2a:SetOrder(1)
    local g2d = g2aag:CreateAnimation("Alpha")
    g2d:SetChange(-1)
    g2d:SetDuration(0.4)
    g2d:SetOrder(2)
    --Required for 4.2
    g2aag:SetScript("OnFinished",function(self)
        self:GetParent():SetAlpha(0)
    end)

    f.glow2 = g2aag
    f.SetColor = SetColorFunc
    f.SetPreset = function() end

    return f
end

function NugComboBar.Create3DPoint(self, id, opts)
    local size = 64
    local f = CreateFrame("Model","NugComboBarPoint"..id,self)
    f:SetHeight(size); f:SetWidth(size);
    f.SetPreset = PointSetModelFunc
    f:SetLight( 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 );
    f.position = { 0.0205,0.021,0 }
    f:SetPosition(unpack(f.position))
    f:SetFacing(0)

    -- if prev
        -- then f:SetPoint("CENTER", prev, "CENTER", 50, 0)
        -- else f:SetPoint("LEFT", self, "LEFT", 0, 0)
    -- end

    -- local backdrop = {
    --     bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    --     tile = true, tileSize = 0,
    --     insets = {left = 0, right = 0, top = 0, bottom = 0},
    -- }   
    -- f:SetBackdrop(backdrop)
    -- f:SetBackdropColor(0, 0, 0, 0.7)

    f.SetColor = function() end
    f.SetPreset = SetPresetFunc

    return f
end


NugComboBar.Create = function(self)
    local MAX_POINTS = #pointtex
    self:SetFrameStrata("MEDIUM")
    self:SetWidth(164)
    self:SetHeight(32)


    self.point = {}
    self.point_map = mappings[6]
    self.p = setmetatable({}, { __index = function(t,k)
        return self.point[self.point_map[k]]
    end})

    local prevt
    for i=1,MAX_POINTS do
        local ts = pointtex[i]
        local t = self:CreateTexture("NugComboBarBackgroundTexture"..i,"BACKGROUND",nil, ts.drawlayer)
        t:SetTexture(ts.texture)
        t:SetTexCoord(unpack(ts.coords))
        t:SetPoint("TOPLEFT", prevt or self, prevt and "TOPRIGHT" or "TOPLEFT", 0, 0)
        --t:SetPoint("BOTTOMRIGHT", prevt or self, prevt and "BOTTOMRIGHT" or "BOTTOMLEFT", ts.width, ts.height)
        t:SetWidth(ts.width)
        t:SetHeight(ts.height)
        t.settings = ts
        prevt = t

        local is3D = NugComboBarDB.enable3d
        local f = is3D  and self:Create3DPoint(i, ts) or self:Create2DPoint(i, ts)
        if is3D then
            ts.poffset_x = ts.poffset_x + aX
            ts.poffset_y = ts.poffset_y + aY
        end

        f:SetAlpha(0)
        f:SetPoint("CENTER", t, "TOPLEFT", ts.poffset_x, ts.poffset_y)

        f.bg = t
        f.id = i
        self.point[i] = f
        
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
    end


    local bar = CreateFrame("StatusBar",nil, self)
    local ts = pointtex["bar"]
    bar:SetWidth(45); bar:SetHeight(7)
    bar:SetStatusBarTexture([[Interface\AddOns\NugComboBar\tex\statusbar]], "ARTWORK")
    bar:SetMinMaxValues(0,100)
    bar:SetValue(50)

    local barbg = bar:CreateTexture(nil, "BACKGROUND")
    barbg:SetTexture[[Interface\AddOns\NugComboBar\tex\statusbar]]
    --[[Interface\TargetingFrame\UI-StatusBar]]
    --[[Interface\Addons\NugComboBar\tex\white]]
    barbg:SetAllPoints(bar)
    bar.bg = barbg


    local backdrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 0,
        insets = {left = -2, right = -2, top = -2, bottom = -2},
    }    
    bar:SetBackdrop(backdrop)
    bar:SetBackdropColor(0, 0, 0, 0.7)

    bar.SetColor = function(self, r,g,b)
        self:SetStatusBarColor(r,g,b)
        self.bg:SetVertexColor(r*.5,g*.5,b*.5)
    end

    local text = bar:CreateFontString(nil, "OVERLAY")
    text:SetFont([[Interface\AddOns\NugComboBar\tex\Emblem.ttf]],15)
    text:SetPoint("TOPLEFT",bar,"TOPLEFT", 0,0)
    text:SetPoint("BOTTOMRIGHT",bar,"BOTTOMRIGHT", -10,0)
    text:SetJustifyH("RIGHT")
    text:SetTextColor(1,1,1,0.2)
    -- text:SetVertexColor(1,1,1)   
    bar.text = text

    bar.SetValue1 = bar.SetValue -- text should only be visible for demonology
    bar.SetValue = function(self, v)
        self:SetValue1(v)
        if self.text:IsVisible() then
            self.text:SetText(v)
        end
    end

    local normalSetScale = self.SetScale
    local normalSetAlpha = self.SetAlpha
    local normalShow = self.Show
    local normalHide = self.Hide
    bar.Small = function(self)
        self:SetWidth(45); self:SetHeight(7);
        self.text:Hide()
        self:SetParent(NugComboBar)
        self:ClearAllPoints()
        NugComboBar.SetScale = normalSetScale
        NugComboBar.SetAlpha = normalSetAlpha
        NugComboBar.Show = nil -- return to normal
        NugComboBar.Hide = nil
        if barBottom then 
            self:SetPoint("TOPLEFT", NugComboBar, "BOTTOMLEFT", 14, 4)
        else
            self:SetPoint("BOTTOMLEFT", NugComboBar, "TOPLEFT", 14, 0)
        end
        NugComboBar:Show()
    end

    bar.Long = function(self)
        self:Small()
        self:SetWidth(83); self:SetHeight(4);
    end

    bar.Big = function(self)
        self:SetWidth(80); self:SetHeight(20);
        self:SetParent(UIParent)
        -- I don't want to rewrite everything
        -- just to make them siblings
        self:SetScale(NugComboBar:GetScale())
        NugComboBar.SetScale = function(self, scale)
            self.bar:SetScale(scale)
            normalSetScale(NugComboBar, scale)
        end
        self:SetAlpha(NugComboBar:GetAlpha())
        NugComboBar.SetAlpha = function(self, alpha)
            self.bar:SetAlpha(alpha)
            normalSetAlpha(NugComboBar, alpha)
        end

        NugComboBar.Hide = function(self)
            self.bar:Hide()
        end
        NugComboBar.Show = function(self)
            self.bar:Show()
        end
        normalHide(NugComboBar)

        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", NugComboBar, "TOPLEFT", 5, -3)
        self.text:Show()
    end

    -- local tb = bar:CreateTexture(nil, "BACKGROUND", nil, 1)
    -- tb:SetWidth(ts.width); tb:SetHeight(ts.height)
    -- tb:SetTexture(ts.texture)
    -- tb:SetTexCoord(unpack(ts.coords))
    -- tb:SetPoint("TOPLEFT", bar, "TOPLEFT", -5, 4)

    bar:Small()
    bar:SetColor(0.6,0,0)
    -- bar.t = tb
    self.bar = bar
    bar:Hide()

    
    return self
end