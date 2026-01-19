local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.CooldownViewer = {}

function ImportCondenser.CooldownViewer:DetectIssues(importString)
    return nil
end

function ImportCondenser.CooldownViewer:Import(importString, profileName)
    C_CooldownViewer.SetLayoutData(importString, profileName)
end

function ImportCondenser.CooldownViewer:Export(exports)
    local layout = C_CooldownViewer.GetLayoutData()
    if layout then
        exports["CooldownViewer"] = layout
    end
end
