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

function ImportCondenser:ReplaceDelimitedTokenValue(inputStr, token, newValue)
    if type(inputStr) ~= "string" then
        return inputStr
    end
    if type(token) ~= "string" or token == "" then
        return inputStr
    end

    newValue = tostring(newValue or "")

    local lastStart, lastEnd
    local searchFrom = 1
    while true do
        local s, e = string.find(inputStr, token, searchFrom, true)
        if not s then
            break
        end
        lastStart, lastEnd = s, e
        searchFrom = e + 1
    end

    if not lastEnd then
        return inputStr
    end

    local afterTokenIndex = lastEnd + 1
    local nextDelimStart = string.find(inputStr, "::", afterTokenIndex, true)
    if nextDelimStart then
        return string.sub(inputStr, 1, lastEnd) .. newValue .. string.sub(inputStr, nextDelimStart)
    end

    return string.sub(inputStr, 1, lastEnd) .. newValue
end
