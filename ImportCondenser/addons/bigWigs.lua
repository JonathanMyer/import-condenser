local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.BigWigs = {}

function ImportCondenser.BigWigs:GetExportOptions()
    return {"Export"}, {"Export"}, false
end

function ImportCondenser.BigWigs:Import(importString, profileName)
    local BW = _G.BigWigsAPI
    if importString and profileName and BW and type(BW.RegisterProfile) == "function" then
        BW.RegisterProfile("ImportCondenser", importString, profileName)
    end
end


function ImportCondenser.BigWigs:Export(table)
    if ImportCondenser.db.global.BigWigs.selectedExportOptions["Export"] ~= true then
        return
    end
    local BW = _G.BigWigsAPI
    if BW and type(BW.RequestProfile) == "function" then
        local profile = BW.RequestProfile("ImportCondenser")
        table["BigWigs"] = profile
    end
end
