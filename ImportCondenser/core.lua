local ADDON_NAME, ns = ...
ns = ns or {}

local ImportCondenser = ns.Addon
if not ImportCondenser then
    return
end

local LibDualSpec = ns.LibDualSpec
local AceConfigDialog = ns.AceConfigDialog
local AceConfigRegistry = ns.AceConfigRegistry

function ImportCondenser:GetAddonModules()
    local addons = ns.addons
    if not addons then
        addons = {}
        ns.addons = addons
    end

    if #addons == 0 then
        for key, value in pairs(ImportCondenser) do
            if type(value) == "table" and value.Import and value.Export then
                table.insert(addons, key)
            end
        end
    end

    table.sort(addons, function(a, b)
        local aLoaded = ImportCondenser:IsAddonLoaded(a)
        local bLoaded = ImportCondenser:IsAddonLoaded(b)

        if aLoaded ~= bLoaded then
            return aLoaded
        end

        if aLoaded then
            local aHasDetect = ImportCondenser[a] and ImportCondenser[a].DetectIssues ~= nil
            local bHasDetect = ImportCondenser[b] and ImportCondenser[b].DetectIssues ~= nil

            if aHasDetect ~= bHasDetect then
                return aHasDetect
            end
        end

        return a < b
    end)

    return addons
end

function ImportCondenser:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ImportCondenserDB", ns.defaults or {}, true)

    if LibDualSpec then
        LibDualSpec:EnhanceDatabase(self.db, "ImportCondenser")
    end

    self.db.global.ImportedStrings = nil

    self:GetAddonModules()

    if ns.SetupOptions then
        ns.SetupOptions(self)
    end

    self:RegisterChatCommand("importcondenser", "OpenConfig")
    self:RegisterChatCommand("ic", "OpenConfig")
end

function ImportCondenser:OpenConfig()
    self:GetAddonModules()

    if ns.SetupOptions then
        ns.SetupOptions(self)
    end

    if AceConfigRegistry then
        AceConfigRegistry:NotifyChange(ADDON_NAME)
    end
    if AceConfigDialog then
        AceConfigDialog:Open(ADDON_NAME)
    end
end

function ImportCondenser:IsAddonLoaded(addonName)
    if addonName == "EditMode" then
        return C_EditMode ~= nil
    end
    if addonName == "CooldownManager" then
        return C_CooldownViewer ~= nil
    end
    return C_AddOns and C_AddOns.IsAddOnLoaded(addonName) or (IsAddOnLoaded and IsAddOnLoaded(addonName))
end
