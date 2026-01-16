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
            header = {
                type = "header",
                name = "Import/Export Settings",
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
                order = 3,
            },
            reloadUi = {
                type = "execute",
                name = "Reload UI",
                desc = "Reload the user interface to apply changes.",
                func = function()
                    ReloadUI()
                end,
                order = 4,
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
            ImportCondenser:ImportNephUI(profileName, result["NephUI"])
        end

        if result["EditMode"] and C_EditMode then
            ImportCondenser:ImportEditMode(result["EditMode"], profileName)
        end

        if result["Platynator"] then
            ImportCondenser:ImportPlatynator(result["Platynator"], profileName)
        end

        if result["Baganator"] then
            ImportCondenser:ImportBaganator(result["Baganator"], profileName)
        end

        if result["Plater"] then
            ImportCondenser:ImportPlater(result["Plater"], profileName)
        end

        if result["Details"] then
            ImportCondenser:ImportDetails(result["Details"], profileName)
        end

        if result["Bartender"] then
            ImportCondenser:ImportBartender(result["Bartender"], profileName)
        end

        print("Import successful for profile: " .. profileName)
    else
        print("Import failed: " .. (err or "Invalid format."))
    end
end


function ImportCondenser:GenerateExportString()
    local profileName = self.db.global.profileName or "DefaultProfile"
    local exports = {profileName = profileName}

    ImportCondenser:ExportNephUI(exports)
    ImportCondenser:ExportPlatynator(exports)
    ImportCondenser:ExportBaganator(exports)
    ImportCondenser:ExportPlater(exports)
    ImportCondenser:ExportDetails(exports)
    ImportCondenser:ExportBartender(exports)
    ImportCondenser:ExportEditMode(exports)

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