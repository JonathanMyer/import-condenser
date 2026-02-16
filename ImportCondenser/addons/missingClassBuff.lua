local ADDON_NAME, ns             = ...
local ImportCondenser            = ns.Addon

ImportCondenser.MissingClassBuff = {}

function ImportCondenser.MissingClassBuff:GetExportOptions()
    return { "Export" }, { "Export" }, false
end

function ImportCondenser.MissingClassBuff:Import(importStr, profileName)
    print("Importing MissingClassBuff profile: " .. profileName)
    ImportCondenser:ImportAceAddon("MissingClassBuff", importStr, profileName)
end

function ImportCondenser.MissingClassBuff:Export(exports)
    if ImportCondenser.db.global.MissingClassBuff.selectedExportOptions["Export"] ~= true then return end
    exports["MissingClassBuff"] = ImportCondenser:ExportAceAddon("MissingClassBuff")
end
