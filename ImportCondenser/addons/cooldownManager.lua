local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.CooldownManager = {}

function ImportCondenser.CooldownManager:GetExportOptions()
    return {"Export"}, {}, true
end

function ImportCondenser.CooldownManager:DetectIssues(importString)
    if importString and importString ~= "" then
        return {
            message = "Warning: Importing will overwrite all of your Cooldown Manager layouts for this Character.",
            options = {"Import"},
        }
    end
    return nil
end

function ImportCondenser.CooldownManager:Import(importString, profileName)
    if ImportCondenser.db.global.CooldownManager.selectedImportOptions["import"] then
        C_CooldownViewer.SetLayoutData(importString, profileName)
    end
end

function ImportCondenser.CooldownManager:Export(exports)
    local layout = C_CooldownViewer.GetLayoutData()
    if layout and ImportCondenser.db.global.CooldownManager.selectedExportOptions["export"] then
        exports["CooldownManager"] = layout
    end
end
