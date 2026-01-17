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

function ImportCondenser:IsAddonLoaded(addonName)
    if addonName == "EditMode" then
        return C_EditMode ~= nil
    end
    return C_AddOns and C_AddOns.IsAddOnLoaded(addonName) or (IsAddOnLoaded and IsAddOnLoaded(addonName))
end


function ns.GenerateSection(addonName, order)
    return {
        type = "group",
        name = addonName,
        order = order,
        hidden = function() 
            return not ImportCondenser:IsAddonLoaded(addonName)
        end,
        inline = true,
        args = {
            status = {
                type = "description",
                name = "Loaded",
                order = 1,
            },
            parsed = {
                type = "description",
                name = "Something",
                order = 2,
            },
        },
    }
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
                            ImportCondenser:ParseImportString(value)
                        end,
                        order = 1,
                    },
                    Import = {
                        type = "execute",
                        name = "Import",
                        desc = "Import the pasted profile string.",
                        width = "half",
                        func = function()
                            ImportCondenser:Import()
                        end,
                        order = 2,
                    },
                    reloadUi = {
                        type = "execute",
                        name = "Reload UI",
                        desc = "Reload the user interface to apply changes.",
                        width = "half",
                        func = function()
                            ReloadUI()
                        end,
                        order = 2,
                    },
                    nephUISection = ns.GenerateSection("NephUI", 3),
                    editModeSection = ns.GenerateSection("EditMode", 4),
                    platynatorSection = ns.GenerateSection("Platynator", 5),
                    baganatorSection = ns.GenerateSection("Baganator", 6),
                    platerSection = ns.GenerateSection("Plater", 7),
                    detailsSection = ns.GenerateSection("Details", 8),
                    bartenderSection = ns.GenerateSection("Bartender4", 9),
                    twintopInsanityBarSection = ns.GenerateSection("TwintopInsanityBar", 10),
                    dandersFramesSection = ns.GenerateSection("DandersFrames", 11),
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
                    nephUISection = ns.GenerateSection("NephUI", 3),
                    editModeSection = ns.GenerateSection("EditMode", 4),
                    platynatorSection = ns.GenerateSection("Platynator", 5),
                    baganatorSection = ns.GenerateSection("Baganator", 6),
                    platerSection = ns.GenerateSection("Plater", 7),
                    detailsSection = ns.GenerateSection("Details", 8),
                    bartenderSection = ns.GenerateSection("Bartender4", 9),
                    twintopInsanityBarSection = ns.GenerateSection("TwintopInsanityBar", 10),
                    dandersFramesSection = ns.GenerateSection("DandersFrames", 11),
                },
            },
        },
    }

    AceConfig:RegisterOptionsTable(ADDON_NAME, options)
    AceConfigDialog:AddToBlizOptions(ADDON_NAME, ADDON_NAME)
end

function ImportCondenser:ParseImportString(importStr)
    self.db.global.ImportedStrings = C_EncodingUtil.DeserializeJSON(importStr)
end

function ImportCondenser:Import()
    for key, value in pairs(self.db.global.ImportedStrings) do
        print("Key: " .. tostring(key))
    end
    if self.db.global.ImportedStrings and type(self.db.global.ImportedStrings) == "table" then
        local profileName = self.db.global.ImportedStrings.profileName or "ImportedProfile"
        print("Starting import for profile: " .. profileName)

        if self.db.global.ImportedStrings["NephUI"] then
            ImportCondenser.NephUI:Import(profileName, self.db.global.ImportedStrings["NephUI"])
        end

        if self.db.global.ImportedStrings["EditMode"] and C_EditMode then
            ImportCondenser.EditMode:Import(self.db.global.ImportedStrings["EditMode"], profileName)
        end

        if self.db.global.ImportedStrings["Platynator"] then
            ImportCondenser.Platynator:Import(self.db.global.ImportedStrings["Platynator"], profileName)
        end

        if self.db.global.ImportedStrings["Baganator"] then
            ImportCondenser.Baganator:Import(self.db.global.ImportedStrings["Baganator"], profileName)
        end

        if self.db.global.ImportedStrings["Plater"] then
            ImportCondenser.Plater:Import(self.db.global.ImportedStrings["Plater"], profileName)
        end

        if self.db.global.ImportedStrings["Details"] then
            ImportCondenser.Details:Import(self.db.global.ImportedStrings["Details"], profileName)
        end

        if self.db.global.ImportedStrings["Bartender"] then
            ImportCondenser.Bartender:Import(self.db.global.ImportedStrings["Bartender"], profileName)
        end

        if self.db.global.ImportedStrings["TwintopInsanityBar"] then
            ImportCondenser.TwintopInsanityBar:Import(self.db.global.ImportedStrings["TwintopInsanityBar"], profileName)
        end

        if self.db.global.ImportedStrings["DandersFrames"] then
            ImportCondenser.DandersFrames:Import(self.db.global.ImportedStrings["DandersFrames"], profileName)
        end

        print("Import successful for profile: " .. profileName)
    else
        print("Import failed: " .. (err or "Invalid format."))
    end
end


function ImportCondenser:GenerateExportString()
    local profileName = self.db.global.profileName or "DefaultProfile"
    local exports = {profileName = profileName}

    print("Exporting")
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
