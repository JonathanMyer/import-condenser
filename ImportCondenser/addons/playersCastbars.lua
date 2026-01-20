local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon
local AceAddon = LibStub("AceAddon-3.0", true)

ImportCondenser.PlayersCastbars = {}

function ImportCondenser.PlayersCastbars:Import(importStr, profileName)
    local allProfs = ImportCondenser:DeSeriPressCode(importStr)
    local PlayersCastbars = AceAddon and AceAddon:GetAddon("PlayersCastbars", true)
    if PlayersCastbars and PlayersCastbars.db and PlayersCastbars.db.profile and allProfs and allProfs.profile then
        PlayersCastbars.db.profile = allProfs.profile or PlayersCastbars.db.profile
    end
    if _G.TarSaves and allProfs and allProfs.target then
        _G.TarSaves = allProfs.target or _G.TarSaves
    end
    if _G.FocusSaves and allProfs and allProfs.focus then
        _G.FocusSaves = allProfs.focus or _G.FocusSaves
    end
end

function ImportCondenser.PlayersCastbars:Export(exports)
    local PlayersCastbars = AceAddon and AceAddon:GetAddon("PlayersCastbars", true)
    if not PlayersCastbars then
        return
    end
    local profile = {}
    local target = {}
    local focus = {}
    if PlayersCastbars and PlayersCastbars.db and PlayersCastbars.db.profile then
        profile = PlayersCastbars.db.profile
    end
    if _G.TarSaves then
        target = _G.TarSaves 
    end
    if _G.FocusSaves then
        focus = _G.FocusSaves 
    end
    local combinedProfs = {
        profile = profile,
        target = target,
        focus = focus,
    }
    exports["PlayersCastbars"] = ImportCondenser:SeriPressCode(combinedProfs)
end
