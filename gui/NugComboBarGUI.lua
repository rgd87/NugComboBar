local L = NugComboBar.L

do
    local opt = {
        type = 'group',
        name = "NugComboBar",
        args = {},
    }
    -- opt.args.display = {
    --     type    = "group",
    --     name    = "Display Settings",
    --     order   = 1,
    --     args    = {},
    -- }
    opt.args.general = {
        type = "group",
        name = "General",
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
            specspec = {
                type = 'toggle',
                name = L"Specialization-specific",
                width = "normal",
                order = 1,
                disabled = function()
                    return (not NugComboBarDB_Character.charspec)
                end,
                get = function(info)
                    local spec = GetSpecialization()
                    return NugComboBarDB_Character.specspec[spec]
                end,
                set = function(info, s)
                    NugComboBar.Commands.specspec()
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
                        desc = L"Unlock dragging anchor",
                        func = function() NugComboBar.Commands.unlock() end,
                        order = 1,
                    },
                    lock = {
                        name = L"Lock",
                        type = "execute",
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
                        get = function() return NugComboBarDB.anchorpoint end,
                        set = function(info, s) NugComboBar.Commands.anchorpoint(s) end,
                        order = 3,
                    },
                    scale = {
                        name = L"Scale",
                        type = "range",
                        --desc = L"Change scale",
                        get = function(info) return NugComboBarDB.scale end,
                        set = function(info, s) NugComboBarDB.scale = s; NugComboBar:SetScale(NugComboBarDB.scale); end,
                        min = 0.4,
                        max = 2,
                        step = 0.01,
                        order = 4,
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
                    togglebliz = {
                        name = L"Disable Default",
                        type = "toggle",
                        desc = L"Hides default combat point (and other) frames",
                        get = function(info) return NugComboBarDB.disableBlizz end,
                        set = function(info, s) NugComboBar.Commands.toggleblizz() end,
                        order = 9,
                    },
                    secondLayer = {
                        name = L"Second Layer",
                        desc = L"For Anticipation talent",
                        type = "toggle",
                        get = function(info) return NugComboBarDB.secondLayer end,
                        set = function(info, s) NugComboBar.Commands.secondlayer() end,
                        order = 10,
                    },
                    hideWithoutTarget = {
                        name = L"Hide w/o Target",
                        desc = L"(Only for combat points)",
                        type = "toggle",
                        get = function(info) return NugComboBarDB.hideWithoutTarget end,
                        set = function(info, s) NugComboBar.Commands.hidewotarget() end,
                        order = 11,
                    },
                    disableProgress = {
                        name = L"Disable Progress Bar",
                        type = "toggle",
                        get = function(info) return NugComboBarDB.disableProgress end,
                        set = function(info, s) NugComboBar.Commands.toggleprogress() end,
                        order = 12,
                    },
                    vertical = {
                        name = L"Vertical",
                        type = "toggle",
                        get = function(info) return NugComboBarDB.vertical end,
                        set = function(info, s) NugComboBar.Commands.vertical() end,
                        order = 13,
                    },
                }
            },
            -- classThemes = {
            --             name = L"Use class theme",
            --             type = 'toggle',
            --             order = 2.5,
            --             get = function(info) return NugComboBarDB.classThemes end,
            --             set = function(info, s) NugComboBar.Commands.classthemes() end,
            --         },
            showColor = {
                type = "group",
                name = L"Colors",
                disabled = function() return NugComboBar:IsDefaultSkin() and NugComboBarDB.classThemes and NugComboBarDB.enable3d end,
                guiInline = true,
                order = 3,
                args = {
                    color1 = {
                        name = "1",
                        type = 'color',
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
                    colorb1 = {
                        name = "Bar1",
                        type = 'color',
                        -- desc = "Color of all Points",
                        get = function(info)
                            local r,g,b = unpack(NugComboBarDB.colors["bar1"])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor("bar1",r,g,b)
                        end,
                    },
                    colorb2 = {
                        name = "Bar2",
                        type = 'color',
                        get = function(info)
                            local r,g,b = unpack(NugComboBarDB.colors["bar2"])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugComboBar.SetColor("bar2",r,g,b)
                        end,
                    },
                    color_layer2 = {
                        name = L"Second Layer",
                        type = 'color',
                        get = function(info)
                            local r,g,b = unpack(NugComboBarDB.colors["layer2"])
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            local tbl = NugComboBarDB.colors["layer2"]
                            tbl[1] = r
                            tbl[2] = g
                            tbl[3] = b
                        end,
                    },
                },
            },
            enable2d = {
                        name = L"2D Mode",
                        type = 'toggle',
                        desc = L"(Color settings only available in 2D mode)",
                        order = 4,
                        get = function(info) return (not NugComboBarDB.enable3d) end,
                        set = function(info, s) NugComboBar.Commands.toggle3d() end,
                    },
            enable3d = {
                        name = L"3D Mode",
                        -- desc = L"(Activates 3D Mode)",
                        type = "toggle",
                        order = 5,
                        get = function(info) return NugComboBarDB.enable3d end,
                        set = function(info, s) NugComboBar.Commands.toggle3d() end,
                    },
            presets = {
                type = "group",
                name = L"3D Mode settings",
                disabled = function() return NugComboBar:IsDefaultSkin() and NugComboBarDB.classThemes and NugComboBarDB.enable3d end,
                guiInline = true,
                order = 6,
                args = {
                    
                    preset = {
                        name = L"Preset",
                        type = 'select',
                        order = 1,
                        values = function()
                            local p = {}
                            for k,_ in pairs(NugComboBar.presets) do
                                p[k] = k
                            end
                            return p
                        end,
                        get = function(info) return NugComboBarDB.preset3d end,
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
                        get = function(info) return NugComboBarDB.preset3dlayer2 end,
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
                        get = function(info) return NugComboBarDB.preset3dpointbar2 end,
                        set = function( info, v ) NugComboBar.Commands.preset3dpointbar2(v) end,
                    },

                    colors3d = {
                        name = L"Use colors",
                        desc = L"Only some effects can be altered using colored lighting.\nfireXXXX presets are good for it",
                        type = 'toggle',
                        order = 4,
                        get = function(info) return NugComboBarDB.colors3d end,
                        set = function( info, v ) NugComboBar.Commands.colors3d(v) end,
                    },

                    adjustX = {
                        name = L"X Offset",
                        type = "range",
                        disabled = function() return NugComboBar._disableOffsetSettings end,
                        desc = L"Use these to calibrate point position on resolutions with aspect ratio other than 16:9",
                        get = function(info) return NugComboBarDB_Global.adjustX end,
                        set = function(info, v) NugComboBar.Commands.adjustx(v) end,
                        min = -10,
                        max = 10,
                        step = 0.01,
                        order = 5,
                    },

                    adjustY = {
                        name = L"Y Offset",
                        type = "range",
                        disabled = function() return NugComboBar._disableOffsetSettings end,
                        desc = L"Use these to calibrate point position on resolutions with aspect ratio other than 16:9",
                        get = function(info) return NugComboBarDB_Global.adjustY end,
                        set = function(info, v) NugComboBar.Commands.adjusty(v) end,
                        min = -10,
                        max = 10,
                        step = 0.01,
                        order = 6,
                    },
                },
            },

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
            sound = {
                type = "group",
                name = L"Sounds",
                guiInline = true,
                order = 6.5,
                args = {
                    
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
                        end
                        PlaySoundFile(sound, NugComboBarDB.soundChannel) end,
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
    Config:RegisterOptionsTable("NugComboBar-Bliz", {name = "NugComboBar",type = 'group',args = {} })
    Dialog:SetDefaultSize("NugComboBar-Bliz", 600, 400)
    
    Config:RegisterOptionsTable("NugComboBar-General", opt.args.general)
    Dialog:AddToBlizOptions("NugComboBar-General", "NugComboBar")
    --Config:RegisterOptionsTable("NugComboBar-General", opt.args.general)
    --Dialog:AddToBlizOptions("NugComboBar-General", "NugComboBar")
    
    -- Config:RegisterOptionsTable("NugComboBar-Skin", opt.args.skin)
    -- Dialog:AddToBlizOptions("NugComboBar-Skin", opt.args.skin.name, "NugComboBar")
end