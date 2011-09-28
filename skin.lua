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
function NugComboBar.ConvertTo3(self)
    if NugComboBar.MAX_POINTS == 3 then return end
    NugComboBar.MAX_POINTS = 3
    local p1 = self.p[1]
    local point,parent,to,x,y = p1:GetPoint(1)
    x = x - 34.5*2
    p1:SetPoint(point,parent,to,x,y)
    local w = 256-70-30
    self:SetWidth(w)
    self.bgt:SetTexture("Interface\\Addons\\NugComboBar\\tex\\ncbu_bg3")
    for i=1,5 do
        self.p[i]:Deactivate()
        self.p[i-2] = self.p[i]
    end
    self.p[5] = nil
    self.p[4] = nil
end
function NugComboBar.ConvertTo5(self)
    if NugComboBar.MAX_POINTS == 5 then return end
    NugComboBar.MAX_POINTS = 5
    local p1 = self.p[-1]
    local point,parent,to,x,y = p1:GetPoint(1)
    x = x + 34.5*2
    p1:SetPoint(point,parent,to,x,y)
    local w = 256-30
    self:SetWidth(w)
    self.bgt:SetTexture("Interface\\Addons\\NugComboBar\\tex\\ncbu_bg5")
    for i=5,1,-1 do
        self.p[i] = self.p[i-2]
        self.p[i]:Deactivate()
    end
    self.p[0] = nil
    self.p[-1] = nil
end
function NugComboBar.Create(self)
    local MAX_POINTS = 5
    self:SetFrameStrata("MEDIUM")
    local w = (MAX_POINTS == 3) and 256-70-30 or 256-30
    local h = 64
    self:SetWidth(w)
    self:SetHeight(h)
    self:SetPoint("CENTER",UIParent,"CENTER",0,0)
    
    local bgt = self:CreateTexture(nil,"BACKGROUND")
    bgt:SetTexture("Interface\\Addons\\NugComboBar\\tex\\ncbu_bg"..MAX_POINTS)
    bgt:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
    bgt:SetPoint("BOTTOMRIGHT",self,"TOPLEFT",256,-64)
    self.bgt = bgt
    
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
            --f:SetPoint("TOPLEFT",prev,"TOPLEFT",offsetX,offsetY-(h-size)/2)
            --f:SetPoint("BOTTOMRIGHT",prev,"BOTTOMRIGHT",0,0)---w+offsetX+size,offsetY+(h-size)/2)
            --/dump NugComboBar.p[-1]:SetAlpha(1)
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
        --Required for 4.2
        g2aag:SetScript("OnFinished",function(self)
            self:GetParent():SetAlpha(0)
        end)
        
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
