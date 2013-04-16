

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
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 4, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
    },
    ["funnelPurple"] = {
        { "spells\\soulfunnel_impact_chest.m2", true, 1.7 },
        { "spells\\soulfunnel_impact_chest.m2", true, 1.7 },
        { "spells\\soulfunnel_impact_chest.m2", true, 1.7 },
        { "spells\\soulfunnel_impact_chest.m2", true, 1.7 },
        { "spells\\soulfunnel_impact_chest.m2", true, 1.7 },
        { "spells\\soulfunnel_impact_chest.m2", true, 3 },
        { "spells\\soulfunnel_impact_chest.m2", true, 1.7 },
        { "spells\\soulfunnel_impact_chest.m2", true, 1.7 },
    },
    ["glow_funnelPurple"] = {
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\soulfunnel_impact_chest.m2", true, 3, 0,0,0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
    },
    ["funnelRed"] = {
        { "spells\\healrag_state_chest.m2", true, 1.7 },
        { "spells\\healrag_state_chest.m2", true, 1.7 },
        { "spells\\healrag_state_chest.m2", true, 1.7 },
        { "spells\\healrag_state_chest.m2", true, 1.7 },
        { "spells\\healrag_state_chest.m2", true, 1.7 },
        { "spells\\healrag_state_chest.m2", true, 3 },
        { "spells\\healrag_state_chest.m2", true, 1.7 },
        { "spells\\healrag_state_chest.m2", true, 1.7 },
    },
    ["funnelGreen"] = {
        { "spells\\lifetap_state_chest.m2", true, 1.7 },
        { "spells\\lifetap_state_chest.m2", true, 1.7 },
        { "spells\\lifetap_state_chest.m2", true, 1.7 },
        { "spells\\lifetap_state_chest.m2", true, 1.7 },
        { "spells\\lifetap_state_chest.m2", true, 1.7 },
        { "spells\\lifetap_state_chest.m2", true, 3 },
        { "spells\\lifetap_state_chest.m2", true, 1.7 },
        { "spells\\lifetap_state_chest.m2", true, 1.7 },
    },
    ["funnelBlue"] = {
        { "spells\\manafunnel_impact_chest.m2", true, 1.7 },
        { "spells\\manafunnel_impact_chest.m2", true, 1.7 },
        { "spells\\manafunnel_impact_chest.m2", true, 1.7 },
        { "spells\\manafunnel_impact_chest.m2", true, 1.7 },
        { "spells\\manafunnel_impact_chest.m2", true, 1.7 },
        { "spells\\manafunnel_impact_chest.m2", true, 3 },
        { "spells\\manafunnel_impact_chest.m2", true, 1.7 },
        { "spells\\manafunnel_impact_chest.m2", true, 1.7 },
    },
    ["glowFreedom"] = {
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\blessingoffreedom_state.m2",  true,  1, 0, -0.0004,0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
        { "spells\\gouge_precast_state_hand.m2", true, 3, 0,0, 0.0 },
    },
    ["fireBlue"] = {
        { "spells\\fire_blue_precast_uber_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fire_blue_precast_uber_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fire_blue_precast_uber_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fire_blue_precast_uber_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fire_blue_precast_uber_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fire_blue_precast_uber_hand.m2", true, 5.5, 0, 0.0017 },
        { "spells\\fire_blue_precast_uber_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fire_blue_precast_uber_hand.m2", true, 4, 0, 0.0015 },
    },
    ["fireOrange"] = {
        { "spells\\fire_precast_uber_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fire_precast_uber_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fire_precast_uber_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fire_precast_uber_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fire_precast_uber_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fire_precast_uber_hand.m2", true, 5.5, 0, 0.0017 },
        { "spells\\fire_precast_uber_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fire_precast_uber_hand.m2", true, 4, 0, 0.0015 },
    },
    ["fireGreen"] = {
        { "spells\\fel_fire_precast_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fel_fire_precast_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fel_fire_precast_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fel_fire_precast_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fel_fire_precast_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fel_fire_precast_hand.m2", true, 5.5, 0, 0.0017 },
        { "spells\\fel_fire_precast_hand.m2", true, 4, 0, 0.0015 },
        { "spells\\fel_fire_precast_hand.m2", true, 4, 0, 0.0015 },
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
        { "spells\\lightningbolt_missile.m2", true, 2.3 },
        { "spells\\lightningbolt_missile.m2", true, 2.3 },
        { "spells\\lightningbolt_missile.m2", true, 2.3 },
        { "spells\\lightningbolt_missile.m2", true, 2.3 },
        { "spells\\lightningbolt_missile.m2", true, 2.3 },
        { "spells\\lightningbolt_missile.m2", true, 3},
        { "spells\\lightningbolt_missile.m2", true, 2.3 },
        { "spells\\lightningbolt_missile.m2", true, 2.3 },
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
    local settings = ps[self.id]
    local model, cameraReset, scale, ox, oy, oz = unpack(settings)

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

        -- self.playermodel:ClearModel()
        
    else
        self.playermodel:Show()
        self.model:Hide()
        self.playermodel:SetModel(model)
        self.playermodel:SetModelScale(1*scale)
        

        self.playermodel:SetPosition(0+oz,0+ox,0+oz)

        -- self.model:ClearModel()
        
    end
    return true
end

local SetColor3DFunc = function(self, r,g,b)
    local enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB
    if NugComboBarDB.colors3d then
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
    pm:SetAllPoints(f)
    -- pm:SetScript("OnUpdateModel", function() print("PM model update")     end)
    pm:SetLight(enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB )

    local m = CreateFrame("Model","NugComboBarPointModel"..id,f)
    -- pm:SetScript("OnUpdateModel", function() print("M model update") end)
    m:SetAllPoints(f)
    m:SetLight(enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB )

    -- m.position = { 0.0205,0.021,0 }
    -- m:SetPosition(unpack(m.position))


    f.playermodel = pm
    f.model = m

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
        -- if is3D then
            -- ts.poffset_x = ts.poffset_x
            -- ts.poffset_y = ts.poffset_y
        -- end

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
        
        f.Activate = ActivateFunc
        f.Deactivate = DeactivateFunc
        f.Reappear = ReappearFunc
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
        NugComboBar.Show = normalShow
        NugComboBar.Hide = normalHide
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