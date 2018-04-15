local AddOnName, AddOnTable = ...
local _

_G[AddOnName] = AddOnTable

local database = AddOnTable:LoadDatabase()

local MountJournal_UpdateMountList_ORIG = MountJournal_UpdateMountList
MountJournal_UpdateMountList = function()
    MountJournal_UpdateMountList_ORIG()

    -- determine how many entries actuall shown in list
    local numDisplayedMounts = C_MountJournal.GetNumDisplayedMounts() - database.OverallGroupedMounts + database.OverallGroupCount
    DEFAULT_CHAT_FRAME:AddMessage(GetTime().." SMJ: Need to show "..numDisplayedMounts.." mounts rather than "..C_MountJournal.GetNumDisplayedMounts())
end

