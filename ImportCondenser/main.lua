local ADDON_NAME, ns = ...
ns = ns or {}

local AceAddon = LibStub("AceAddon-3.0", true)

local ImportCondenser = AceAddon:NewAddon(
    ADDON_NAME,
    "AceConsole-3.0",
    "AceEvent-3.0"
)

ns.Addon = ImportCondenser
ImportCondenser.DEBUG = true


local LibDualSpec   = LibStub("LibDualSpec-1.0", true)
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")


function ImportCondenser:OnInitialize()
    -- Called when the addon is loaded
    self.db = LibStub("AceDB-3.0"):New("ImportCondenserDB", ns.defaults or {}, true)

    if LibDualSpec then
        LibDualSpec:EnhanceDatabase(self.db, "ImportCondenser")
    end

    ns.SetupOptions(self)
    self:RegisterChatCommand("importcondenser", "OpenConfig")
    self:RegisterChatCommand("ic", "OpenConfig")
end


function ImportCondenser:OpenConfig()
    AceConfigDialog:Open(ADDON_NAME)
end

-- SetupOptions implementation
function ns.SetupOptions(self)

    local tempImportText = ""
    local options = {
        type = "group",
        name = ADDON_NAME,
        args = {
            importTab = {
                type = "group",
                name = "Import",
                desc = "Import addon profiles",
                order = 1,
                args = {
                    header = {
                        type = "header",
                        name = "Import Settings",
                        order = 0,
                    },
                    importProfile = {
                        type = "input",
                        name = "Import Profiles",
                        desc = "Paste a profile string here to import. Only strings exported from this addon are supported.",
                        multiline = true,
                        width = "full",
                        get = function()
                            return tempImportText
                        end,
                        set = function(info, value)
                            tempImportText = value
                            ImportCondenser:Import(value)
                        end,
                        order = 1,
                    },
                    reloadUi = {
                        type = "execute",
                        name = "Reload UI",
                        desc = "Reload the user interface to apply changes.",
                        func = function()
                            ReloadUI()
                        end,
                        order = 2,
                    },
                    -- Addon sections
                    nephUISection = {
                        type = "group",
                        name = "NephUI",
                        order = 10,
                        hidden = function() 
                            return not (ImportCondenser.NephUI and ImportCondenser.NephUI.IsLoaded and ImportCondenser.NephUI:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "NephUI profile will be imported.",
                                order = 1,
                            },
                        },
                    },
                    editModeSection = {
                        type = "group",
                        name = "Edit Mode",
                        order = 11,
                        hidden = function() 
                            return not (ImportCondenser.EditMode and ImportCondenser.EditMode.IsLoaded and ImportCondenser.EditMode:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "Edit Mode layout will be imported.",
                                order = 1,
                            },
                        },
                    },
                    platynatorSection = {
                        type = "group",
                        name = "Platynator",
                        order = 12,
                        hidden = function() 
                            return not (ImportCondenser.Platynator and ImportCondenser.Platynator.IsLoaded and ImportCondenser.Platynator:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "Platynator profile will be imported.",
                                order = 1,
                            },
                        },
                    },
                    baganatorSection = {
                        type = "group",
                        name = "Baganator",
                        order = 13,
                        hidden = function() 
                            return not (ImportCondenser.Baganator and ImportCondenser.Baganator.IsLoaded and ImportCondenser.Baganator:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "Baganator profile will be imported.",
                                order = 1,
                            },
                        },
                    },
                    platerSection = {
                        type = "group",
                        name = "Plater",
                        order = 14,
                        hidden = function() 
                            return not (ImportCondenser.Plater and ImportCondenser.Plater.IsLoaded and ImportCondenser.Plater:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "Plater profile will be imported.",
                                order = 1,
                            },
                        },
                    },
                    detailsSection = {
                        type = "group",
                        name = "Details",
                        order = 15,
                        hidden = function() 
                            return not (ImportCondenser.Details and ImportCondenser.Details.IsLoaded and ImportCondenser.Details:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "Details profile will be imported.",
                                order = 1,
                            },
                        },
                    },
                    bartenderSection = {
                        type = "group",
                        name = "Bartender",
                        order = 16,
                        hidden = function() 
                            return not (ImportCondenser.Bartender and ImportCondenser.Bartender.IsLoaded and ImportCondenser.Bartender:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "Bartender profile will be imported.",
                                order = 1,
                            },
                        },
                    },
                    twintopInsanityBarSection = {
                        type = "group",
                        name = "Twintop Insanity Bar",
                        order = 17,
                        hidden = function() 
                            return not (ImportCondenser.TwintopInsanityBar and ImportCondenser.TwintopInsanityBar.IsLoaded and ImportCondenser.TwintopInsanityBar:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "Twintop Insanity Bar settings will be imported.",
                                order = 1,
                            },
                        },
                    },
                    dandersFramesSection = {
                        type = "group",
                        name = "Danders Frames",
                        order = 18,
                        hidden = function() 
                            return not (ImportCondenser.DandersFrames and ImportCondenser.DandersFrames.IsLoaded and ImportCondenser.DandersFrames:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "Danders Frames profile will be imported.",
                                order = 1,
                            },
                        },
                    },
                },
            },
            exportTab = {
                type = "group",
                name = "Export",
                desc = "Export your addon profiles",
                order = 2,
                args = {
                    header = {
                        type = "header",
                        name = "Export Settings",
                        order = 0,
                    },
                    profileName = {
                        type = "input",
                        name = "Export Profile Name",
                        desc = "Enter a name for the exported profile.",
                        get = function(info)
                            return self.db.global.profileName or "DefaultProfile"
                        end,
                        set = function(info, value)
                            self.db.global.profileName = value
                        end,
                        order = 1,
                    },
                    exportNephUI = {
                        type = "execute",
                        name = "Export Current Profiles",
                        desc = "Export current profile to string.",
                        func = function()
                            ImportCondenser:ShowExportWindow()
                        end,
                        order = 2,
                    },
                    -- Addon sections
                    nephUISection = {
                        type = "group",
                        name = "NephUI",
                        order = 10,
                        hidden = function() 
                            return not (ImportCondenser.NephUI and ImportCondenser.NephUI.IsLoaded and ImportCondenser.NephUI:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "NephUI profile will be exported.",
                                order = 1,
                            },
                        },
                    },
                    editModeSection = {
                        type = "group",
                        name = "Edit Mode",
                        order = 11,
                        hidden = function() 
                            return not (ImportCondenser.EditMode and ImportCondenser.EditMode.IsLoaded and ImportCondenser.EditMode:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "Edit Mode layout will be exported.",
                                order = 1,
                            },
                        },
                    },
                    platynatorSection = {
                        type = "group",
                        name = "Platynator",
                        order = 12,
                        hidden = function() 
                            return not (ImportCondenser.Platynator and ImportCondenser.Platynator.IsLoaded and ImportCondenser.Platynator:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "Platynator profile will be exported.",
                                order = 1,
                            },
                        },
                    },
                    baganatorSection = {
                        type = "group",
                        name = "Baganator",
                        order = 13,
                        hidden = function() 
                            return not (ImportCondenser.Baganator and ImportCondenser.Baganator.IsLoaded and ImportCondenser.Baganator:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "Baganator profile will be exported.",
                                order = 1,
                            },
                        },
                    },
                    platerSection = {
                        type = "group",
                        name = "Plater",
                        order = 14,
                        hidden = function() 
                            return not (ImportCondenser.Plater and ImportCondenser.Plater.IsLoaded and ImportCondenser.Plater:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "Plater profile will be exported.",
                                order = 1,
                            },
                        },
                    },
                    detailsSection = {
                        type = "group",
                        name = "Details",
                        order = 15,
                        hidden = function() 
                            return not (ImportCondenser.Details and ImportCondenser.Details.IsLoaded and ImportCondenser.Details:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "Details profile will be exported.",
                                order = 1,
                            },
                        },
                    },
                    bartenderSection = {
                        type = "group",
                        name = "Bartender",
                        order = 16,
                        hidden = function() 
                            return not (ImportCondenser.Bartender and ImportCondenser.Bartender.IsLoaded and ImportCondenser.Bartender:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "Bartender profile will be exported.",
                                order = 1,
                            },
                        },
                    },
                    twintopInsanityBarSection = {
                        type = "group",
                        name = "Twintop Insanity Bar",
                        order = 17,
                        hidden = function() 
                            return not (ImportCondenser.TwintopInsanityBar and ImportCondenser.TwintopInsanityBar.IsLoaded and ImportCondenser.TwintopInsanityBar:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "Twintop Insanity Bar settings will be exported.",
                                order = 1,
                            },
                        },
                    },
                    dandersFramesSection = {
                        type = "group",
                        name = "Danders Frames",
                        order = 18,
                        hidden = function() 
                            return not (ImportCondenser.DandersFrames and ImportCondenser.DandersFrames.IsLoaded and ImportCondenser.DandersFrames:IsLoaded())
                        end,
                        inline = true,
                        args = {
                            status = {
                                type = "description",
                                name = "Danders Frames profile will be exported.",
                                order = 1,
                            },
                        },
                    },
                },
            },
        },
    }

    AceConfig:RegisterOptionsTable(ADDON_NAME, options)
    AceConfigDialog:AddToBlizOptions(ADDON_NAME, ADDON_NAME)
