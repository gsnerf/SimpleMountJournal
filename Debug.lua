local AddOnName, AddOnTable = ...
local _

MountCollection = {}

function Export() 
    local mountCount = 0
    local visibleMountCount = 0

    local mountIDs = C_MountJournal.GetMountIDs()
    for i, mountID in ipairs(mountIDs) do
        local name, _, _, _, _, _, _, _, _, hideOnChar, isCollected = C_MountJournal.GetMountInfoByID(mountID)
        local creatureDisplayID, descriptionText, sourceText, isSelfMount, mountType, modelSceneId = C_MountJournal.GetMountInfoExtraByID(mountID)
        MountCollection[mountID] = {
            ID = mountID,
            Name = name,
            HideOnChar = hideOnChar,
            Owned = isCollected,
            SourceType = sourceType,
            Extras = {
                DisplayID = creatureDisplayID,
                Description = descriptionText,
                Source = sourceText,
                IsSelfMount = isSelfMount,
                MountType = mountType,
                ModelSceneId = modelSceneId
            }
        }
        mountCount = mountCount + 1
        visibleMountCount = visibleMountCount + (hideOnChar and 0 or 1)
    end

    DEFAULT_CHAT_FRAME:AddMessage(GetTime().." SMJ: Extracted "..mountCount.." mounts from client, "..visibleMountCount.." are visible to the current char")
end

AddOnTable["Export"] = Export