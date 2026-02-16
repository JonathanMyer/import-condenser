local ADDON_NAME, ns          = ...
local ImportCondenser         = ns.Addon

ImportCondenser.BuffReminders = {}

function ImportCondenser.BuffReminders:GetExportOptions()
    return { "Export" }, { "Export" }, false
end

function ImportCondenser.BuffReminders:Import(importStr, profileName)
    local BR = _G.BuffReminders
    if BR and type(BR.Import) == "function" then
        BR:Import(importStr, profileName)
    end
end

function ImportCondenser.BuffReminders:Export(exports)
    if ImportCondenser.db.global.BuffReminders.selectedExportOptions["Export"] ~= true then return end
    local BR = _G.BuffReminders
    if BR and type(BR.Export) == "function" then
        exports["BuffReminders"] = BR:Export()
    end
end
