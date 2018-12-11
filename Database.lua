local AddOnName, AddOnTable = ...
local _

local StaticMountGroups = {
    ClassMounts = {
        860, -- mage
        861, -- priest
        864, -- monk
        865, -- hunter color variation #1
        866, -- death knight
        867, -- warrior
        868, -- demon hunter
        870, -- hunter color variation #2
        872, -- hunter color variation #3
        884, -- rogue color variation #1
        885, -- paladin color variation #1
        888, -- shaman
        889, -- rogue color variation #2
        890, -- rogue color variation #1
        891, -- rogue color variation #1
        892, -- paladin color variation #2
        893, -- paladin color variation #3
        894, -- paladin color variation #4
        898, -- warlock color variation #1
        930, -- warlock color variation #2
        931, -- warlock color variation #3
    },
    CloudSerpents = {
        448, -- jade
        464, -- azure
        465, -- golden
        471, -- onyx
        472, -- crimson
        478, -- astral
    },
    DragonTurtle = {
        452, -- green
        492, -- black
        493, -- blue
        494, -- brown
        495, -- purple
        496, -- red
    },
    GreatDragonTurtle = {
        453, -- red
        497, -- green
        498, -- black
        499, -- blue
        500, -- brown
        501, -- purple
    },
    Gron = { 607, 655 },
    HeavenlyCloudSerpents = {
        473, -- onyx
        474, -- crimson
        475, -- golden
        477, -- azure
    },
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
    },
    NetherwingDrakes = {
        186, -- onyx
        187, -- azure
        188, -- cobalt
        189, -- purple
        190, -- veridian
        191, -- violet
    },
    Panther = {
        451, -- onyx
        456, -- sapphire
        457, -- jade
        458, -- ruby
        459, -- sunstone
    },
    ProtoDrakes = {
        262, -- red
        263, -- black
        264, -- blue
        265, -- time-lost
        266, -- plagued
        267, -- violet
        278, -- green
        306, -- ironbound
        307, -- rusted
    },
    ThunderingCloudSerpents = {
        466, -- jade
        504, -- august
        517, -- ruby
        542, -- cobalt
        561, -- onyx
    },
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

    AddOnTable["GroupDatabase"] = database
    return database
end
