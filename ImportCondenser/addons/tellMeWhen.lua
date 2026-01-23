local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon
local AceAddon = LibStub("AceAddon-3.0", true)
local LibDualSpec   = LibStub("LibDualSpec-1.0", true)

ImportCondenser.TellMeWhen = {}

function ImportCondenser.TellMeWhen:GetExportOptions()
    return {"Export"}, {"Export"}, false
end

function ImportCondenser.TellMeWhen:Import(importStr, profileName)
    local TMW = AceAddon and AceAddon:GetAddon("TellMeWhen", true)
    if not TMW then
        return
    end

    local combined = ImportCondenser:DeSeriPressCode(importStr)
    if combined and TMW and TMW.db then
        TMW.db.SetProfile(TMW.db, profileName)
        TMW.db.profiles[profileName] = combined.profile or TMW.db.profile
        TMW.db.global = combined.global or TMW.db.global
    end
end

function ImportCondenser.TellMeWhen:Export(exports)
    if ImportCondenser.db.global.TellMeWhen.selectedExportOptions["Export"] ~= true then return end
    local TMW = AceAddon and AceAddon:GetAddon("TellMeWhen", true)
    if TMW and TMW.db and TMW.db.profile then
        local profile = TMW.db.profile
        local global = TMW.db.global
        exports["TellMeWhen"] = ImportCondenser:SeriPressCode({
            profile = profile,
            global = global,
        })
    end
end