end


function ImportCondenser:Import(importStr)
    -- Attempt to parse and import immediately upon setting
    local result = C_EncodingUtil.DeserializeJSON(importStr)
    if result and type(result) == "table" then
        local profileName = result.profileName or "ImportedProfile"
        print("Starting import for profile: " .. profileName)

        if result["NephUI"] then
            ImportCondenser.NephUI:Import(profileName, result["NephUI"])
        end

        if result["EditMode"] and C_EditMode then
            ImportCondenser.EditMode:Import(result["EditMode"], profileName)
        end

        if result["Platynator"] then
            ImportCondenser.Platynator:Import(result["Platynator"], profileName)
        end

        if result["Baganator"] then
            ImportCondenser.Baganator:Import(result["Baganator"], profileName)
        end

        if result["Plater"] then
            ImportCondenser.Plater:Import(result["Plater"], profileName)
        end

        if result["Details"] then
            ImportCondenser.Details:Import(result["Details"], profileName)
        end

        if result["Bartender"] then
            ImportCondenser.Bartender:Import(result["Bartender"], profileName)
        end

        if result["TwintopInsanityBar"] then
            ImportCondenser.TwintopInsanityBar:Import(result["TwintopInsanityBar"], profileName)
        end

        if result["DandersFrames"] then
            ImportCondenser.DandersFrames:Import(result["DandersFrames"], profileName)
        end

        print("Import successful for profile: " .. profileName)
    else
        print("Import failed: " .. (err or "Invalid format."))
    end
