local ADDON_NAME, ns = ...
ns = ns or {}

local ImportCondenser = ns.Addon
if not ImportCondenser then
    return
end

local AceConfig = ns.AceConfig
local AceConfigDialog = ns.AceConfigDialog

function ns.GenerateImportSection(addonName, order)
    local addonModule = ImportCondenser[addonName]

    local function getImportedAddonString()
        return ImportCondenser.db and
            ImportCondenser.db.global and
            ImportCondenser.db.global.ImportedStrings and
            ImportCondenser.db.global.ImportedStrings[addonName]
    end

    local function getAddonDb()
        if not (ImportCondenser.db and ImportCondenser.db.global) then
            return nil
        end
        local addonDb = ImportCondenser.db.global[addonName]
        if not addonDb then
            addonDb = {}
            ImportCondenser.db.global[addonName] = addonDb
        end
        return addonDb
    end

    local function getIssues()
        local imported = getImportedAddonString()
        if addonModule and addonModule.DetectIssues and imported then
            return addonModule:DetectIssues(imported)
        end
        return nil
    end

    local function ensureSelectedImportOptions(issues)
        if not (issues and type(issues) == "table") then
            return
        end
        if not (issues.options and type(issues.options) == "table" and #issues.options > 0) then
            return
        end

        local addonDb = getAddonDb()
        if not addonDb then
            return
        end

        local storeAsLower = issues.storeAsLower
        if storeAsLower == nil then
            storeAsLower = true
        end

        if addonDb.selectedImportOptions then
            return
        end

        addonDb.selectedImportOptions = {}
        local defaults = issues.defaults or {}
        if defaults and type(defaults) == "table" then
            for _, defaultOption in ipairs(defaults) do
                addonDb.selectedImportOptions[storeAsLower and defaultOption:lower() or defaultOption] = true
            end
        end
    end

    local imported = getImportedAddonString()
    local readyToImport = ImportCondenser:IsAddonLoaded(addonName) and
        imported ~= nil and
        addonModule ~= nil

    return {
        type = "group",
        name = "",
        inline = true,
        order = order,
        args = (function()
            return {
                addon = {
                    type = "description",
                    name = addonName,
                    width = 0.7,
                    order = 1,
                },
                loaded = {
                    type = "description",
                    name = function()
                        return ImportCondenser:IsAddonLoaded(addonName) and "|cff00ff00Loaded|r" or
                            "|cffff0000Not Loaded|r"
                    end,
                    width = 0.5,
                    order = 2,
                },
                parsed = {
                    type = "description",
                    name = function()
                        if readyToImport and addonModule and addonModule.DetectIssues then
                            local issues = getIssues()
                            if issues and type(issues) == "string" then
                                return "|cffff0000" .. issues .. "|r"
                            elseif issues and type(issues) == "table" and issues.message then
                                return issues.message and "|cffffff00" .. issues.message .. "|r" or
                                    "|cffffff00Options available|r"
                            end
                        end
                        return readyToImport and "|cff00ff00Ready to Import|r" or "|cffaaaaaa---"
                    end,
                    width = "fill",
                    order = 3,
                },
                shouldImport = {
                    type = "toggle",
                    name = "Import?",
                    desc = "Do you want to import settings for " .. addonName .. "?",
                    hidden = function()
                        return not readyToImport
                    end,
                    disabled = function()
                        return not readyToImport
                    end,
                    get = function()
                        if not readyToImport then
                            return false
                        end
                        local addonDb = getAddonDb()
                        if not addonDb then
                            return false
                        end
                        if addonDb.shouldImport == nil then
                            addonDb.shouldImport = true
                        end
                        return addonDb.shouldImport
                    end,
                    set = function(info, value)
                        if not readyToImport then
                            return
                        end
                        local addonDb = getAddonDb()
                        if not addonDb then
                            return
                        end
                        addonDb.shouldImport = value
                    end,
                    width = .75,
                    order = 3.5,
                },
                options = {
                    type = "group",
                    name = "",
                    inline = true,
                    order = 4,
                    args = (function()
                        local checkboxArgs = {}
                        local issues = getIssues()
                        if issues and issues.options and type(issues.options) == "table" and #issues.options > 0 then
                            ensureSelectedImportOptions(issues)

                            local storeAsLower = issues.storeAsLower
                            if storeAsLower == nil then
                                storeAsLower = true
                            end
                            local addonDb = getAddonDb()
                            if not addonDb then
                                return checkboxArgs
                            end

                            for i, option in ipairs(issues.options) do
                                local optionName = type(option) == "table" and option.name or option
                                local optionDesc = type(option) == "table" and option.desc or ""

                                checkboxArgs["option" .. i] = {
                                    type = "toggle",
                                    name = optionName,
                                    desc = optionDesc,
                                    get = function()
                                        return addonDb.selectedImportOptions
                                            [storeAsLower and optionName:lower() or optionName] or false
                                    end,
                                    set = function(info, value)
                                        addonDb.selectedImportOptions[storeAsLower and optionName:lower() or optionName] =
                                            value
                                    end,
                                    width = .75,
                                    order = i,
                                }
                            end
                        end
                        return checkboxArgs
                    end)(),
                },
            }
        end)(),
    }
end

function ns.GenerateExportSection(addonName, order)
    local addonModule = ImportCondenser[addonName]

    local function canShowExport()
        return addonModule and addonModule.GetExportOptions and ImportCondenser:IsAddonLoaded(addonName)
    end

    local function getAddonDb()
        if not (ImportCondenser.db and ImportCondenser.db.global) then
            return nil
        end
        local addonDb = ImportCondenser.db.global[addonName]
        if not addonDb then
            addonDb = {}
            ImportCondenser.db.global[addonName] = addonDb
        end
        return addonDb
    end

    local function normalizeKey(key, storeAsLower)
        return storeAsLower and key:lower() or key
    end

    local function getExportOptions()
        if not (addonModule and addonModule.GetExportOptions) then
            return nil
        end

        local options, defaults, storeAsLower = addonModule:GetExportOptions()
        if storeAsLower == nil then
            storeAsLower = true
        end
        if not options or type(options) ~= "table" then
            return nil
        end

        return options, defaults, storeAsLower
    end

    local function ensureSelectedExportOptions(addonDb, defaults, storeAsLower)
        if addonDb.selectedExportOptions then
            return
        end

        addonDb.selectedExportOptions = {}
        if defaults and type(defaults) == "table" then
            for key, defaultOption in pairs(defaults) do
                if type(key) == "number" then
                    addonDb.selectedExportOptions[normalizeKey(defaultOption, storeAsLower)] = true
                else
                    addonDb.selectedExportOptions[key] = normalizeKey(defaultOption, storeAsLower)
                end
            end
        end
    end

    return {
        type = "group",
        name = addonName,
        hidden = function()
            return not canShowExport()
        end,
        inline = true,
        order = order,
        args = (function()
            if not (addonModule and addonModule.GetExportOptions) then
                return {}
            end

            local addonDb = getAddonDb()
            if not addonDb then
                return {}
            end

            local options, defaults, storeAsLower = getExportOptions()
            if not options then
                return {}
            end

            ensureSelectedExportOptions(addonDb, defaults, storeAsLower)

            local checkboxArgs = {}
            for i, option in ipairs(options) do
                local optionName = type(option) == "table" and option.name or option
                local optionDesc = type(option) == "table" and option.desc or ""
                local normalizedKey = normalizeKey(optionName, storeAsLower)

                if type(option) == "table" then
                    checkboxArgs["option" .. i] = {
                        type = "select",
                        style = "dropdown",
                        name = optionName,
                        desc = optionDesc,
                        values = option.values,
                        get = function()
                            return addonDb.selectedExportOptions[normalizedKey] or 0
                        end,
                        set = function(info, value)
                            addonDb.selectedExportOptions[normalizedKey] = value
                        end,
                        width = .75,
                        order = i,
                    }
                else
                    checkboxArgs["option" .. i] = {
                        type = "toggle",
                        name = optionName,
                        desc = optionDesc,
                        get = function()
                            return addonDb.selectedExportOptions[normalizedKey] or false
                        end,
                        set = function(info, value)
                            addonDb.selectedExportOptions[normalizedKey] = value
                        end,
                        width = .75,
                        order = i,
                    }
                end
            end

            return checkboxArgs
        end)(),
    }
end

function ns.SetupOptions(self)
    local tempImportText = ""

    local options = {
        type = "group",
        name = "Import Condenser",
        childGroups = "tab",
        args = {
            importTab = {
                type = "group",
                name = "Import",
                desc = "Import addon profiles",
                childGroups = "tab",
                order = 1,
                args = {
                    importProfileName = {
                        type = "input",
                        name = "Profile Name Override",
                        desc =
                        "Enter a name for the imported profile. If empty, it will use the name that was in the export. Some addons do not support new profile names.",
                        get = function(info)
                            return self.db.global.importProfileName or nil
                        end,
                        set = function(info, value)
                            self.db.global.importProfileName = value
                        end,
                        order = 1,
                    },
                    importProfile = {
                        type = "input",
                        name = "Input String",
                        desc =
                        "Paste a profile string here to import. Only strings exported from this addon are supported.",
                        width = "full",
                        get = function()
                            return tempImportText
                        end,
                        set = function(info, value)
                            tempImportText = value
                            ImportCondenser:ParseImportString(value)
                        end,
                        order = .25,
                    },
                    Import = {
                        type = "execute",
                        name = "Import",
                        desc = "Import the pasted profile string.",
                        width = .5,
                        func = function()
                            ImportCondenser:Import()
                        end,
                        order = 2,
                    },
                    reloadUi = {
                        type = "execute",
                        name = "Reload UI",
                        desc = "Reload the user interface to apply changes.",
                        width = .5,
                        func = function()
                            ReloadUI()
                        end,
                        order = 2,
                    },
                    addonGroup = {
                        type = "group",
                        name = "Addons                     Status              Parse Status",
                        order = 3,
                        args = (function()
                            local args = {}
                            local addons = ns.addons or {}
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
                childGroups = "tab",
                args = {
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
                        order = 3,
                        args = (function()
                            local args = {}
                            local addons = ns.addons or {}
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

    if AceConfig then
        AceConfig:RegisterOptionsTable(ADDON_NAME, options)
    end

    if not ns.blizOptionsAdded and AceConfigDialog then
        AceConfigDialog:AddToBlizOptions(ADDON_NAME, ADDON_NAME)
        ns.blizOptionsAdded = true
    end
end
