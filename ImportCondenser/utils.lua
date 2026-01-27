local ADDON_NAME, ns = ...
ns = ns or {}

local ImportCondenser = ns.Addon
if not ImportCondenser then
    return
end

function ImportCondenser:AddToInspector(data, strName)
    if DevTool and self.DEBUG then
        DevTool:AddData(data, strName)
    end
end

function ImportCondenser:CopyTable(src, dest)
    if type(dest) ~= "table" then dest = {} end
    if type(src) == "table" then
        for k, v in pairs(src) do
            if type(v) == "table" then
                v = self:CopyTable(v, dest[k])
            end
            dest[k] = v
        end
    end
    return dest
end

function ImportCondenser:CountKeys(table)
    if not table then
        return 0
    end
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

ImportCondenser.ClassNames = {
    [1] = "Warrior",
    [2] = "Paladin",
    [3] = "Hunter",
    [4] = "Rogue",
    [5] = "Priest",
    [6] = "DeathKnight",
    [7] = "Shaman",
    [8] = "Mage",
    [9] = "Warlock",
    [10] = "Monk",
    [11] = "Druid",
    [12] = "DemonHunter",
    [13] = "Evoker"
}
