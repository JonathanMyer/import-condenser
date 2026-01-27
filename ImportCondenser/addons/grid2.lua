local ADDON_NAME, ns = ...
local ImportCondenser = ns.Addon

ImportCondenser.Grid2 = {}

local function sanitizeProfileName(profileName)
    if profileName == nil then
        return nil
    end

    local s = tostring(profileName)
    s = s:gsub("^%s+", ""):gsub("%s+$", "")
    if s == "" then
        return nil
    end

    -- Avoid breaking the export marker format.
    s = s:gsub("[%c%[%]]", " ")
    s = s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return s ~= "" and s or nil
end

local function InitializeGrid2Options()
    local LoadAddOn = C_AddOns and C_AddOns.LoadAddOn or LoadAddOn
    LoadAddOn("Grid2Options")
    if _G.Grid2 and type (_G.Grid2Options.Initialize) == "function" then
        _G.Grid2Options:Initialize()
    end
end

local function UpdateExportStringProfileName(exportString, newProfileName)
    if type(exportString) ~= "string" then
        return exportString
    end

    local sanitized = sanitizeProfileName(newProfileName)
    if not sanitized then
        return exportString
    end

    -- Grid2 exports are wrapped with markers like: [=== Main profile ===]
    -- Replace only the embedded profile name, not arbitrary occurrences.
    local updated = exportString:gsub("%[===%s*(.-)%s+profile%s+===%]", function()
        return "[=== " .. sanitized .. " profile ===]"
    end)

    return updated
end

function ImportCondenser.Grid2:GetExportOptions()
    return {"Export", "Custom Layouts"}, {"Export"}, false
end

function ImportCondenser.Grid2:DetectIssues(importTable)
    if importTable and type(importTable) == "table" and importTable.includeCustomLayouts then
        return {
            options = {"Custom Layouts"},
            message = "Options available.",
        }
    end
    return nil
end
    

function ImportCondenser.Grid2:Import(importTable, profileName)
    InitializeGrid2Options()
    local grid2Options = _G.Grid2Options
    if type(importTable) == "table" and
        importTable.data and
        type(grid2Options) == "table" and
        type(grid2Options.ImportCurrentProfile) == "function"
    then
        local includeCustomLayouts = ImportCondenser.db.global.Grid2.selectedImportOptions["Custom Layouts"] == true
        importTable.data = UpdateExportStringProfileName(importTable.data, profileName)
        grid2Options:ImportCurrentProfile(importTable.data, includeCustomLayouts)
    end
end


function ImportCondenser.Grid2:Export(table)
    if ImportCondenser.db.global.Grid2.selectedExportOptions["Export"] ~= true then
        return
    end
    InitializeGrid2Options()
    local grid2Options = _G.Grid2Options
    if grid2Options and  type(grid2Options.ExportCurrentProfile) == "function" then
        local includeCustomLayouts = ImportCondenser.db.global.Grid2.selectedExportOptions["Custom Layouts"] == true
        table["Grid2"] = { includeCustomLayouts = includeCustomLayouts, data = grid2Options:ExportCurrentProfile(includeCustomLayouts) }
    end
end
