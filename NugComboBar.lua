local NUGCOMBOBAR_FADE_IN = 0.3;
local NUGCOMBOBAR_FADE_OUT = 0.5;
local NUGCOMBOBAR_HIGHLIGHT_FADE_IN = 0.4;
local NUGCOMBOBAR_SHINE_FADE_IN = 0.3;
local NUGCOMBOBAR_SHINE_FADE_OUT = 0.4;
local NUGCOMBOBAR_FRAME_LAST_NUM_POINTS = 0;

local db

local function SetupDefaults(t, defaults)
    if not defaults then return end
    for k,v in pairs(defaults) do
        if type(v) == "table" then
            if t[k] == nil then
                t[k] = CopyTable(v)
            elseif t[k] == false then
                t[k] = false --pass
            else
                ns.SetupDefaults(t[k], v)
            end
        else
            if t[k] == nil then t[k] = v end
        end
    end
end

local function RemoveDefaults(t, defaults)
    if not defaults then return end
    for k, v in pairs(defaults) do
        if type(t[k]) == 'table' and type(v) == 'table' then
            ns.RemoveDefaults(t[k], v)
            if next(t[k]) == nil then
                t[k] = nil
            end
        elseif t[k] == v then
            t[k] = nil
        end
    end
    return t
end


NugComboBar:SetScript("OnEvent", function()
	return this[event](this, event, arg1, arg2, arg3)
end)
NugComboBar:RegisterEvent("PLAYER_LOGIN");
NugComboBar:RegisterEvent("PLAYER_LOGOUT");



local defaults = {
	locked = false,
	showempty = false,
	scale = 1.2,
}


function NugComboBar:PLAYER_LOGIN(event)
	local _,class = UnitClass("player");
	if (class == "ROGUE" or class == "DRUID") then
		-- local realmName = GetCVar("realmName");
		-- local playerName = UnitName("player");
		-- player = realmName.."|"..playerName;

		NugComboBarDB = NugComboBarDB or {}
		db = NugComboBarDB
		SetupDefaults(db, defaults)


		if NugComboBarDB.showempty then
			NugComboBar:PLAYER_COMBO_POINTS()
		end
		NugComboBar:SetScale(NugComboBarDB.scale)



		this:RegisterEvent("PLAYER_TARGET_CHANGED");
		this:RegisterEvent("PLAYER_COMBO_POINTS");

		ComboFrame:UnregisterEvent("PLAYER_TARGET_CHANGED");
		ComboFrame:UnregisterEvent("PLAYER_COMBO_POINTS");
		-- init alpha
		NugComboBarPoint1Highlight:SetAlpha(0);
		NugComboBarPoint1Shine:SetAlpha(0);



		if NugComboBarDB.locked then
			NugComboBar:DisableDrag()
		else
			NugComboBar:EnableDrag()
		end



		SLASH_NUGCOMBOBAR1= "/ncb";
		SLASH_NUGCOMBOBAR2 = "/nugcombobar";
		SLASH_NUGCOMBOBAR2 = "/nugiecombobar";
		SlashCmdList["NUGCOMBOBAR"] = NugComboBarPointsFrame_SlashCmd;
	end
end

function NugComboBar:PLAYER_LOGOUT(event)
	RemoveDefaults(db, defaults)
end


local function rgb2hsv(r, g, b)
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

local function hsv2rgb(h,s,v)
    local r,g,b
    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);
    local rem = math.mod(i, 6)
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

local function SetColor(i, r,g,b)
	local comboPointHighlight = getglobal("NugComboBarPoint"..i.."Highlight");
	local comboPointHighlight2 = getglobal("NugComboBarPoint"..i.."Highlight2");
	local comboPointShine = getglobal("NugComboBarPoint"..i.."Shine");


	local glowIntensity = 0.6

    if not r then return end
    local h,s,v = rgb2hsv(r,g,b)
    local h2 = h - 0.15
    if h2 < 0 then h2 = h2 + 1 end
    local r2,g2,b2 = hsv2rgb(h2, s, v)
    local m1 = glowIntensity
    local m2 = 1

    comboPointHighlight:SetVertexColor(r2*m1,g2*m1,b2*m1)
    comboPointHighlight2:SetVertexColor(r*m2,g*m2,b*m2)
end



