local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon
local AceAddon = LibStub("AceAddon-3.0", true)
local AceDBOptions = LibStub("AceDBOptions-3.0", true)
local LibDualSpec   = LibStub("LibDualSpec-1.0", true)

ImportCondenser.NephUI = {}

function ImportCondenser.NephUI:IsLoaded()
    return C_AddOns and C_AddOns.IsAddOnLoaded("NephUI") or (IsAddOnLoaded and IsAddOnLoaded("NephUI"))
end

function ImportCondenser.NephUI:Import(profileName, importStr)
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

function ImportCondenser.NephUI:Export(exports)
    local NephUI = AceAddon and AceAddon:GetAddon("NephUI", true)
    if NephUI and type(NephUI.ExportProfileToString) == "function" then
        exports["NephUI"] = NephUI:ExportProfileToString()
    end

end
