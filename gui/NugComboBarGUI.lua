local NugComboBar = _G.NugComboBar
local L = NugComboBar.L

-- local layoutChoices = { }
-- for k,v in pairs(NugComboBar.mappings) do
--         table.insert(layoutChoices, tostring(k))
-- end
-- table.sort(layoutChoices)
-- table.insert(layoutChoices, 1, "Default" )

do
    local opt = {
        type = "group",
        name = "NugComboBar",
        order = 1,
        args = {
            charspec = {
                type = 'toggle',
                name = L"Character-specific",
                desc = L"Switch between global/character configuration",
                width = "normal",
                order = 0,
                get = function(info)
                    return NugComboBarDB_Character.charspec
                end,
                set = function( info, s )
                    NugComboBar.Commands.charspec()
                end
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
                        disabled = function() return NugComboBarDB.nameplateAttach or NugComboBarDB.nameplateAttachTarget end,
                        desc = L"Unlock dragging anchor",
                        func = function() NugComboBar.Commands.unlock() end,
                        order = 1,
                    },
                    lock = {
                        name = L"Lock",
                        type = "execute",
                        -- width = "half",
                        disabled = function() return NugComboBarDB.nameplateAttach or NugComboBarDB.nameplateAttachTarget end,
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
                        disabled = function() return NugComboBarDB.nameplateAttach or NugComboBarDB.nameplateAttachTarget end,
                        get = function() return NugComboBarDB.anchorpoint end,
                        set = function(info, s) NugComboBar.Commands.anchorpoint(s) end,
                        order = 3,
                    },
                    nameplateOffsetY = {
                        name = L"Nameplate Y offset",
                        type = "range",

                        disabled = function() return not (NugComboBarDB.nameplateAttach or NugComboBarDB.nameplateAttachTarget) end,
                        get = function(info) return NugComboBarDB.nameplateOffsetY end,
                        set = function(info, s)
                            NugComboBarDB.nameplateOffsetY = s
                            if NugComboBarDB.nameplateAttachTarget then
                                NugComboBar:PLAYER_TARGET_CHANGED()
                            elseif NugComboBarDB.nameplateAttach then
                                if C_NamePlate.GetNamePlateForUnit("player") then
                                    NugComboBar:NAME_PLATE_UNIT_ADDED(nil, "player")
                                end
                            end
                        end,
                        min = -150,
                        max = 150,
                        step = 1,
                        order = 3.2,
                    },
                    nameplateAttachTarget = {
                        name = L"Attach to Target Nameplate",
                        desc = L"Display above target nameplate",
                        type = "toggle",
                        width = "full",
                        get = function(info) return NugComboBarDB.nameplateAttachTarget end,
                        set = function(info, s) NugComboBar.Commands.nameplateattachtarget() end,
                        order = 3.3,
                    },
                    scale = {
                        name = L"Scale",
                        type = "range",
                        get = function(info) return NugComboBarDB.scale end,
                        set = function(info, s) NugComboBarDB.scale = s; NugComboBar:SetScale(NugComboBarDB.scale); end,
                        min = 0.4,
                        max = 2,
                        step = 0.01,
                        order = 4,
                    },
                    alpha = {
                        name = L"Alpha",
                        type = "range",
                        get = function(info) return NugComboBarDB.alpha end,
                        set = function(info, s) NugComboBarDB.alpha = s; NugComboBar:SetAlpha(NugComboBarDB.alpha); end,
                        min = 0.1,
                        max = 1,
                        step = 0.01,
                        order = 4.5,
                    },
                    showempty = {
                        name = L"Show Empty",
                        type = "toggle",
                        desc = L"Keep when there's no points IN COMBAT",
                        get = function(info) return NugComboBarDB.showEmpty end,
                        set = function(info, s) NugComboBar.Commands.showempty() end,
                        order = 5,
                    },
                    showAlways = {
                        name = L"Show Always",
                        desc = L"Don't hide at all",
                        type = "toggle",
                        get = function(info) return NugComboBarDB.showAlways end,
                        set = function(info, s) NugComboBar.Commands.showalways() end,
                        order = 6,
                    },
                    hideOOC = {
                        name = L"Hide OOC",
                        desc = L"Always hide out of combat",
                        type = "toggle",
                        get = function(info) return NugComboBarDB.onlyCombat end,
                        set = function(info, s) NugComboBar.Commands.onlycombat() end,
                        order = 7,
                    },
                    hideslowly = {
                        name = L"Fade out",
                        type = "toggle",
                        get = function(info) return NugComboBarDB.hideSlowly end,
                        set = function(info, s) NugComboBar.Commands.hideslowly() end,
                        order = 8,
                    },
                    hideWithoutTarget = {
                        name = L"Hide w/o Target",
                        desc = L"(Only for combat points)",
                        type = "toggle",
                        get = function(info) return NugComboBarDB.hideWithoutTarget end,
                        set = function(info, s) NugComboBar.Commands.hidewotarget() end,
                        order = 11,
                    },
                    -- vertical = {
                    --     name = L"Vertical",
                    --     type = "toggle",
                    --     get = function(info) return NugComboBarDB.vertical end,
                    --     set = function(info, s) NugComboBar.Commands.vertical() end,
                    --     order = 13,
                    -- },
                    resourcesGroup = {
                        type = "group",
                        name = "",
                        guiInline = true,
                        order = 14,
                        args = {
                            togglebliz = {
                                name = L"Disable Blizzard Frames",
                                type = "toggle",
                                width = "double",
                                desc = L"Hides default class frames on player unit frame",
                                get = function(info) return NugComboBarDB.disableBlizz end,
                                set = function(info, s) NugComboBar.Commands.toggleblizz() end,
                                order = 14,
                            },
                        },
                    },
                }
            },
            showColor = {
                type = "group",
                name = L"Colors",
                -- disabled = function() return NugComboBar:IsDefaultSkin() and NugComboBarDB.classThemes and NugComboBarDB.enable3d end,
                guiInline = true,
                order = 3,
                args = {
                    color1 = {
                        name = "1",
                        type = 'color',
                        order = 1,
                        --desc = "Color of first point",
                        get = function(info)
                            local r,g,b = unpack(NugComboBarDB.colors[1])
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
                            local r,g,b = unpack(NugComboBarDB.colors[2])
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
                            local r,g,b = unpack(NugComboBarDB.colors[3])
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
                            local r,g,b = unpack(NugComboBarDB.colors[4])
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
                            local r,g,b = unpack(NugComboBarDB.colors[5])
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
                            local r,g,b = unpack(NugComboBarDB.colors[6])
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
                            local r,g,b = unpack(NugComboBarDB.colors[5])
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
                            local r,g,b = unpack(NugComboBarDB.colors[1])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            for i=1,6 do
                                NugComboBar.SetColor(i,r,g,b)
                            end
                        end,
                    },
                    intensity = {
                        name = L"2D Mode glow intensity",
                        type = "range",
                        get = function(info) return NugComboBarDB.glowIntensity end,
                        set = function(info, s)
                            NugComboBarDB.glowIntensity = s
                            for i=1,6 do
                                local color = NugComboBarDB.colors[i]
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
            enable2d = {
                        name = L"2D Mode",
                        type = 'toggle',
                        -- disabled = function() return NugComboBar:IsDefaultSkin() end,
                        confirm = true,
						confirmText = "Warning: Requires UI reloading.",
                        desc = L"(Color settings only available in 2D mode)",
                        order = 4,
                        get = function(info) return (not NugComboBarDB.enable3d) end,
                        set = function(info, s) NugComboBarDB.enable3d = not NugComboBarDB.enable3d; ReloadUI(); end,
                    },
            enable3d = {
                        name = L"3D Mode",
                        -- desc = L"(Activates 3D Mode)",
                        type = "toggle",
                        confirm = true,
						confirmText = "Warning: Requires UI reloading.",
                        order = 5,
                        get = function(info) return NugComboBarDB.enable3d end,
                        set = function(info, s) NugComboBarDB.enable3d = not NugComboBarDB.enable3d; ReloadUI(); end,
                    },
            presets = {
                type = "group",
                name = L"3D Mode settings",
                -- disabled = function() return NugComboBar:IsDefaultSkin() and NugComboBarDB.classThemes and NugComboBarDB.enable3d end,
                guiInline = true,
                order = 6,
                args = {

                    preset = {
                        name = L"Preset",
                        type = 'select',
                        order = 1,
                        disabled = function() return (NugComboBarDB.classThemes == true) end,
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
                        get = function(info) return NugComboBarDB.preset3d end,
                        set = function( info, v ) NugComboBar.Commands.preset3d(v) end,
                    },
                    colors3d = {
                        name = L"Use colors",
                        desc = L"Only some effects can be altered using colored lighting.\nfireXXXX presets are good for it",
                        width = "double",
                        type = 'toggle',
                        order = 5,
                        get = function(info) return NugComboBarDB.colors3d end,
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
                        get = function(info) return NugComboBarDB.soundChannel end,
                        set = function( info, v ) NugComboBarDB.soundChannel = v end,
                    },

                    soundNameFull = {
                        name = L"Max points sound",
                        desc = L"(Active only for certain specs)",
                        type = 'select',
                        order = 1,
                        values = NugComboBar.soundChoices,
                        get = function(info)
                            for i,v in ipairs(NugComboBar.soundChoices) do
                                if v == NugComboBarDB.soundNameFull then return i end
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
                        disabled = function() return (NugComboBarDB.soundNameFull == "none") end,
                        func = function()
                            local sound = NugComboBar.soundFiles[NugComboBarDB.soundNameFull]
                            if sound == "custom" then
                                sound = NugComboBarDB.soundNameFullCustom
                                PlaySoundFile(sound, NugComboBarDB.soundChannel)
                            else
                                if type(sound) == "number" then
                                    PlaySound(sound, NugComboBarDB.soundChannel)
                                end
                            end
                        end,
                    },
                    customsoundNameFull = {
                        name = L"Custom Sound",
                        type = 'input',
                        width = "full",
                        order = 2,
                        disabled = function() return (NugComboBarDB.soundNameFull ~= "custom") end,
                        get = function(info) return NugComboBarDB.soundNameFullCustom end,
                        set = function( info, v )
                            NugComboBarDB.soundNameFullCustom = v
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
            --                 local overrideLayout = NugComboBarDB.overrideLayout
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

            disable = {
                type = "group",
                name = "",
                guiInline = true,
                order = 7,
                args = {
                    desc = {
                        type = 'description',
                        name = L"Disable for current character or spec",
                        order = 1,
                    },
                    disabled = {
                        name = L"Disabled",
                        type = 'toggle',
                        disabled = function() return not NugComboBarDB_Character.charspec end,
                        get = function(info)
                            if NugComboBarDB == NugComboBarDB_Global then return nil end
                            return NugComboBarDB.disabled
                        end,
                        set = function(info, s) NugComboBar.Commands.disable(s) end,
                        order = 2,
                    },
                    -- reloadui = {
                    --     order = 3,
                    --     type = "execute",
                    --     name = L"ReloadUI",
                    --     func = function() ReloadUI() end
                    -- },
                },
            },

        },
    }

    local Config = LibStub("AceConfigRegistry-3.0")
    local Dialog = LibStub("AceConfigDialog-3.0")

    Config:RegisterOptionsTable("NugComboBar", opt)
    Dialog:AddToBlizOptions("NugComboBar", "NugComboBar")
end
