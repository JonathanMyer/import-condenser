local ADDON_NAME, ns = ...
ns = ns or {}

local ImportCondenser = ns.Addon
if not ImportCondenser then
    return
end

local AceConfigRegistry = ns.AceConfigRegistry

function ImportCondenser:ParseImportString(importStr)
    local importPrefix = ns.importPrefix or "1:ImportCondenser:"

    if importStr:sub(1, #importPrefix) == importPrefix then
        importStr = importStr:sub(#importPrefix + 1)
        self.db.global.ImportedStrings = ImportCondenser:DeSeriPressCode(importStr)
    else
        self.db.global.ImportedStrings = C_EncodingUtil.DeserializeJSON(importStr)
    end

    if ns.SetupOptions then
        ns.SetupOptions(self)
    end

    if AceConfigRegistry then
        AceConfigRegistry:NotifyChange(ADDON_NAME)
    end
end

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
    if not (self.db and self.db.global and self.db.global.ImportedStrings and type(self.db.global.ImportedStrings) == "table") then
        print("Import failed: Invalid format.")
        return
    end

    local importedStrings = self.db.global.ImportedStrings
    local profileName = (self.db.global.importProfileName ~= "" and self.db.global.importProfileName) or importedStrings.profileName or "ImportedProfile"
    print("Starting import for profile: " .. profileName)

    local addons = ns.addons or {}
    for _, addonName in ipairs(addons) do
        local addonPayload = importedStrings[addonName]
        if addonPayload then
            local addonModule = ImportCondenser[addonName]

            local addonDb = self.db.global[addonName]
            if not addonDb then
                addonDb = {}
                self.db.global[addonName] = addonDb
            end
            if addonDb.shouldImport == nil then
                addonDb.shouldImport = true
            end

            if addonModule and addonModule.Import and addonDb.shouldImport then
                print("Importing settings for addon: " .. addonName)
                addonModule:Import(addonPayload, profileName)
            end
        end
    end

    print("Import successful for profile: " .. profileName)
    StaticPopup_Show("IMPORTCONDENSER_RELOAD_UI")
end
