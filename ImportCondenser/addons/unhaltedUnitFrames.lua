local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.UnhaltedUnitFrames = {}
local realmKey = GetRealmName()
local charKey = UnitName("player") .. " - " .. realmKey

function ImportCondenser.UnhaltedUnitFrames:Import(importString, profileName)
    local UUFdb = _G.UnhaltedUFDB 
    if type(_G.UUFG) == "table" and type(_G.UUFG.ImportUUF) == "function" then
        _G.UUFG:ImportUUF(importString, profileName)
        if UUFdb and UUFdb.global and UUFdb.global.UseGlobalProfile then
            UUFdb.global.GlobalProfile = profileName
        end
    end
end


function ImportCondenser.UnhaltedUnitFrames:Export(table)
    local UUFdb = _G.UnhaltedUFDB
    if UUFdb and UUFdb.profileKeys and charKey and type(_G.UUFG) == "table" and type(_G.UUFG.ExportUUF) == "function" then
        local profileName = UUFdb.profileKeys[charKey]
        table["UnhaltedUnitFrames"] = _G.UUFG:ExportUUF(profileName)
    end
end
