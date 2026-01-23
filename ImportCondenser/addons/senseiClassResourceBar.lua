local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.SenseiClassResourceBar = {}

function ImportCondenser.SenseiClassResourceBar:GetExportOptions()
    return {"Export"}, {"Export"}, false
end

function ImportCondenser.SenseiClassResourceBar:Import(importString)
    local SCRB = _G.SCRB
    if importString and SCRB and type(SCRB.importProfileFromString) == "function" then
        SCRB.importProfileFromString(importString)
    end
end


function ImportCondenser.SenseiClassResourceBar:Export(table)
    if ImportCondenser.db.global.SenseiClassResourceBar.selectedExportOptions["Export"] ~= true then return end
    local SCRB = _G.SCRB
    if SCRB and type(SCRB.exportProfileAsString) == "function" then
        local profile = SCRB.exportProfileAsString(true, true)
        table["SenseiClassResourceBar"] = profile
    end
end
