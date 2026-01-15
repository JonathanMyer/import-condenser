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


local AceDBOptions = LibStub("AceDBOptions-3.0", true)
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

function ImportCondenser:AddToInspector(data, strName)
	if DevTool and self.DEBUG then
		DevTool:AddData(data, strName)
	end
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
            local layout = C_EditMode.ConvertStringToLayoutInfo(result["EditMode"])
            layout.layoutName = profileName
            layout.layoutType = 1 -- set to account layout
            self:AddToInspector(layout, "Imported Layout")
            local layouts = C_EditMode.GetLayouts()
            self:AddToInspector(layouts, "EditMode Layouts Before Import")
            local maxLayoutID = 0
            if layouts and layouts.layouts then
                for k, _ in pairs(layouts.layouts) do
                    if type(k) == "number" and k > maxLayoutID then
                        maxLayoutID = k
                    end
                end
                self:AddToInspector(maxLayoutID, "maxLayoutID")
                layouts.layouts[maxLayoutID + 1] = layout
                self:AddToInspector(layouts, "EditMode Layouts After Import")
                C_EditMode.SaveLayouts(layouts)
                C_EditMode.SetActiveLayout(maxLayoutID + 3) -- need to add 3 because of the two default layouts
            end
        end

        if result["CooldownViewer"] and C_CooldownViewer then
            print("Importing CooldownViewer layout")
            C_CooldownViewer.SetLayoutData(result["CooldownViewer"])
        end

        if result["Platynatory"] then
            ImportCondenser:ImportPlatynatory(result["Platynatory"], profileName)
        end

        print("Import successful for profile: " .. profileName)
    else
        print("Import failed: " .. (err or "Invalid format."))
    end
end

function ImportCondenser:ImportNephUI(profileName, importStr)
    local NephUI = AceAddon and AceAddon:GetAddon("NephUI", true)

    local profileOptions
    if AceDBOptions and NephUI.db then
        profileOptions = AceDBOptions:GetOptionsTable(NephUI.db)
        -- Enhance profile options with LibDualSpec if available
        if LibDualSpec then
            LibDualSpec:EnhanceOptions(profileOptions, NephUI.db)
        end
    end

    local handler = profileOptions.handler
    handler.db.SetProfile(handler.db, profileName)

    if NephUI and type(NephUI.ImportProfileFromString) == "function" then
        NephUI:ImportProfileFromString(importStr)
    end
end

function ImportCondenser:ImportPlatynatory(importString, profileName)
    _G.PLATYNATOR_CONFIG = _G.PLATYNATOR_CONFIG or {}
    _G.PLATYNATOR_CONFIG.Profiles = _G.PLATYNATOR_CONFIG.Profiles or {}
    _G.PLATYNATOR_CONFIG.Profiles[profileName] = importString
    _G.PLATYNATOR_CURRENT_PROFILE = profileName
  end

function ImportCondenser:GenerateExportString()
    local profileName = self.db.global.profileName or "DefaultProfile"
    local exports = {profileName = profileName}

    -- NephUI
    local NephUI = AceAddon and AceAddon:GetAddon("NephUI", true)
    if NephUI and type(NephUI.ExportProfileToString) == "function" then
        exports["NephUI"] = NephUI:ExportProfileToString()
    end

    -- EditMode
    if C_EditMode and type(C_EditMode.GetLayouts) == "function" and type(C_EditMode.ConvertLayoutInfoToString) == "function" then
        local layouts = C_EditMode.GetLayouts()
        local layoutNumber = layouts and layouts.activeLayout
        if layouts and layouts.layouts then
            -- need to minus 2 because the first two layouts are default ones and are not returned by GetLayouts
            if layoutNumber and layouts.layouts[layoutNumber - 2] then
                local activeLayoutInfo = layouts.layouts[layoutNumber - 2]
                exports["EditMode"] = C_EditMode.ConvertLayoutInfoToString(activeLayoutInfo)
            end
        end
    end

    -- CooldownViewer
    if C_CooldownViewer and type(C_CooldownViewer.GetLayoutData) == "function" then
        local layout = C_CooldownViewer.GetLayoutData()
        if layout then
            exports["CooldownViewer"] = layout
        end
    end

    if _G.PLATYNATOR_CONFIG and _G.PLATYNATOR_CONFIG.Profiles then
        local platynatorProfile = _G.PLATYNATOR_CONFIG.Profiles[_G.PLATYNATOR_CURRENT_PROFILE]
        if platynatorProfile then
            exports["Platynatory"] = platynatorProfile
        end
    end

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

function ImportCondenser:ImportAddonSettings(addonName)
    -- Placeholder: Implement actual import logic here
    print("Importing settings for " .. (addonName or "Unknown Addon"))
end