function NugComboBar:PLAYER_COMBO_POINTS()
	local comboPoints = GetComboPoints();
	if ( comboPoints > 0 or NugComboBarDB.showempty) then
		if ( not NugComboBar:IsVisible() ) then
			NugComboBar:Show();
			UIFrameFadeIn(NugComboBar, NUGCOMBOBAR_FADE_IN);
		end

		for i=1, MAX_COMBO_POINTS do
			local comboPointHighlight = getglobal("NugComboBarPoint"..i.."Highlight");
			local comboPointHighlight2 = getglobal("NugComboBarPoint"..i.."Highlight2");
			local comboPointShine = getglobal("NugComboBarPoint"..i.."Shine");
			if ( i <= comboPoints ) then
				SetColor(i, 1, 0.33, 0.74)
				if ( i > NUGCOMBOBAR_FRAME_LAST_NUM_POINTS ) then
					-- Fade in the highlight and set a function that triggers when it is done fading
					local fadeInfo = {};
					fadeInfo.mode = "IN";
					fadeInfo.timeToFade = NUGCOMBOBAR_HIGHLIGHT_FADE_IN;
					-- fadeInfo.finishedFunc = NugComboBarPointShineFadeIn;
					-- fadeInfo.finishedArg1 = comboPointShine;
					UIFrameFade(comboPointHighlight, fadeInfo);


					local fadeInfo2 = {};
					fadeInfo2.mode = "IN";
					fadeInfo2.timeToFade = NUGCOMBOBAR_HIGHLIGHT_FADE_IN;
					UIFrameFade(comboPointHighlight2, fadeInfo2);

					NUGCOMBOBAR_SHINE_FADE_IN = NUGCOMBOBAR_HIGHLIGHT_FADE_IN+0.1
					NugComboBarPointShineFadeIn(comboPointShine)
				end
			else
				comboPointHighlight:SetAlpha(0);
				comboPointHighlight2:SetAlpha(0);
				comboPointShine:SetAlpha(0);
			end
		end
	else
		NugComboBarPoint1Highlight:SetAlpha(0);
		NugComboBarPoint1Highlight2:SetAlpha(0);
		NugComboBarPoint1Shine:SetAlpha(0);
		NugComboBar:Hide();
	end
	NUGCOMBOBAR_FRAME_LAST_NUM_POINTS = comboPoints;
end
NugComboBar.PLAYER_TARGET_CHANGED = NugComboBar.PLAYER_COMBO_POINTS

function NugComboBarPointShineFadeIn(frame)
	-- Fade in the shine and then fade it out with the NugComboBarPointShineFadeOut function
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = NUGCOMBOBAR_SHINE_FADE_IN;
	fadeInfo.finishedFunc = NugComboBarPointShineFadeOut;
	fadeInfo.finishedArg1 = frame:GetName();
	UIFrameFade(frame, fadeInfo);
end

--hack since a frame can't have a reference to itself in it
function NugComboBarPointShineFadeOut(frameName)
	UIFrameFadeOut(getglobal(frameName), NUGCOMBOBAR_SHINE_FADE_OUT);
end

function NugComboBarPointsFrame_SlashCmd(msg)
	if (msg == "help" or msg == "") then
		DEFAULT_CHAT_FRAME:AddMessage("Usage:")
		DEFAULT_CHAT_FRAME:AddMessage("/ncb lock")
		DEFAULT_CHAT_FRAME:AddMessage("/ncb unlock")
		DEFAULT_CHAT_FRAME:AddMessage("/ncb scale (0.5 - 2.0)")
		DEFAULT_CHAT_FRAME:AddMessage("/ncb showempty")
	elseif (msg == "lock") then
		NugComboBar:DisableDrag()
		NugComboBarDB.locked = true
	elseif (msg == "unlock") then
		NugComboBar:EnableDrag()
		NugComboBarDB.locked = false
	elseif (string.sub(msg, 1, 5) == "scale" ) then
		local scale = tonumber(string.sub(msg, 7));
		if( scale <= 2.0 and scale >= 0.5 ) then
			NugComboBar:SetScale(scale);
			NugComboBarDB.scale=scale;
		end
	elseif (msg == "showempty") then
		if (NugComboBarDB.showempty == true) then
			NugComboBarDB.showempty = false;
			DEFAULT_CHAT_FRAME:AddMessage("ncb show empty disabled");
			if (GetComboPoints() == 0) then
				NugComboBar:Hide();
			end
		else
			NugComboBarDB.showempty = true;
			DEFAULT_CHAT_FRAME:AddMessage("ncb show empty enabled");
			if (GetComboPoints() == 0) then
				NugComboBar:Show();
				UIFrameFadeIn(NugComboBar, NUGCOMBOBAR_FADE_IN);
				NugComboBarPoint1Highlight:SetAlpha(0);
				NugComboBarPoint1Highlight2:SetAlpha(0);
				NugComboBarPoint1Shine:SetAlpha(0);
				NugComboBarPoint2Highlight:SetAlpha(0);
				NugComboBarPoint2Highlight2:SetAlpha(0);
				NugComboBarPoint2Shine:SetAlpha(0);
				NugComboBarPoint3Highlight:SetAlpha(0);
				NugComboBarPoint3Highlight2:SetAlpha(0);
				NugComboBarPoint3Shine:SetAlpha(0);
				NugComboBarPoint4Highlight:SetAlpha(0);
				NugComboBarPoint4Highlight2:SetAlpha(0);
				NugComboBarPoint4Shine:SetAlpha(0);
				NugComboBarPoint5Highlight:SetAlpha(0);
				NugComboBarPoint5Highlight2:SetAlpha(0);
				NugComboBarPoint5Shine:SetAlpha(0);
			end
		end
	end
end

function NugComboBar:EnableDrag()
	this:RegisterForDrag("LeftButton");
	this:EnableMouse(true)
	this:SetMovable(true)
	this:SetScript("OnDragStart", function()
		if (not NugComboBarDB.locked) then
			this:StartMoving();
		end
	end)
end

function NugComboBar:DisableDrag()
	this:EnableMouse(false)
	this:SetMovable(false)
	this:SetScript("OnDragStart", nil)
end
