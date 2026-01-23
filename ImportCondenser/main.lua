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
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local addons = {}

function ImportCondenser:GetAddonModules()
    if #addons == 0 then
        -- Dynamically discover addon modules
        for key, value in pairs(ImportCondenser) do
            if type(value) == "table" and value.Import and value.Export then
                table.insert(addons, key)
            end
        end
        -- Sort with DetectIssues addons first, then alphabetically
        table.sort(addons, function(a, b)
            local aHasDetect = ImportCondenser[a] and ImportCondenser[a].DetectIssues ~= nil
            local bHasDetect = ImportCondenser[b] and ImportCondenser[b].DetectIssues ~= nil
            
            if aHasDetect ~= bHasDetect then
                return aHasDetect -- a comes first if it has DetectIssues
            end
            return a < b -- Otherwise sort alphabetically
        end)
    end
    return addons
end

function ImportCondenser:OnInitialize()
    -- Called when the addon is loaded
    self.db = LibStub("AceDB-3.0"):New("ImportCondenserDB", ns.defaults or {}, true)

    if LibDualSpec then
        LibDualSpec:EnhanceDatabase(self.db, "ImportCondenser")
    end

    -- Clear ImportedStrings on every reload
    self.db.global.ImportedStrings = nil

    -- Discover addon modules
    self:GetAddonModules()

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
    if addonName == "CooldownManager" then
        return C_CooldownViewer ~= nil
    end
    return C_AddOns and C_AddOns.IsAddOnLoaded(addonName) or (IsAddOnLoaded and IsAddOnLoaded(addonName))
end

function ns.GenerateImportSection(addonName, order)
    return {
        type = "group",
        name = "",
        inline = true,
        order = order,
        args = {
            addon = {
                type = "description",
                name = addonName,
                width = 0.7,
                order = 1,
            },
            loaded = {
                type = "description",
                name = function()
                    return ImportCondenser:IsAddonLoaded(addonName) and "|cff00ff00Loaded|r" or "|cffff0000Not Loaded|r"
                end,
                width = 0.5,
                order = 2,
            },
            parsed = {
                type = "description",
                name = function()
                    local addonModule = ImportCondenser[addonName]
                    local readyToImport = ImportCondenser:IsAddonLoaded(addonName) and
                        ImportCondenser.db and
                        ImportCondenser.db.global.ImportedStrings and
                        ImportCondenser.db.global.ImportedStrings[addonName] ~= nil and
                        addonModule ~= nil
                    if readyToImport and addonModule and addonModule.DetectIssues then
                        local issues = addonModule:DetectIssues(ImportCondenser.db.global.ImportedStrings[addonName])
                        if issues and type(issues) == "string" then
                            return "|cffff0000" .. issues .. "|r"
                        elseif issues and type(issues) == "table" and #issues.options and #issues.options > 0 then
                            return issues.message and "|cffffff00" .. issues.message .. "|r" or "|cffffff00Options available|r"
                        end
                    end
                    return readyToImport and "|cff00ff00Ready to Import|r" or "|cffaaaaaa---"
                end,
                width = "fill",
                order = 3,
            },
            options = {
                type = "group",
                name = "",
                inline = true,
                order = 4,
                args = (function()
                    local addonModule = ImportCondenser[addonName]
                    local checkboxArgs = {}
                    if addonModule and addonModule.DetectIssues then
                        local issues = addonModule:DetectIssues(ImportCondenser.db.global.ImportedStrings and ImportCondenser.db.global.ImportedStrings[addonName] or "")
                        if issues and issues.options and type(issues.options) == "table" and #issues.options > 0 then
                            local storeAsLower = issues.storeAsLower
                            local defaults = issues.defaults or {}
                            if storeAsLower == nil then
                                storeAsLower = true
                            end
                            local addonDb = ImportCondenser.db.global[addonName]
                            if not addonDb then
                                ImportCondenser.db.global[addonName] = {}
                                addonDb = ImportCondenser.db.global[addonName]
                            end

                            local playerClass = select(1, UnitClass("player"))
                            
                            -- Initialize selectedOptions table if it doesn't exist
                            if not addonDb.selectedImportOptions then
                                addonDb.selectedImportOptions = {}
                                if defaults and type(defaults) == "table" then
                                    for _, defaultOption in ipairs(defaults) do
                                        addonDb.selectedImportOptions[storeAsLower and defaultOption:lower() or defaultOption] = true
                                    end
                                end
                            end
                            
                            for i, option in ipairs(issues.options) do
                                local optionName = type(option) == "table" and option.name or option
                                local optionDesc = type(option) == "table" and option.desc or ""
                                
                                checkboxArgs["option" .. i] = {
                                    type = "toggle",
                                    name = optionName,
                                    desc = optionDesc,
                                    get = function()
                                        return addonDb.selectedImportOptions[storeAsLower and optionName:lower() or optionName] or false
                                    end,
                                    set = function(info, value)
                                        addonDb.selectedImportOptions[storeAsLower and optionName:lower() or optionName] = value
                                    end,
                                    width = .75,
                                    order = i,
                                }
                            end
                        end
                    end
                    return checkboxArgs
                end)(),
            },
        },
    }
end

