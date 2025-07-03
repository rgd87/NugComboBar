local addonName, ns = ...

local NugComboBar = _G.NugComboBar
local L = NugComboBar.L

local APILevel = math.floor(select(4,GetBuildInfo())/10000)
local isClassic = APILevel <= 4

local GetNumSpecializations = APILevel <= 4 and function() return 1 end or _G.GetNumSpecializations
local GetSpecializationInfo = APILevel <= 4 and function() return nil end or (C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo or _G.GetSpecializationInfo)

local newFeatureIcon = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t"

-- local layoutChoices = { }
-- for k,v in pairs(NugComboBar.mappings) do
--         table.insert(layoutChoices, tostring(k))
-- end
-- table.sort(layoutChoices)
-- table.insert(layoutChoices, 1, "Default" )

function ns.GetProfileList(db)
    local profiles = db:GetProfiles()
    local t = {}
    for i,v in ipairs(profiles) do
        t[v] = v
    end
    return t
end
local GetProfileList = ns.GetProfileList

do
    local opt = {
        type = "group",
        name = "NugComboBar",
        order = 1,
        args = {
            resourceSelection = {
                type = "group",
                name = "",
                guiInline = true,
                order = 1,
                args = {

                },
            },
            currentProfile = {
                type = 'group',
                order = 1.5,
                name = L"Current Profile",
                guiInline = true,
                args = {
                    curProfile = {
                        name = "",
                        type = 'select',
                        width = 1.5,
                        order = 1,
                        values = function()
                            return ns.GetProfileList(NugComboBar.db)
                        end,
                        get = function(info)
                            return NugComboBar.db:GetCurrentProfile()
                        end,
                        set = function(info, v)
                            local spec = GetSpecialization()
                            local class = select(2,UnitClass("player"))
                            NugComboBar.db.global.specProfiles[class][spec] = v

                            NugComboBar.db:SetProfile(v)
                        end,
                    },
                    copyButton = {
                        name = L"Copy",
                        type = 'execute',
                        order = 2,
                        width = 0.5,
                        func = function(info)
                            local p = NugComboBar.db:GetCurrentProfile()
                            ns.storedProfile = p
                        end,
                    },
                    pasteButton = {
                        name = L"Paste",
                        type = 'execute',
                        order = 3,
                        width = 0.5,
                        disabled = function()
                            return ns.storedProfile == nil
                        end,
                        func = function(info)
                            if ns.storedProfile then
                                NugComboBar.db:CopyProfile(ns.storedProfile, true)
                            end
                        end,
                    },
                    deleteButton = {
                        name = L"Delete",
                        type = 'execute',
                        order = 4,
                        confirm = true,
                        confirmText = L"Are you sure?",
                        width = 0.5,
                        disabled = function()
                            return NugComboBar.db:GetCurrentProfile() == "Default"
                        end,
                        func = function(info)
                            local p = NugComboBar.db:GetCurrentProfile()
                            NugComboBar.db:SetProfile("Default")
                            NugComboBar.db:DeleteProfile(p, true)
                        end,
                    },
                    newProfileName = {
                        name = L"New Profile Name",
                        type = 'input',
                        order = 5,
                        width = 2,
                        get = function(info) return ns.newProfileName end,
                        set = function(info, v)
                            ns.newProfileName = v
                        end,
                    },
                    createButton = {
                        name = L"Create New Profile",
                        type = 'execute',
                        order = 6,
                        disabled = function()
                            return not ns.newProfileName
                            or strlenutf8(ns.newProfileName) == 0
                            or NugComboBar.db.profiles[ns.newProfileName]
                        end,
                        func = function(info)
                            if ns.newProfileName and strlenutf8(ns.newProfileName) > 0 then
                                NugComboBar.db:SetProfile(ns.newProfileName)
                                NugComboBar.db:CopyProfile("Default", true)
                                ns.newProfileName = ""
                            end
                        end,
                    },
                },
            },
            showGeneral = {
                type = "group",
                name = L"General",
                guiInline = true,
                order = 2,
                args = {
                    unlock = {
                        name = L"Unlock",
                        type = "execute",
                        -- width = "half",
                        disabled = function() return NugComboBar.db.profile.nameplateAttach or NugComboBar.db.profile.nameplateAttachTarget end,
                        desc = L"Unlock dragging anchor",
                        func = function() NugComboBar.Commands.unlock() end,
                        order = 1,
                    },
                    lock = {
                        name = L"Lock",
                        type = "execute",
                        -- width = "half",
                        disabled = function() return NugComboBar.db.profile.nameplateAttach or NugComboBar.db.profile.nameplateAttachTarget end,
                        desc = L"Lock dragging anchor",
                        func = function() NugComboBar.Commands.lock() end,
                        order = 2,
                    },
                    anchorpoint = {
                        name = L"Anchorpoint",
                        type = "select",
                        values = {
                            LEFT = "Left",
                            RIGHT = "Right",
                            TOP = "Top",
                        },
                        disabled = function() return NugComboBar.db.profile.nameplateAttach or NugComboBar.db.profile.nameplateAttachTarget end,
                        get = function() return NugComboBar.db.profile.anchorpoint end,
                        set = function(info, s) NugComboBar.Commands.anchorpoint(s) end,
                        order = 3,
                    },
                    nameplateAttach = {
                        name = L"Attach to Player Nameplate",
                        disabled = isClassic,
                        desc = L"Display below player nameplate\nOnly works if your have player nameplate enabled",
                        type = "toggle",
                        width = "double",
                        get = function(info) return NugComboBar.db.profile.nameplateAttach end,
                        set = function(info, s) NugComboBar.Commands.nameplateattach() end,
                        order = 3.1,
                    },
                    nameplateOffsetY = {
                        name = L"Nameplate Y offset",
                        type = "range",

                        disabled = function() return not (NugComboBar.db.profile.nameplateAttach or NugComboBar.db.profile.nameplateAttachTarget) end,
                        get = function(info) return NugComboBar.db.profile.nameplateOffsetY end,
                        set = function(info, s)
                            NugComboBar.db.profile.nameplateOffsetY = s
                            if NugComboBar.db.profile.nameplateAttachTarget then
                                NugComboBar:PLAYER_TARGET_CHANGED()
                            elseif NugComboBar.db.profile.nameplateAttach then
                                if C_NamePlate.GetNamePlateForUnit("player") then
                                    NugComboBar:NAME_PLATE_UNIT_ADDED(nil, "player")
                                end
                            end
                        end,
                        min = -250,
                        max = 250,
                        step = 1,
                        order = 3.2,
                    },
                    nameplateAttachTarget = {
                        name = L"Attach to Target Nameplate",
                        desc = L"Display above target nameplate",
                        type = "toggle",
                        width = "full",
                        get = function(info) return NugComboBar.db.profile.nameplateAttachTarget end,
                        set = function(info, s) NugComboBar.Commands.nameplateattachtarget() end,
                        order = 3.3,
                    },
                    scale = {
                        name = L"Scale",
                        type = "range",
                        get = function(info) return NugComboBar.db.profile.scale end,
                        set = function(info, s) NugComboBar.db.profile.scale = s; NugComboBar:SetScale(NugComboBar.db.profile.scale); end,
                        min = 0.4,
                        max = 2,
                        step = 0.01,
                        order = 4,
                    },
                    alpha = {
                        name = L"Alpha",
                        type = "range",
                        get = function(info) return NugComboBar.db.profile.alpha end,
                        set = function(info, s) NugComboBar.db.profile.alpha = s; NugComboBar:SetAlpha(NugComboBar.db.profile.alpha); end,
                        min = 0.1,
                        max = 1,
                        step = 0.01,
                        order = 4.5,
                    },
                    showempty = {
                        name = L"Show Empty",
                        type = "toggle",
                        desc = L"Keep when there's no points IN COMBAT",
                        get = function(info) return NugComboBar.db.profile.showEmpty end,
                        set = function(info, s) NugComboBar.Commands.showempty() end,
                        order = 5,
                    },
                    showAlways = {
                        name = L"Show Always",
                        desc = L"Don't hide at all",
                        type = "toggle",
                        get = function(info) return NugComboBar.db.profile.showAlways end,
                        set = function(info, s) NugComboBar.Commands.showalways() end,
                        order = 6,
                    },
                    hideOOC = {
                        name = L"Hide OOC",
                        desc = L"Always hide out of combat",
                        type = "toggle",
                        get = function(info) return NugComboBar.db.profile.onlyCombat end,
                        set = function(info, s) NugComboBar.Commands.onlycombat() end,
                        order = 7,
                    },
                    hideslowly = {
                        name = L"Fade out",
                        type = "toggle",
                        get = function(info) return NugComboBar.db.profile.hideSlowly end,
                        set = function(info, s) NugComboBar.Commands.hideslowly() end,
                        order = 8,
                    },
                    secondLayer = {
                        name = L"Second Layer",
                        disabled = isClassic,
                        desc = L"Used for Maelstrom / Echoing Reprimand",
                        type = "toggle",
                        get = function(info) return NugComboBar.db.profile.secondLayer end,
                        set = function(info, s) NugComboBar.Commands.secondlayer() end,
                        order = 10,
                    },
                    hideWithoutTarget = {
                        name = L"Hide w/o Target",
                        desc = L"(Only for combat points)",
                        type = "toggle",
                        get = function(info) return NugComboBar.db.profile.hideWithoutTarget end,
                        set = function(info, s) NugComboBar.Commands.hidewotarget() end,
                        order = 11,
                    },
                    disableProgress = {
                        name = L"Disable Progress Bar",
                        type = "toggle",
                        get = function(info) return NugComboBar.db.profile.disableProgress end,
                        set = function(info, s) NugComboBar.Commands.toggleprogress() end,
                        order = 12,
                    },
                    chargeCooldown = {
                        name = L"Charge Cooldowns",
                        disabled = isClassic,
                        type = "toggle",
                        get = function(info) return NugComboBar.db.profile.chargeCooldown end,
                        set = function(info, s) NugComboBar.Commands.chargecooldown() end,
                        order = 12.5,
                    },
                    cooldownOnTop = {
                        name = L"Cooldowns On Top",
                        disabled = isClassic,
                        type = "toggle",
                        get = function(info) return NugComboBar.db.profile.cooldownOnTop end,
                        set = function(info, s) NugComboBar.db.profile.cooldownOnTop = not NugComboBar.db.profile.cooldownOnTop end,
                        order = 12.55,
                    },
                    enableFullColor = {
                        name = L"Recolor when Full",
                        type = "toggle",
                        get = function(info) return NugComboBar.db.profile.enableFullColor end,
                        set = function(info, s) NugComboBar.db.profile.enableFullColor = not NugComboBar.db.profile.enableFullColor end,
                        order = 12.57,
                    },
                    animationLevel = {
                        name = L"Animation Level",
                        type = "range",
                        get = function(info) return NugComboBar.db.profile.animationLevel end,
                        set = function(info, v) NugComboBar.db.profile.animationLevel = v end,
                        min = 0,
                        max = 2,
                        step = 1,
                        order = 13,
                    },
                    -- vertical = {
                    --     name = L"Vertical",
                    --     type = "toggle",
                    --     get = function(info) return NugComboBarDB.vertical end,
                    --     set = function(info, s) NugComboBar.Commands.vertical() end,
                    --     order = 13,
                    -- },


                    bar2offset = {
                        type = "group",
                        name = "",
                        disabled = isClassic,
                        guiInline = true,
                        order = 15,
                        args = {

                            bar2offset_x = {
                                name = L"2nd row X offset",
                                type = "range",
                                get = function(info) return NugComboBar.db.profile.bar2_x end,
                                set = function(info, s) NugComboBar.Commands.bar2offset(tonumber(s), nil) end,
                                softMin = -200,
                                softMax = 200,
                                step = 5,
                                order = 4.1,
                            },
                            bar2offset_y = {
                                name = L"2nd row Y offset",
                                type = "range",
                                get = function(info) return NugComboBar.db.profile.bar2_y end,
                                set = function(info, s) NugComboBar.Commands.bar2offset(nil, tonumber(s)) end,
                                softMin = -200,
                                softMax = 200,
                                step = 5,
                                order = 4.1,
                            },
                        },
                    },

                    classThemes = {
                        name = L"Use NCB Class Themes",
                        type = 'toggle',
                        width = "full",
                        disabled = isClassic,
                        order = 16,
                        get = function(info) return NugComboBar.db.profile.classThemes end,
                        set = function(info, s) NugComboBar.Commands.classthemes() end,
                    },
                }
            },

            showColor = {
                type = "group",
                name = L"Colors",
                -- disabled = function() return NugComboBar:IsDefaultSkin() and NugComboBar.db.profile.classThemes and NugComboBar.db.profile.enable3d end,
                disabled = function() return (NugComboBar.db.profile.classThemes == true) end,
                guiInline = true,
                order = 3,
                args = {
                    color1 = {
                        name = "1",
                        type = 'color',
                        order = 1,
                        --desc = "Color of first point",
                        get = function(info)
                            local r,g,b = unpack(NugComboBar.db.profile.colors[1])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor(1,r,g,b)
                        end,
                    },
                    color2 = {
                        name = "2",
                        type = 'color',
                        order = 2,
                        --desc = "Color of second point",
                        get = function(info)
                            local r,g,b = unpack(NugComboBar.db.profile.colors[2])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor(2,r,g,b)
                        end,
                    },
                    color3 = {
                        name = "3",
                        type = 'color',
                        order = 3,
                        --desc = "Color of third point",
                        get = function(info)
                            local r,g,b = unpack(NugComboBar.db.profile.colors[3])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor(3,r,g,b)
                        end,
                    },
                    color4 = {
                        name = "4",
                        type = 'color',
                        order = 4,
                        --desc = "Color of fourth point",
                        get = function(info)
                            local r,g,b = unpack(NugComboBar.db.profile.colors[4])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor(4,r,g,b)
                        end,
                    },
                    color5 = {
                        name = "5",
                        type = 'color',
                        order = 5,
                        --desc = "Color of fifth point",
                        get = function(info)
                            local r,g,b = unpack(NugComboBar.db.profile.colors[5])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor(5,r,g,b)
                        end,
                    },
                    color6 = {
                        name = "6",
                        type = 'color',
                        order = 6,
                        --desc = "Color of six point",
                        get = function(info)
                            local r,g,b = unpack(NugComboBar.db.profile.colors[6])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor(6,r,g,b)
                        end,
                    },
                    --[[colorFinal = {
                        name = "Final Point",
                        type = 'color',
                        desc = "If enabled, overrides color",
                        get = function(info)
                            local r,g,b = unpack(NugComboBar.db.profile.colors[5])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor(5,r,g,b)
                        end,
                    },]]
                    color = {
                        name = L"All Points",
                        type = 'color',
                        order = 7,
                        -- desc = "Color of all Points",
                        get = function(info)
                            local r,g,b = unpack(NugComboBar.db.profile.colors[1])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            for i=1,6 do
                                NugComboBar.SetColor(i,r,g,b)
                            end
                        end,
                    },
                    fullColor = {
                        name = "Full Color",
                        type = 'color',
                        disabled = function() return not NugComboBar.db.profile.enableFullColor end,
                        order = 7.1,
                        -- desc = "Color of all Points",
                        get = function(info)
                            local r,g,b = unpack(NugComboBar.db.profile.colors["full"])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor("full",r,g,b)
                        end,
                    },
                    colorb1 = {
                        name = "Bar1",
                        desc = L"Cooldown bar color",
                        type = 'color',
                        order = 8,
                        -- desc = "Color of all Points",
                        get = function(info)
                            local r,g,b = unpack(NugComboBar.db.profile.colors["bar1"])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor("bar1",r,g,b)
                        end,
                    },
                    colorb2 = {
                        name = "Second Row",
                        type = 'color',
                        order = 9,
                        get = function(info)
                            local r,g,b = unpack(NugComboBar.db.profile.colors["bar2"])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor("bar2",r,g,b)
                        end,
                    },
                    color_layer2 = {
                        name = L"Second Layer",
                        desc = L"For anticipation or similar",
                        type = 'color',
                        order = 10,
                        get = function(info)
                            local r,g,b = unpack(NugComboBar.db.profile.colors["layer2"])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            local tbl = NugComboBar.db.profile.colors["layer2"]
                            tbl[1] = r
                            tbl[2] = g
                            tbl[3] = b
                        end,
                    },
                },
            },
            mode2dSettings = {
                type = "group",
                name = L"2D Mode settings",
                disabled = function() return NugComboBar.db.global.enable3d end,
                guiInline = true,
                order = 5.5,
                args = {
                    intensity = {
                        name = L"2D Mode glow intensity",
                        type = "range",
                        get = function(info) return NugComboBar.db.profile.glowIntensity end,
                        set = function(info, s)
                            NugComboBar.db.profile.glowIntensity = s
                            for i=1,6 do
                                local color = NugComboBar.db.profile.colors[i]
                                NugComboBar.SetColor(i, unpack(color))
                            end
                        end,
                        min = 0,
                        max = 1,
                        step = 0.01,
                        order = 100,
                    },
                },
            },
            presets = {
                type = "group",
                name = L"3D Mode settings".."   (DISABLED)",
                -- disabled = function() return (not NugComboBar:IsDefaultSkin() or not NugComboBar.db.global.enable3d) or NugComboBar.db.profile.classThemes end,
                disabled = true,
                guiInline = true,
                order = 6,
                args = {

                    preset = {
                        name = L"Preset",
                        type = 'select',
                        order = 1,
                        values = function()
                            local p = {}
                            for k,preset in pairs(NugComboBar.presets) do
                                local v = k
                                if preset.name then v = string.format("%s %s", k, preset.name) end
                                if k ~= "_RuneCharger2" then
                                    p[k] = v
                                end
                            end
                            return p
                        end,
                        get = function(info) return NugComboBar.db.profile.preset3d end,
                        set = function( info, v ) NugComboBar.Commands.preset3d(v) end,
                    },
                    preset_layer2 = {
                        name = L"Second Layer Preset",
                        type = 'select',
                        order = 2,
                        values = function()
                            local p = {}
                            for k,_ in pairs(NugComboBar.presets) do
                                p[k] = k
                            end
                            return p
                        end,
                        get = function(info) return NugComboBar.db.profile.preset3dlayer2 end,
                        set = function( info, v ) NugComboBar.Commands.preset3dlayer2(v) end,
                    },

                    preset_pointbar2 = {
                        name = L"Second Point Bar Preset",
                        type = 'select',
                        order = 3,
                        values = function()
                            local p = {}
                            for k,_ in pairs(NugComboBar.presets) do
                                p[k] = k
                            end
                            return p
                        end,
                        get = function(info) return NugComboBar.db.profile.preset3dpointbar2 end,
                        set = function( info, v ) NugComboBar.Commands.preset3dpointbar2(v) end,
                    },
                    colors3d = {
                        name = L"Use colors",
                        desc = L"Only some effects can be altered using colored lighting.\nfireXXXX presets are good for it",
                        width = "double",
                        type = 'toggle',
                        order = 5,
                        get = function(info) return NugComboBar.db.profile.colors3d end,
                        set = function( info, v ) NugComboBar.Commands.colors3d(v) end,
                    },
                    description1 = {
                        name = "|cffffaa55 * "..L"Effects are influenced by Particle Density setting in Graphics Menu".."|r",
                        width = "full",
                        type = 'description',
                        order = 7,
                    },
                    description2 = {
                        name = "|cffffaa55 * "..L"Only several effects can change colors to some degree, marked as 'colored'".."|r",
                        width = "full",
                        type = 'description',
                        order = 8,
                    },
                },
            },

            sound = {
                type = "group",
                name = L"Sounds",
                guiInline = true,
                order = 6.5,
                args = {

                    soundChannel = {
                        name = L"Sound Channel",
                        type = 'select',
                        order = 6.4,
                        values = {
                            SFX = L"SFX",
                            Music = L"Music",
                            Ambience = L"Ambience",
                            Master = L"Master",
                        },
                        get = function(info) return NugComboBar.db.profile.soundChannel end,
                        set = function( info, v ) NugComboBar.db.profile.soundChannel = v end,
                    },

                    soundNameFull = {
                        name = L"Max points sound",
                        desc = L"(Active only for certain specs)",
                        type = 'select',
                        order = 1,
                        values = NugComboBar.soundChoices,
                        get = function(info)
                            for i,v in ipairs(NugComboBar.soundChoices) do
                                if v == NugComboBar.db.profile.soundNameFull then return i end
                            end
                        end,
                        set = function( info, v )
                            local soundNameFull = NugComboBar.soundChoices[v]
                            NugComboBar.Commands.playsound(soundNameFull)
                        end,
                    },
                    Play_soundNameFull = {
                        name = L"Play",
                        type = 'execute',
                        width = "half",
                        order = 1.5,
                        disabled = function() return (NugComboBar.db.profile.soundNameFull == "none") end,
                        func = function()
                            local sound = NugComboBar.soundFiles[NugComboBar.db.profile.soundNameFull]
                            if sound == "custom" then
                                sound = NugComboBar.db.profile.soundNameFullCustom
                                PlaySoundFile(sound, NugComboBar.db.profile.soundChannel)
                            else
                                if type(sound) == "number" then
                                    PlaySound(sound, NugComboBar.db.profile.soundChannel)
                                end
                            end
                        end,
                    },
                    customsoundNameFull = {
                        name = L"Custom Sound",
                        type = 'input',
                        width = "full",
                        order = 2,
                        disabled = function() return (NugComboBar.db.profile.soundNameFull ~= "custom") end,
                        get = function(info) return NugComboBar.db.profile.soundNameFullCustom end,
                        set = function( info, v )
                            NugComboBar.db.profile.soundNameFullCustom = v
                        end,
                    },
                },
            },
            -- overrideLayout = {
            --     type = "group",
            --     name = "",
            --     guiInline = true,
            --     disabled = function() return not NugComboBar:IsDefaultSkin() end,
            --     order = 6.9,
            --     args = {
            --         overridePointLayout = {
            --             name = L"Override Layout",
            --             type = 'select',
            --             order = 6.4,
            --             values = layoutChoices,
            --             get = function(info)
            --                 local overrideLayout = NugComboBar.db.profile.overrideLayout
            --                 if not overrideLayout then return 1 end
            --                 for i,v in ipairs(layoutChoices) do
            --                     if v == overrideLayout then return i end
            --                 end
            --             end,
            --             set = function( info, v )
            --                 local newLayout = layoutChoices[v]
            --                 NugComboBar.Commands.overridelayout(newLayout)
            --             end,
            --         },
            --     },
            -- },
        },
    }

    local specsTable = opt.args.resourceSelection.args
    for specIndex=1,GetNumSpecializations() do
        local id, name, description, icon = GetSpecializationInfo(specIndex)
        local iconCoords = nil
        if APILevel <= 3 then
            icon = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
            local _, class = UnitClass('player')
            iconCoords = CLASS_ICON_TCOORDS[class];
        end
        local _, class = UnitClass('player')
        specsTable["desc"..specIndex] = {
            name = "",
            type = "description",
            width = APILevel >= 5 and 0.4 or 0.25,
            imageWidth = 23,
            imageHeight = 23,
            image = icon,
            imageCoords = iconCoords,
            order = specIndex*10+1,
        }
        specsTable["conf"..specIndex] = {
            name = "",
            width = 1.5,
            type = "select",
            values = NugComboBar:GetAvailableConfigsForSpec(specIndex),
            get = function(info) return NugComboBar.db.global.classConfig[class][specIndex] end,
            set = function(info, v)
                NugComboBar.db.global.classConfig[class][specIndex] = v
                NugComboBar:SPELLS_CHANGED()
                NugComboBar:NotifyGUI()
            end,
            order = specIndex*10+2,
        }
        specsTable["profile"..specIndex] = {
            name = "",
            type = 'select',
            order = specIndex*10+3,
            width = 1.5,
            values = function()
                return GetProfileList(NugComboBar.db)
            end,
            get = function(info) return NugComboBar.db.global.specProfiles[class][specIndex] end,
            set = function(info, v)
                NugComboBar.db.global.specProfiles[class][specIndex] = v
                NugComboBar:SPELLS_CHANGED()
            end,
        }
    end

    local global_opts = {
        type = "group",
        name = "Global Settings",
        guiInline = true,
        order = 2.5,
        args = {
            enablePrettyRunes = {
                name = L"Pretty Runes",
                desc = L"If disabled, rune charge timers will be displayed as simple bars",
                width = "full",
                type = "toggle",
                confirm = true,
                confirmText = "Warning: Requires UI reloading.",
                get = function(info) return NugComboBar.db.global.enablePrettyRunes end,
                set = function(info, s)
                    NugComboBar.db.global.enablePrettyRunes = not NugComboBar.db.global.enablePrettyRunes
                    ReloadUI()
                end,
                order = 1,
            },
            togglebliz = {
                name = L"Disable Class Frames",
                type = "toggle",
                -- width = "double",
                desc = L"Hides default class frames on player unit frame",
                get = function(info) return NugComboBar.db.global.disableBlizz end,
                set = function(info, s) NugComboBar.Commands.toggleblizz() end,
                order = 2,
            },
            togglebliznp = {
                name = L"Disable Nameplate Class Frames",
                type = "toggle",
                width = "double",
                desc = L"Hides default class frames on player nameplate",
                get = function(info) return NugComboBar.db.global.disableBlizzNP end,
                set = function(info, s) NugComboBar.Commands.toggleblizznp() end,
                order = 3,
            },

            --[[
            enable2d = {
                name = L"2D Mode"..newFeatureIcon,
                type = 'toggle',
                -- disabled = function() return NugComboBar:IsDefaultSkin() end,
                confirm = true,
                confirmText = "Warning: Requires UI reloading.",
                -- desc = L"(Color settings only available in 2D mode)",
                order = 4,
                get = function(info) return (not NugComboBar.db.global.enable3d) end,
                set = function(info, s) NugComboBar.db.global.enable3d = not NugComboBar.db.global.enable3d; ReloadUI(); end,
            },
            enable3d = {
                name = L"3D Mode",
                desc = L"Less stable, bad coloring support",
                type = "toggle",
                confirm = true,
                confirmText = "Warning: Requires UI reloading.",
                order = 5,
                get = function(info) return NugComboBar.db.global.enable3d end,
                set = function(info, s) NugComboBar.db.global.enable3d = not NugComboBar.db.global.enable3d; ReloadUI(); end,
            },
            ]]
        },
    }

    opt.args.global = global_opts

    local Config = LibStub("AceConfigRegistry-3.0")
    local Dialog = LibStub("AceConfigDialog-3.0")

    Config:RegisterOptionsTable("NugComboBar", opt)
    Dialog:AddToBlizOptions("NugComboBar", "NugComboBar")
end
