local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.BetterCooldownManager = {}
local realmKey = GetRealmName()
local charKey = UnitName("player") .. " - " .. realmKey

function ImportCondenser.BetterCooldownManager:GetExportOptions()
    return {"Export"}, {"Export"}, false
end

function ImportCondenser.BetterCooldownManager:Import(importString, profileName)
    local BCDMdb = _G.BCDMDB 
    if type(_G.BCDMG) == "table" and type(_G.BCDMG.ImportBCDM) == "function" then
        _G.BCDMG:ImportBCDM(importString, profileName)
        if BCDMdb and BCDMdb.global and BCDMdb.global.UseGlobalProfile then
            BCDMdb.global.GlobalProfile = profileName
        end
    end
end


function ImportCondenser.BetterCooldownManager:Export(table)
    local BCDMdb = _G.BCDMDB
    if ImportCondenser.db.global.BetterCooldownManager.selectedExportOptions["Export"] ~= true then
        return
    end
    if BCDMdb and BCDMdb.profileKeys and charKey and type(_G.BCDMG) == "table" and type(_G.BCDMG.ExportBCDM) == "function" then
        local profileName = BCDMdb.profileKeys[charKey]
        table["BetterCooldownManager"] = _G.BCDMG:ExportBCDM(profileName)
    end
end
