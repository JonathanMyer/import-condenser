local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.CooldownManager = {}

function ImportCondenser.CooldownManager:GetExportOptions()
    return { "Export" }, {}, false
end

function ImportCondenser.CooldownManager:DetectIssues(importString)
    if importString and importString ~= "" then
        return {
            message = "Warning: Importing will overwrite all of your Cooldown Manager layouts for this Character.",
        }
    end
    return nil
end

function ImportCondenser.CooldownManager:Import(importString, profileName)
    C_CooldownViewer.SetLayoutData(importString, profileName)
end

function ImportCondenser.CooldownManager:Export(exports)
    if ImportCondenser.db.global.CooldownManager.selectedExportOptions["Export"] ~= true then return end
    local layout = C_CooldownViewer.GetLayoutData()
    if layout then
        exports["CooldownManager"] = layout
    end
end
