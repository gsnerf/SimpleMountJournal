local AddOnName, AddOnTable = ...
local _

local StaticMountGroups = {
    Gron = { 607, 655 },
    Mechanostrider = {
        39,  -- red
        40,  -- blue
        42,  -- white mod. b (classical, unobtainable)
        43,  -- green
        57,  -- green again???
        58,  -- greyscale
        145  -- blue again???
    },
    FastMechanostrider = {
        88, -- yellow
        89, -- white
        90  -- green
    }
}

local Prototype = {
    OverallGroupedMounts = 0,
    OverallGroupCount = 0,
    -- don't forget to reset them on intantiation!
    StaticMountGroups = {},
    GroupedMountCounts = {},
    MountIdModelGroupMap = {}
}

local Metatable = { __index = Prototype }

function AddOnTable:LoadDatabase()
    -- create object
    local database = _G.setmetatable({}, Metatable)
    database.MountGroups = {}
    database.GroupedMountCounts = {}
    database.MountIdModelGroupMap = {}

    -- traverse static mounts and generate user specific one with mappings and counts used for 
    local groupName, idList, index, id
    for groupName, idList in pairs(StaticMountGroups) do
        local mountGroup = {}
        for index, id in ipairs(idList) do
            local _, _, _, _, _, _, _, _, _, hideOnChar, _ = C_MountJournal.GetMountInfoByID(id)
            if (not hideOnChar) then
                table.insert(mountGroup, id)
                database.MountIdModelGroupMap[id] = groupName
            end
        end
        local groupCount = #mountGroup
        if 0 < groupCount then
            database.MountGroups[groupName] = mountGroup
            database.GroupedMountCounts[groupName] = groupCount
            
            database.OverallGroupedMounts = database.OverallGroupedMounts + groupCount
            database.OverallGroupCount = database.OverallGroupCount + 1
        end
    end

    AddOnTable["Database"] = database
    return database
end
