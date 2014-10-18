

-- local spells = {
--         purple1 = { model = "spells\\seedofcorruption_state.m2", scale = 1 },
--         purple2 = { model = "spells\\gouge_precast_state_hand.m2", scale = 3 }, -- good, warlock, rogue

--         funnel1 = { model = "spells\\manafunnel_impact_chest.m2", scale = 1.8 }, -- monk
--         funnel2 = { model = "lifetap_state_chest.m2      funnel3 = { model = "spells\\soulfunnel_impact_chest.m2", scale = 3 },
--         funnel4 = { model = "spells\\healrag_state_chest.m2", scale = 1.8 },

--         green1 = { model = "spells\\nature_precast_chest.m2", scale = 2.5 },
--         spark1 = { model = "spells\\dispel_low_recursive.m2", scale = 30 }, 
--         spark2 = { model = "spells\\detectmagic_recursive.m2", scale = 30 },
--         fire1 = { model = "spells\\fire_blue_precast_uber_hand.m2", scale = 5 }, --blue
--         fire2 = { model = "spells\\fire_precast_uber_hand.m2", scale = 5 }, --orange
--         fire3 = { model = "spells\\fel_fire_precast_hand.m2", scale = 5 }, --green

        -- electric1 = { model = "spells\\lightningboltivus_missile.m2", scale = .3 }, --blue long
        -- electric2 = { model = "spells\\lightning_precast_low_hand.m2", scale = 6 }, --blue
        -- electric3 = { model = "spells\\lightning_fel_precast_low_hand.m2", scale = 6 }, --green
        -- electric4 = { model = "spells\\wrath_precast_hand.m2", scale = 6 }, --green long

        -- spin1 = { model = "spells\\blessingoffreedom_state.m2", scale = 1 }, --paladin
    -- }
NugComboBar.presets = {
    --- model, cameraReset, scale, xOffset, yOffset
    ["glowPurple"] = {
        NORMAL = { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        BIG = { "spells\\gouge_precast_state_hand.m2", true, 4, 0,0, 0.0 },
    },
    ["glowHoly"] = {
        LEFT = { "spells\\Holy_precast_med_hand_simple.m2", true, 2.8, 0,0, 0.0 },
        NORMAL = { "spells\\Holy_precast_med_hand_simple.m2", true, 3.2, 0,0, 0.0 },
        BIG = { "spells\\Holy_precast_med_hand_simple.m2", true, 3.7, 0,0, 0.0, "spells\\Paladin_headlinghands_state_01.m2", true, 1, 0,0,0 },
        RIGHT = { "spells\\Holy_precast_med_hand_simple.m2", true, 2.8, 0,0, 0.0 },
    },
    ["funnelPurple"] = {
        NORMAL = { "spells\\soulfunnel_impact_chest.m2", true, 1.7 },
        BIG = { "spells\\soulfunnel_impact_chest.m2", true, 3 },
    },
    ["glow_funnelPurple"] = {
        NORMAL = { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        BIG = { "spells\\soulfunnel_impact_chest.m2", true, 3, 0,0,0 , "spells\\gouge_precast_state_hand.m2", true, 2.5, 0,0, 0.0,},
    },
    ["funnelRed"] = {
        NORMAL = { "spells\\healrag_state_chest.m2", true, 1.7 },
        BIG = { "spells\\healrag_state_chest.m2", true, 3 },
    },
    ["funnelGreen"] = {
        NORMAL = { "spells\\lifetap_state_chest.m2", true, 1.7 },
        BIG = { "spells\\lifetap_state_chest.m2", true, 3 },
    },
    ["funnelBlue"] = {
        NORMAL = { "spells\\manafunnel_impact_chest.m2", true, 1.7 },
        BIG = { "spells\\manafunnel_impact_chest.m2", true, 3 },
    },
    ["glowFreedom"] = {
        NORMAL = { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        BIG = { "spells\\gouge_precast_state_hand.m2", true, 4, 0,0, 0.0, "spells\\blessingoffreedom_state.m2",  true,  .51, 0, -0.0004,0 },
    },
    ["fireBlue"] = {
        NORMAL = { "spells\\fire_blue_precast_uber_hand.m2", true, 4, 0, 0.0015 },
        BIG = { "spells\\fire_blue_precast_uber_hand.m2", true, 5.5, 0, 0.0017 },
    },
    ["fireOrange"] = {
        NORMAL = { "spells\\fire_precast_uber_hand.m2", true, 4, 0, 0.0015 },
        BIG = { "spells\\fire_precast_uber_hand.m2", true, 5.5, 0, 0.0017 },
    },
    ["fireGreen"] = {
        NORMAL = { "spells\\fel_fire_precast_hand.m2", true, 4, 0, 0.0015 },
        BIG = { "spells\\fel_fire_precast_hand.m2", true, 5.5, 0, 0.0017 },
    },
    -- ["Shadowflame"] = {
    --     { "SPELLS/Shadowflame_Cast_Hand.m2", true, 3, 0, 0 },
    --     { "SPELLS/Shadowflame_Cast_Hand.m2", true, 3, 0, 0 },
    --     { "SPELLS/Shadowflame_Cast_Hand.m2", true, 3, 0, 0 },
    --     { "SPELLS/Shadowflame_Cast_Hand.m2", true, 3, 0, 0 },
    --     { "SPELLS/Shadowflame_Cast_Hand.m2", true, 3, 0, 0 },
    --     { "SPELLS/Shadowflame_Cast_Hand.m2", true, 4, 0, 0 },
    --     { "SPELLS/Shadowflame_Cast_Hand.m2", true, 3, 0, 0 },
    --     { "SPELLS/Shadowflame_Cast_Hand.m2", true, 3, 0, 0 },
    -- },
    -- ["electricBlueOld"] = {
    --     { "spells\\lightningboltivus_missile.m2", true, .25 },
    --     { "spells\\lightningboltivus_missile.m2", true, .25 },
    --     { "spells\\lightningboltivus_missile.m2", true, .25 },
    --     { "spells\\lightningboltivus_missile.m2", true, .25 },
    --     { "spells\\lightningboltivus_missile.m2", true, .25 },
    --     { "spells\\lightningboltivus_missile.m2", true, .4 },
    --     { "spells\\lightningboltivus_missile.m2", true, .25 },
    --     { "spells\\lightningboltivus_missile.m2", true, .25 },
    -- },
    ["electricBlue"] = {
        NORMAL = { "spells\\lightningbolt_missile.m2", true, 2.3 },
        BIG = { "spells\\lightningbolt_missile.m2", true, 3},
    },
}


local barBottom = false

local ActivateFunc = function(self)
    if self.dag:IsPlaying() then self.dag:Stop() end
    if self.rag:IsPlaying() then self.rag:Stop() end
    if self:GetAlpha() == 1 then return end
    self.aag:Play()
    if self.glow2 then self.glow2:Play() end
end
local DeactivateFunc = function(self)
    if self.aag:IsPlaying() then self.aag:Stop() end
    if self.rag:IsPlaying() then self.rag:Stop() end
    if self:GetAlpha() == 0 then return end
    self.dag:Play()
end
    local OnFinishedScript = function(self)
        local f = self:GetParent()
        f:dagfunc()
        f:Activate()
        f.dagfunc = nil
        self:SetScript("OnFinished", nil)
    end
local ReappearFunc = function(self, func, arg)
    if self.aag:IsPlaying() then self.aag:Stop() end
    if self.dag:IsPlaying() then self.dag:Stop() end
    self.ragfunc = func
    self.ragfuncarg = arg
    self.rag:Play()
end

local SR1 = 9
local SR2 = 10
local SR3 = 11
local SR4 = 12
local SR5 = 13
local SR6 = 14
local SR7 = 15
local SR8 = 16

local pointtex = {
    [1] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {0, 26/256, 0, 1},
        role = "LEFT",
        width = 26, height = 32,
        psize = 14,
        poffset_x = 19, poffset_y = -14,
    },
    [2] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {26/256, 50/256, 0, 1},
        role = "NORMAL",
        width = 24, height = 32,
        psize = 14,
        poffset_x = 17, poffset_y = -14,
    },
    [3] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {50/256, 74/256, 0, 1},
        role = "NORMAL",
        width = 24, height = 32,
        psize = 14,
        poffset_x = 17, poffset_y = -14,
    },
    [4] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {74/256, 98/256, 0, 1},
        role = "NORMAL",
        width = 24, height = 32,
        psize = 14,
        poffset_x = 17, poffset_y = -14,
    },
    [5] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {26/256, 50/256, 0, 1},
        role = "NORMAL",
        width = 24, height = 32,
        psize = 14,
        poffset_x = 17, poffset_y = -14,
    },
    [6] = { -- the big one
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {98/256, 140/256, 0, 1},
        role = "BIG",
        width = 42, height = 32,
        psize = 18,
        poffset_x = 20, poffset_y = -14,
        bgeffect = true,
    },

    --reversed textures for paladin
    [7] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {196/256, 221/256, 0, 1},
        role = "NORMAL",
        width = 25, height = 32,
        toffset_x = -13, drawlayer = 1,
        psize = 14,
        poffset_x = 17, poffset_y = -14,
    },

    [8] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {221/256, 1, 0, 1},
        role = "RIGHT",
        width = 35, height = 32,
        psize = 14,
        poffset_x = 16, poffset_y = -14,
    },


    -- second row
    [SR1] = { -- 
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {0, 26/256, 0, 1},
        role = "LEFT",
        chainreset = true, toffset_x = 13, toffset_y = -20,
        width = 26, height = 32,
        psize = 14,
        poffset_x = 19, poffset_y = -14,
    },
    [SR2] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {26/256, 50/256, 0, 1},
        role = "NORMAL",
        width = 24, height = 32,
        psize = 14,
        poffset_x = 17, poffset_y = -14,
    },
    [SR3] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {50/256, 74/256, 0, 1},
        role = "NORMAL",
        width = 24, height = 32,
        psize = 14,
        poffset_x = 17, poffset_y = -14,
    },
    [SR4] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {74/256, 98/256, 0, 1},
        role = "NORMAL",
        width = 24, height = 32,
        psize = 14,
        poffset_x = 17, poffset_y = -14,
    },
    [SR5] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {26/256, 50/256, 0, 1},
        role = "NORMAL",
        width = 24, height = 32,
        psize = 14,
        poffset_x = 17, poffset_y = -14,
    },
    [SR6] = { -- the big one
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {98/256, 140/256, 0, 1},
        role = "BIG",
        width = 42, height = 32,
        psize = 18,
        poffset_x = 20, poffset_y = -14,
        bgeffect = true,
    },
    [SR7] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {196/256, 221/256, 0, 1},
        role = "NORMAL",
        width = 25, height = 32,
        toffset_x = -13, drawlayer = 1,
        psize = 14,
        poffset_x = 17, poffset_y = -14,
    },

    [SR8] = {
        texture = "Interface\\Addons\\NugComboBar\\tex\\ncbc_bg5",
        coords = {221/256, 1, 0, 1},
        role = "RIGHT",
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


function RotateTexture(coords, degrees)
        local l,r,t,b = unpack(coords)
        return { r, t, l, t, r, b, l, b }
end


local IsVertical = function()
    return NugComboBarDB.vertical
end



local mappings = {
    [2] = { 1, 6 },
    [3] = { 1, 2, 6 },
    [4] = { 1, 2, 3, 6 },
    [5] = { 1, 2, 3, 4, 6 },
    [6] = { 1, 2, 3, 4, 5, 6 },
    ["SHAMAN7"] = { 1, 2, 3, 4, 6, 7, 8 },
    ["SHAMANDOUBLE"] = { 1, 2, 3, 4, 6, SR1, SR2, SR3, SR4, SR6},
    ["PALADIN"] = { 1, 2, 6, 7, 8 },
    ["ARCANE"] = { 1, 2, 3, 6, SR1, SR2, SR8 },
    ["4NO6"] = { 1, 2, 3, 8 },
    ["5NO6"] = { 1, 2, 3, 4, 8 },
}


function NugComboBar.SetMaxPoints(self, n, special, n2)
    -- n2 is second row length
    if NugComboBar.MAX_POINTS == n and NugComboBar.MAX_POINTS2 == n2 then return end
    NugComboBar.MAX_POINTS = n
    NugComboBar.MAX_POINTS2 = n2

    for _, point in pairs(self.point) do
        point:SetAlpha(0)
        point:Hide()
        point.bg:Hide()
        point.bg:ClearAllPoints()
    end

    self.point_map = mappings[special or n]

    local totalpoints = n + (n2 or 0)
    local prevt
    local framesize = 0
    for i=1,totalpoints do
        local point = self.p[i]
        local popts = point.bg.settings
        point:Show()
        point.bg:Show()
        framesize = framesize + popts.width
        if popts.chainreset then prevt = nil end
        if IsVertical() then
            point.bg:SetPoint("BOTTOMLEFT", prevt or self, prevt and "TOPLEFT" or "BOTTOMLEFT", -(popts.toffset_y or 0), popts.toffset_x or 0)
        else
            point.bg:SetPoint("TOPLEFT", prevt or self, prevt and "TOPRIGHT" or "TOPLEFT", popts.toffset_x or 0, popts.toffset_y or 0)
        end
        prevt = point.bg

        point:SetColor(unpack(NugComboBarDB.colors[i])) --+color_offset
        if i > n then
            if not (point:SetPreset(NugComboBarDB.preset3dpointbar2)) then
                NugComboBarDB.preset3dpointbar2 = NugComboBar.defaults.preset3dpointbar2
                point:SetPreset(NugComboBarDB.preset3dpointbar2)
            end
        else
            if not (point:SetPreset(NugComboBarDB.preset3d)) then
                NugComboBarDB.preset3d = NugComboBar.defaults.preset3d
                point:SetPreset(NugComboBarDB.preset3d)
            end
        end
    end
    self:SetWidth(framesize)
end


-------------------------
-- 2D Point
-------------------------
local SetColorFunc = function(self,r,g,b)
    self.t:SetVertexColor(r,g,b)
    if self.ani then self.ani.tex:SetVertexColor(r,g,b) end
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

------------------------------
-- 3D Point (Model Frame Type)
------------------------------

local SetPresetFunc = function ( self, name, noreset )
    local ps = NugComboBar.presets[name]
    if not ps then return false end
    local role = self.bg.settings.role
    if role and not ps[role] then role = "NORMAL" end
    local settings = ps[role] or ps[self.id]
    local model, cameraReset, scale, ox, oy, oz, bgmodel, bgcameraReset, bgscale, bgox, bgoy, bgoz = unpack(settings)

    -- print(">>>>", self:GetModelScale(), "POS>", self:GetPosition(), "LIGHT>",self:GetLight())

    -- self:SetModelScale(1)
    -- self:SetPosition(0,0,0)
    -- self:ClearModel()
    -- self:ClearFog()
    -- self:RefreshCamera()
    -- if notreset and cameraReset then -- cameraReset here simply means Model frame type
        -- if self.model:GetModel() == model then return end
    -- end
    self.currentPreset = name

    ox = ox or 0
    oy = oy or 0
    oz = oz or 0
    if cameraReset then
        -- self:SetCamera(0)
        self.playermodel:Hide()
        self.model:Show()
        self.model:SetModel(model)
        self.model:SetModelScale(0.01*scale)
        

        -- local x,y,z = unpack(self.model.position)
        local x,y,z = NugComboBarDB_Global.adjustX/100, NugComboBarDB_Global.adjustY/100, 0
        self.model:SetPosition(x+ox, y+oy, z)

        if self.bgmodel then
            if bgmodel then
                bgox = bgox or 0
                bgoy = bgoy or 0
                bgoz = bgoz or 0
                self.bgmodel:SetModel(bgmodel)
                self.bgmodel:SetModelScale(0.01*bgscale)
                self.bgmodel:SetPosition(x+bgox, y+bgoy, z)
                self.bgmodel:Show()
            else
                self.bgmodel:Hide()
            end
        end

        -- self.playermodel:ClearModel()
        
    else
        self.playermodel:Show()
        self.model:Hide()
        self.playermodel:SetModel(model)
        self.playermodel:SetModelScale(1*scale)
        

        self.playermodel:SetPosition(0+oz,0+ox,0+oz)

        if self.bgmodel then
            if bgmodel then
                self.bgmodel:Hide()
            end
        end
        -- self.model:ClearModel()
        
    end
    return true
end

local SetColor3DFunc = function(self, r,g,b, force)
    local enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB
    if NugComboBarDB.colors3d or force then
        enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB = 1, 0, 0, 1, 0, 1, r,g,b, 1, r,g,b
    else
        enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB = 1, 0, 0, 1, 0, 1, 0.69999, 0.69999, 0.69999, 1, 0.8, 0.8, 0.63999
    end
    self.model:SetLight(enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB )
    self.playermodel:SetLight(enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB )
end

function NugComboBar.Create3DPoint(self, id, opts)
    local size = 64
    local f = CreateFrame("Frame","NugComboBarPoint"..id,self)
    f:SetHeight(size); f:SetWidth(size);

    -- :SetLight( 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 );
    local enabled, omni, dirX, dirY, dirZ,
          ambIntensity, ambR, ambG, ambB,
          dirIntensity, dirR, dirG, dirB = 1, 0, 0, 1, 0, 1, 0.69999, 0.69999, 0.69999, 1, 0.8, 0.8, 0.63999
          -- dirIntensity, dirR, dirG, dirB = 1, 0, 0, 1, 0, 1, 1.0, 0.0, 0.0, 1, 1.0, 1.0, 1.0


    local pm = CreateFrame("PlayerModel","NugComboBarPointPlayerModel"..id,f)
    pm:SetFrameLevel(2)
    pm:SetAllPoints(f)
    -- pm:SetScript("OnUpdateModel", function() print("PM model update")     end)
    pm:SetLight(enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB )

    local m = CreateFrame("Model","NugComboBarPointModel"..id,f)
    m:SetFrameLevel(2)
    -- pm:SetScript("OnUpdateModel", function() print("M model update") end)
    m:SetAllPoints(f)
    m:SetLight(enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB )

    -- m.position = { 0.0205,0.021,0 }
    -- m:SetPosition(unpack(m.position))


    f.playermodel = pm
    f.model = m


    if opts.bgeffect then
        local bgm = CreateFrame("Model","NugComboBarPointModel"..id,f)
        bgm:SetFrameLevel(0)
        bgm:SetWidth(size)
        bgm:SetHeight(size)
        bgm:SetScale(2)
        bgm:SetPoint("CENTER", f, "CENTER", 0, 0)
        bgm:SetLight(enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB )
        f.bgmodel = bgm
    end

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

    f.SetColor = SetColor3DFunc --function() end
    f.SetPreset = SetPresetFunc

    return f
end

-- -------------------------------------
-- -- 3D Point (PlayerModel Frame Type)
-- -------------------------------------

-- local SetPresetFunc_PlayerModel = function ( self, name )
--     -- local ps = NugComboBar.presets[name]
--     -- if not ps then return false end
--     -- local settings = ps[self.id]
--     -- local model, scale, ox, oy = unpack(settings)
--     -- self:SetModel(model)
--     -- self:SetModelScale(0.01*scale)
--     -- ox = ox or 0
--     -- oy = oy or 0
--     -- local x,y,z = unpack(self.position)
--     -- self:SetPosition(x+ox, y+oy, z)
--     return true
-- end

-- function NugComboBar.Create3DPoint_PlayerModel(self, id, opts)
--     local size = 64
--     local f = CreateFrame("Model","NugComboBarPointPM"..id,self)
--     f:SetHeight(size); f:SetWidth(size);
--     -- f:SetLight( 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 );
--     f:SetLight( 1, 0, 0, 1, 0, 1, 0.69999, 0.69999, 0.69999, 1, 0.8, 0.8, 0.63999 );
--     f:SetModel([[SPELLS/SnowFlakeCreature_Var1_Missile.m2]])
--     f:SetModelScale(0.01)

--     f.position = { 0.0205,0.021,0 }
--     f:SetPosition(unpack(f.position))
--     f:SetFacing(0)

--     f.SetColor = function() end
--     f.SetPreset = SetPresetFunc_PlayerModel

--     return f
-- end


NugComboBar.Create = function(self)
    self:SetFrameStrata("MEDIUM")
    -- if IsVertical() then
        -- self:SetWidth(32)
        -- self:SetHeight(164)
    -- else
        self:SetWidth(164)
        self:SetHeight(32)
    -- end

    local initial = not _G["NugComboBarBackgroundTexture1"]

    self.point = self.point or {}
    self.point_map = mappings[6]
    self.p = setmetatable({}, { __index = function(t,k)
        return self.point[self.point_map[k]]
    end})

    local prevt
    for i=1,#pointtex do
        local ts = pointtex[i]
        local t = _G["NugComboBarBackgroundTexture"..i] or
                    self:CreateTexture("NugComboBarBackgroundTexture"..i,"BACKGROUND",nil, ts.drawlayer)
        t:SetTexture(ts.texture)
        local coords = IsVertical() and RotateTexture(ts.coords) or ts.coords
        t:SetTexCoord(unpack(coords))
        if ts.chainreset then prevt = nil end
        if IsVertical() then
            t:SetPoint("BOTTOMLEFT", prevt or self, prevt and "TOPLEFT" or "BOTTOMLEFT", -(ts.toffset_y or 0), ts.toffset_x or 0)
        else
            t:SetPoint("TOPLEFT", prevt or self, prevt and "TOPRIGHT" or "TOPLEFT", ts.toffset_x or 0, ts.toffset_y or 0)
        end
        --t:SetPoint("BOTTOMRIGHT", prevt or self, prevt and "BOTTOMRIGHT" or "BOTTOMLEFT", ts.width, ts.height)
        if IsVertical() then
            t:SetWidth(ts.height)
            t:SetHeight(ts.width)
        else
            t:SetWidth(ts.width)
            t:SetHeight(ts.height)
        end
        t.settings = ts
        prevt = t

        local is3D = NugComboBarDB.enable3d
        local f = self.point[i] or
                  (is3D  and self:Create3DPoint(i, ts) or self:Create2DPoint(i, ts))
        -- if is3D then
            -- ts.poffset_x = ts.poffset_x
            -- ts.poffset_y = ts.poffset_y
        -- end

        f:SetAlpha(0)
        if IsVertical() then
            f:SetPoint("CENTER", t, "BOTTOMLEFT", -ts.poffset_y, ts.poffset_x)
        else
            f:SetPoint("CENTER", t, "TOPLEFT", ts.poffset_x, ts.poffset_y)
        end

        f.bg = t
        f.id = i
        self.point[i] = f
        
        if initial then
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
        

        local rag = f:CreateAnimationGroup()
        f.rag = rag
        local r1 = rag:CreateAnimation("Alpha")
        r1:SetChange(-0.7)
        r1:SetDuration(0.20)
        r1:SetOrder(1)
        r1:SetScript("OnFinished", function(self)
            local p = self:GetParent():GetParent()
            p:ragfunc(p.ragfuncarg)
        end)
        local r2 = rag:CreateAnimation("Alpha")
        r2:SetChange(0.7)
        r2:SetDuration(0.40)
        r2:SetOrder(2)
        rag:SetScript("OnFinished",function(self)
            self:GetParent():SetAlpha(1)
        end)

        end --endif intiial
        
        f.Activate = ActivateFunc
        f.Deactivate = DeactivateFunc
        f.Reappear = ReappearFunc
    end

    local bar = self.bar or CreateFrame("StatusBar",nil, self)
    if initial then
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
        if IsVertical() then
            self:SetWidth(7); self:SetHeight(45);
            self:SetOrientation("VERTICAL")
            self:SetStatusBarTexture([[Interface\AddOns\NugComboBar\tex\vstatusbar]], "ARTWORK")
        else
            self:SetWidth(45); self:SetHeight(7);
            self:SetOrientation("HORIZONTAL")
            self:SetStatusBarTexture([[Interface\AddOns\NugComboBar\tex\statusbar]], "ARTWORK")
        end
        self.text:Hide()
        self:SetParent(NugComboBar)
        self:ClearAllPoints()
        NugComboBar.SetScale = normalSetScale
        NugComboBar.SetAlpha = normalSetAlpha
        NugComboBar.Show = normalShow
        NugComboBar.Hide = normalHide
        -- if barBottom then 
            -- self:SetPoint("TOPLEFT", NugComboBar, "BOTTOMLEFT", 14, 4)
        -- else
        if IsVertical() then
            self:SetPoint("BOTTOMRIGHT", NugComboBar, "BOTTOMLEFT", 0, 14)
        else
            self:SetPoint("BOTTOMLEFT", NugComboBar, "TOPLEFT", 14, 0)
        end
        -- end
        NugComboBar:Show()
    end

    bar.Long = function(self)
        self:Small()
        if IsVertical() then
            self:SetWidth(4); self:SetHeight(83);
        else
            self:SetWidth(83); self:SetHeight(4);
        end
    end

    bar.Big = function(self)
        if IsVertical() then
            self:SetWidth(20); self:SetHeight(80);
            self:SetOrientation("VERTICAL")
            self:SetStatusBarTexture([[Interface\AddOns\NugComboBar\tex\vstatusbar]], "ARTWORK")
            self.text:ClearAllPoints()
            self.text:SetPoint("CENTER",bar,"TOP", 0,-10)
            self.text:SetFont([[Interface\AddOns\NugComboBar\tex\Emblem.ttf]],10)
        else
            self:SetWidth(80); self:SetHeight(20);
            self:SetOrientation("HORIZONTAL")
            self:SetStatusBarTexture([[Interface\AddOns\NugComboBar\tex\statusbar]], "ARTWORK")
            self.text:ClearAllPoints()
            self.text:SetPoint("TOPLEFT",bar,"TOPLEFT", 0,0)
            self.text:SetPoint("BOTTOMRIGHT",bar,"BOTTOMRIGHT", -10,0)
            self.text:SetFont([[Interface\AddOns\NugComboBar\tex\Emblem.ttf]],15)
        end
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
        if IsVertical() then
            self:SetPoint("BOTTOMLEFT", NugComboBar, "BOTTOMLEFT", 3, 5)
        else
            self:SetPoint("TOPLEFT", NugComboBar, "TOPLEFT", 5, -3)
        end
        self.text:Show()
    end
    end --endif intiial


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



NugComboBar.themes = {}
NugComboBar.themes["WARLOCK"] = {
    [0] = {
        preset3d = "glowPurple",
    },
    [3] = {
        preset3d = "funnelRed",
    },
}

NugComboBar.themes["PALADIN"] = {
    [0] = {
        preset3d = "glowHoly",
    }
}

NugComboBar.themes["SHAMAN"] = {
    [0] = {
        preset3d = "electricBlue",
    }
}

NugComboBar.themes["PRIEST"] = {
    [1] = {
        preset3d = "glowFreedom",
        colors3d = true,
        colors = { normal = {0.43, 0.83, 0} },
    },
    [3] = {
        preset3d = "glowPurple",
        colors3d = true,
        colors = { normal = {0.27, 1, 0.59} },
    }
}

NugComboBar.themes["MONK"] = {
    [0] = {
        preset3d = "funnelGreen",
    },
}