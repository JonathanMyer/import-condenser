local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.SenseiClassResourceBar = {}

function ImportCondenser.SenseiClassResourceBar:Import(importString)
    local SCRB = _G.SCRB
    if importString and SCRB and type(SCRB.importProfileFromString) == "function" then
        SCRB.importProfileFromString(importString)
    end
end


function ImportCondenser.SenseiClassResourceBar:Export(table)
    local SCRB = _G.SCRB
    if SCRB and type(SCRB.exportProfileAsString) == "function" then
        local profile = SCRB.exportProfileAsString(true, true)
        table["SenseiClassResourceBar"] = profile
    end
end
