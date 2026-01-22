local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon
local AceAddon = LibStub("AceAddon-3.0", true)

ImportCondenser.HealthBarColor = {}

function ImportCondenser.HealthBarColor:Import(importStr, profileName)
    local TMW = AceAddon and AceAddon:GetAddon("HealthBarColor", true)
    if not TMW then
        return
    end

    local profile = ImportCondenser:DeSeriPressCode(importStr)
    if profile and TMW and TMW.db then
        TMW.db.SetProfile(TMW.db, profileName)
        TMW.db.profiles[profileName] = profile or TMW.db.profile
    end
end

function ImportCondenser.HealthBarColor:Export(exports)
    local HBC = AceAddon and AceAddon:GetAddon("HealthBarColor", true)
    if HBC and HBC.db and HBC.db.profile then
        local profile = HBC.db.profile
        exports["HealthBarColor"] = ImportCondenser:SeriPressCode(
            profile
        )
    end
end

