local ADDON_NAME, ns             = ...
local ImportCondenser            = ns.Addon
local AceAddon                   = LibStub("AceAddon-3.0", true)
local AceDBOptions               = LibStub("AceDBOptions-3.0", true)
local LibDualSpec                = LibStub("LibDualSpec-1.0", true)

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