function ns.GenerateExportSection(addonName, order)
    return {
        type = "group",
        name = addonName,
        hidden = function()
            local addonModule = ImportCondenser[addonName]
            if addonModule and addonModule.GetExportOptions then
                return not ImportCondenser:IsAddonLoaded(addonName)
            end
            return true
        end,
        inline = true,
        order = order,
        args = (function()
            local addonModule = ImportCondenser[addonName]
            local addonDb = ImportCondenser.db.global[addonName]
            if not addonModule or not addonModule.GetExportOptions then
                return {}
            end
            
            -- Initialize addon namespace if it doesn't exist
            if not addonDb then
                ImportCondenser.db.global[addonName] = {}
                addonDb = ImportCondenser.db.global[addonName]
            end
            
            local options, defaults, storeAsLower = addonModule:GetExportOptions()
            if storeAsLower == nil then
                storeAsLower = true
            end
            if not options or type(options) ~= "table" then
                return {}
            end

            -- Initialize selectedOptions table if it doesn't exist
            -- uncoment the next line to test.
            -- addonDb.selectedExportOptions = nil
            if not addonDb.selectedExportOptions then
                addonDb.selectedExportOptions = {}
                if defaults and type(defaults) == "table" then
                    for _, defaultOption in ipairs(defaults) do
                        addonDb.selectedExportOptions[storeAsLower and defaultOption:lower() or defaultOption] = true
                    end
                end
            end
            
            local checkboxArgs = {}
            for i, option in ipairs(options) do
                local optionName = type(option) == "table" and option.name or option
                local optionDesc = type(option) == "table" and option.desc or ""
                
                checkboxArgs["option" .. i] = {
                    type = "toggle",
                    name = optionName,
                    desc = optionDesc,
                    get = function()
                        return addonDb.selectedExportOptions[storeAsLower and optionName:lower() or optionName] or false
                    end,
                    set = function(info, value)
                        addonDb.selectedExportOptions[storeAsLower and optionName:lower() or optionName] = value
                    end,
                    width = .75,
                    order = i,
                }
            end
            return checkboxArgs
        end)(),
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
                    importProfileName = {
                        type = "input",
                        name = "Import Profile Name Override",
                        desc = "Enter a name for the imported profile.",
                        get = function(info)
                            return self.db.global.importProfileName or nil
                        end,
                        set = function(info, value)
                            self.db.global.importProfileName = value
                        end,
                        order = 0.5,
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
                    addonGroup = {
                        type = "group",
                        name = "Addons                     Status              Parse Status",
                        inline = true,
                        order = 3,
                        args = (function()
                            local args = {}
                            for i, addonName in ipairs(addons) do
                                args[addonName .. "Section"] = ns.GenerateImportSection(addonName, i)
                            end
                            return args
                        end)(),
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
                    addonGroup = {
                        type = "group",
                        name = "Export Options",
                        inline = true,
                        order = 3,
                        args = (function()
                            local args = {}
                            for i, addonName in ipairs(addons) do
                                args[addonName .. "Section"] = ns.GenerateExportSection(addonName, i)
                            end
                            return args
                        end)(),
                    },
                },
            },
        },
    }

    AceConfig:RegisterOptionsTable(ADDON_NAME, options)
    
    -- Only add to Blizzard options the first time
    if not ns.blizOptionsAdded then
        AceConfigDialog:AddToBlizOptions(ADDON_NAME, ADDON_NAME)
        ns.blizOptionsAdded = true
    end
end

local importPrefix = "1:ImportCondenser:"

function ImportCondenser:ParseImportString(importStr)
    if importStr:sub(1, #importPrefix) == importPrefix then
        importStr = importStr:sub(#importPrefix + 1)
        self.db.global.ImportedStrings = ImportCondenser:DeSeriPressCode(importStr)
    else
        self.db.global.ImportedStrings = C_EncodingUtil.DeserializeJSON(importStr)
    end
    -- Rebuild options table to regenerate import sections
    ns.SetupOptions(self)
    -- Refresh the UI to show updated parse status
    AceConfigRegistry:NotifyChange(ADDON_NAME)
end

-- Define static popup for reload UI prompt
StaticPopupDialogs["IMPORTCONDENSER_RELOAD_UI"] = {
    text = "Import successful! Please reload your UI to avoid issues.",
    button1 = "Reload",
    button2 = "Cancel",
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function ImportCondenser:Import()
    if self.db.global.ImportedStrings and type(self.db.global.ImportedStrings) == "table" then
        local profileName = self.db.global.importProfileName ~= "" and self.db.global.importProfileName or self.db.global.ImportedStrings.profileName or "ImportedProfile"
        print("Starting import for profile: " .. profileName)

        for _, addonName in ipairs(addons) do
            if self.db.global.ImportedStrings[addonName] then
                local addonModule = ImportCondenser[addonName]
                if addonModule and addonModule.Import then
                    addonModule:Import(self.db.global.ImportedStrings[addonName], profileName)
                end
            end
        end

        print("Import successful for profile: " .. profileName)
        StaticPopup_Show("IMPORTCONDENSER_RELOAD_UI")
    else
        print("Import failed: " .. (err or "Invalid format."))
    end
end


function ImportCondenser:GenerateExportString()
    local profileName = self.db.global.profileName or "DefaultProfile"
    local exports = {profileName = profileName}
    for _, addonName in ipairs(addons) do
        local addonModule = ImportCondenser[addonName]
        if addonModule and addonModule.Export then
            addonModule:Export(exports)
        end
    end
    return importPrefix .. ImportCondenser:SeriPressCode(exports)
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


function ImportCondenser:CountKeys(table)
    if not table then
        return 0
    end
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

ImportCondenser.ClassNames = {
    [1] = "Warrior",
    [2] = "Paladin",
    [3] = "Hunter",
    [4] = "Rogue",
    [5] = "Priest",
    [6] = "DeathKnight",
    [7] = "Shaman",
    [8] = "Mage",
    [9] = "Warlock",
    [10] = "Monk",
    [11] = "Druid",
    [12] = "DemonHunter",
    [13] = "Evoker"
}
	