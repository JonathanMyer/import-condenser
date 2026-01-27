local ADDON_NAME, ns = ...
ns = ns or {}

local ImportCondenser = ns.Addon
if not ImportCondenser then
    return
end

function ImportCondenser:DeSeriPressCode(inputStr)
    local AceSerializer = LibStub("AceSerializer-3.0", true)
    local LibDeflate = LibStub("LibDeflate", true)

    if AceSerializer and LibDeflate then
        local decoded = LibDeflate:DecodeForPrint(inputStr)
        if not decoded then
            print("Error: Failed to decode import string")
            return nil
        end

        local decompressed = LibDeflate:DecompressDeflate(decoded)
        if not decompressed then
            print("Error: Failed to decompress data")
            return nil
        end

        local success, importProfile = AceSerializer:Deserialize(decompressed)
        if not success or not importProfile then
            print("Error: Failed to deserialize profile")
            return nil
        end

        return importProfile
    else
        print("Error: Required libraries for serialization are missing.")
        return nil
    end
end

function ImportCondenser:SeriPressCode(dataTable)
    local AceSerializer = LibStub("AceSerializer-3.0", true)
    local LibDeflate = LibStub("LibDeflate", true)

    if AceSerializer and LibDeflate then
        local serialized = AceSerializer:Serialize(dataTable)
        local compressed = LibDeflate:CompressDeflate(serialized)
        local encoded = LibDeflate:EncodeForPrint(compressed)

        return encoded
    else
        print("Error: Required libraries for serialization are missing.")
        return nil
    end
end
