local ADDON_NAME, ns       = ...
local ImportCondenser      = ns.Addon

ImportCondenser.FrameColor = {}

function ImportCondenser.FrameColor:GetExportOptions()
    return { "Export" }, { "Export" }, false
end

function ImportCondenser.FrameColor:Import(importStr, profileName)
    ImportCondenser:ImportAceAddon("FrameColor", importStr, profileName)
end

function ImportCondenser.FrameColor:Export(exports)
    if ImportCondenser.db.global.FrameColor.selectedExportOptions["Export"] ~= true then return end
    exports["FrameColor"] = ImportCondenser:ExportAceAddon("FrameColor")
end