end


function ImportCondenser:GenerateExportString()
    local profileName = self.db.global.profileName or "DefaultProfile"
    local exports = {profileName = profileName}

    ImportCondenser.NephUI:Export(exports)
    ImportCondenser.Platynator:Export(exports)
    ImportCondenser.Baganator:Export(exports)
    ImportCondenser.Plater:Export(exports)
    ImportCondenser.Details:Export(exports)
    ImportCondenser.Bartender:Export(exports)
    ImportCondenser.TwintopInsanityBar:Export(exports)
    ImportCondenser.DandersFrames:Export(exports)
    ImportCondenser.EditMode:Export(exports)

    return C_EncodingUtil.SerializeJSON(exports)
end

function ImportCondenser:DisplayTextFrame(title, text)
    local AceGUI = LibStub("AceGUI-3.0")

    local frame = AceGUI:Create("Frame")
    frame:SetTitle(title)
    frame:SetLayout("Flow")
    frame:SetWidth(500)
    frame:SetHeight(200)

    local editbox = AceGUI:Create("MultiLineEditBox")
    editbox:SetLabel(title)
    editbox:SetText(text)
    editbox:SetFullWidth(true)
    editbox:SetNumLines(8)
    editbox:DisableButton(true)
    editbox:SetFocus()
    editbox:HighlightText()
    frame:AddChild(editbox)

    -- Close export window when Enter is pressed
    editbox.editBox:SetScript("OnEnterPressed", function()
        frame:Release()
    end)

    -- Close export window when main config window closes
    local aceConfigDialog = AceConfigDialog
    local function closeExportOnConfigHide()
        if frame and frame.Release then frame:Release() end
    end
    -- Hook AceConfigDialog's OnHide for our options frame
    local blizFrame = aceConfigDialog.OpenFrames and aceConfigDialog.OpenFrames[ADDON_NAME] and aceConfigDialog.OpenFrames[ADDON_NAME].frame
    if blizFrame then
        blizFrame:HookScript("OnHide", closeExportOnConfigHide)
    end
end

-- Show export window for NephUI profile
function ImportCondenser:ShowExportWindow()
    local exportStr = self:GenerateExportString()

    self:DisplayTextFrame("Export", exportStr)
end

function ImportCondenser:AddToInspector(data, strName)
	if DevTool and self.DEBUG then
		DevTool:AddData(data, strName)
	end
end

function ImportCondenser:DeSeriPressCode(inputStr)
    local AceSerializer = LibStub("AceSerializer-3.0", true)
    local LibDeflate = LibStub("LibDeflate", true)

    if AceSerializer and LibDeflate then
        -- Decode, decompress, and deserialize
        local decoded = LibDeflate:DecodeForPrint(inputStr)
        if not decoded then
            print("Error: Failed to decode import string")
            return nil
        end

        local decompressed = LibDeflate:DecompressDeflate(decoded)
        if not decompressed then
            print("Error: Failed to decompress data")
            return nil
        end

        local success, importProfile = AceSerializer:Deserialize(decompressed)
        if not success or not importProfile then
            print("Error: Failed to deserialize profile")
            return nil
        end

        return importProfile
    else
        print("Error: Required libraries for serialization are missing.")
        return nil
    end
end

function ImportCondenser:SeriPressCode(dataTable)
    local AceSerializer = LibStub("AceSerializer-3.0", true)
    local LibDeflate = LibStub("LibDeflate", true)

    if AceSerializer and LibDeflate then
        -- Serialize, compress, and encode
        local serialized = AceSerializer:Serialize(dataTable)
        local compressed = LibDeflate:CompressDeflate(serialized)
        local encoded = LibDeflate:EncodeForPrint(compressed)

        return encoded
    else
        print("Error: Required libraries for serialization are missing.")
        return nil
    end
end
function ImportCondenser:CopyTable(src, dest)
	if type(dest) ~= "table" then dest = {} end
	if type(src) == "table" then
		for k,v in pairs(src) do
			if type(v) == "table" then
				v = self:CopyTable(v, dest[k])
			end
			dest[k] = v
		end
	end
	return dest
end