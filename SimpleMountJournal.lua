local AddOnName, AddOnTable = ...
local _

_G[AddOnName] = AddOnTable

-- duplicated from Blizzard_MountCollection as it is local there
local MOUNT_BUTTON_HEIGHT = 46
local MOUNT_FACTION_TEXTURES = {
	[0] = "MountJournalIcons-Horde",
	[1] = "MountJournalIcons-Alliance"
}

local database = AddOnTable:LoadDatabase()

--[[
    to correctly generate the mount list we need to have a look at several things
    1. only show the mounts currently visible by the filter system
    2. show groups of which at least one mount is visible by the filter system
    3. apply correct ordering as done by the original system:
       - favorites (and groups containing at least one favorite mount) first
       - other owned mounts (and groups containing at least one other owned mount)
       - not owned mounts (and all groups with no owned mounts)
]]

function createGroupInfo(id, name, group)
    return {
        ID = id,
        Name = name,
        Group = group,
        IsGroup = true,
        IsFavorite = function()
            for _,value in ipairs(group) do
                if (value.IsFavorite) then
                    return true
                end
            end
            return false
        end,
        IsCollected = function()
            for _,value in ipairs(group) do
                if (value.IsCollected) then
                    return true
                end
            end
            return false
        end
    }
end

function createMountInfo(id, name, favorite, collected)
    return {
        ID = id,
        Name = name,
        Group = nil,
        IsGroup = false,
        IsFavorite = function() return favorite end,
        IsCollected = function() return collected end
    }

end

function GetVisibleMounts()
    local visibleGroups = {}
    local visibleMountCache = {}
    for index=1, C_MountJournal.GetNumDisplayedMounts() do
        local creatureName, spellID, icon, active, isUsable, _, isFavorite, isFactionSpecific, faction, _, isCollected, mountID = C_MountJournal.GetDisplayedMountInfo(index)
        local mountGroupName = AddOnTable.GroupDatabase.MountIdModelGroupMap[mountID]

        if mountGroupName ~= nil then
            local mountInfo = { MountID = mountID, IsFavorite = isFavorite, IsCollected = isCollected }
            if visibleGroups[mountGroupName] ~= nil then
                table.insert(visibleGroups[mountGroupName], mountInfo)
            else
                local newGroup = {}
                table.insert(newGroup, mountInfo)
                visibleGroups[mountGroupName] = newGroup
                table.insert(visibleMountCache, createGroupInfo(mountGroupName, AddOnTable.Localization[mountGroupName], newGroup))
            end
        else
            table.insert(visibleMountCache, createMountInfo(mountID, creatureName, isFavorite, isCollected))
        end
    end

    return visibleMountCache
end

function SortEntries(visibleMounts)
    local sortFunction = function(elem1, elem2)
        if elem1.IsFavorite() ~= elem2.IsFavorite() then
            return elem1.IsFavorite()
        end

        if elem1.IsCollected() ~= elem2.IsCollected() then
            return elem1.IsCollected()
        end

        return elem1.Name < elem2.Name
    end
    table.sort(visibleMounts, sortFunction)
end

function AddOnTable:UpdateVisibleMountInfo()
    local visibleMounts = GetVisibleMounts()
    SortEntries(visibleMounts)
    AddOnTable["VisibleEntries"] = visibleMounts
end

AddOnTable:UpdateVisibleMountInfo()

local MountJournal_UpdateMountList_ORIG = MountJournal_UpdateMountList
MountJournal_UpdateMountList = function()
    local showMounts = (C_MountJournal.GetNumMounts() > 0)
    if (not showMounts) then
        MountJournal.numOwned = 0
        MountJournal.MountDisplay.NoMounts:Show()
        MountJournal.selectedSpellID = nil
		MountJournal.selectedMountID = nil
		MountJournal_UpdateMountDisplay()
        MountJournal.MountCount.Count:SetText(0)
    else
        MountJournal.numOwned = GetOwnedMountsCount()
        MountJournal.MountDisplay.NoMounts:Hide()
        MountJournal.MountCount.Count:SetText(MountJournal.numOwned)
    end
    
    -- determine how many entries actually shown in list
    local numDisplayedMounts = #AddOnTable.VisibleEntries
    
    -- update buttons based on stuff to show
    local scrollFrame = MountJournal.ListScrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons
    for i=1, #buttons do
		local button = buttons[i]
		local displayIndex = i + offset
        if ( displayIndex <= numDisplayedMounts and showMounts ) then
            --updateButtonWithMount(displayIndex, button)
            SMJ_updateButtonWithMount(displayIndex, button)
        else
            SMJ_resetButton(button)
        end
        button:SetScript("OnClick", SMJ_MountListItem_OnClick)
    end
    
    local totalHeight = numDisplayedMounts * MOUNT_BUTTON_HEIGHT
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight())
end
MountJournal.ListScrollFrame.update = MountJournal_UpdateMountList

function GetOwnedMountsCount()
    local numOwned = 0
    local mountIDs = C_MountJournal.GetMountIDs()
    for _, mountID in ipairs(mountIDs) do
        local _, _, _, _, _, _, _, _, _, hideOnChar, isCollected = C_MountJournal.GetMountInfoByID(mountID)
        if (isCollected and hideOnChar ~= true) then
            numOwned = numOwned + 1
        end
    end
    return numOwned
end


--[[
    @param index index of the shown mount as needed by C_MountJournal.GetDisplayedMountInfo()
    @param button the button element to update with the new info
]]
function SMJ_updateButtonWithMount(index, button)
    local visibleEntry = AddOnTable.VisibleEntries[index]

    if visibleEntry.IsGroup then
        SMJ_createGroupButton(index, visibleEntry, button)
    else
        local creatureName, spellID, icon, active, isUsable, _, isFavorite, isFactionSpecific, faction, _, isCollected = C_MountJournal.GetMountInfoByID(visibleEntry.ID)
        SMJ_updateButton(index, button, creatureName, spellID, icon, active, isUsable, isFavorite, isFactionSpecific, faction, isCollected)
    end
end

function SMJ_createGroupButton(index, groupEntry, button)
    local group = AddOnTable.GroupDatabase.MountGroups[groupEntry.ID]

    local icon = nil
    local isActive = false
    local isUsable = false
    local isFavorite = false
    local isFactionSpecific = false
    local faction = nil
    local isCollected = false
    local needsFanfare = false
    
    for _, mountID in ipairs(group) do
        local _, _, mIcon, mActive, mIsUsable, _, mIsFavorite, mIsFactionSpecific, mFaction, _, mIsCollected = C_MountJournal.GetMountInfoByID(mountID)
        local mNeedsFanfare = C_MountJournal.NeedsFanfare(mountID)
        icon = icon and icon or mIcon
        isActive = isActive or mActive
        isUsable = isUseable or mIsUsable
        isFavorite = isFavorite or mIsFavorite
        isFactionSpecific = isFactionSpecific or mIsFactionSpecific
        faction = faction and faction or mFaction
        isCollected = isCollected or mIsCollected
        needsFanfare = needsFanfare or mNeedsFanfare
    end
    
    --[[ TODO: selection based on spellID cannot work right now, we have to somehow check against the spellIDs of the whole group here ]]
    SMJ_updateButton(index, button, groupEntry.Name, 0, icon, isActive, isUsable, isFavorite, isFactionSpecific, faction, isCollected)
end

function SMJ_updateButton(index, button, creatureName, spellID, icon, active, isUsable, isFavorite, isFactionSpecific, faction, isCollected)
    button.name:SetText(creatureName)
    button.icon:SetTexture(needsFanfare and COLLECTIONS_FANFARE_ICON or icon)
    button.new:SetShown(needsFanfare)
    button.newGlow:SetShown(needsFanfare)

    button.index = index
    button.spellID = spellID

    button.active = active
    if (active) then
        button.DragButton.ActiveTexture:Show()
    else
        button.DragButton.ActiveTexture:Hide()
    end
    button:Show()

    if ( MountJournal.selectedSpellID == spellID ) then
        button.selected = true
        button.selectedTexture:Show()
    else
        button.selected = false
        button.selectedTexture:Hide()
    end
    button:SetEnabled(true)
    button.unusable:Hide()
    button.iconBorder:Hide()
    button.background:SetVertexColor(1, 1, 1, 1)
    if (isUsable or needsFanfare) then
        button.DragButton:SetEnabled(true)
        button.additionalText = nil
        button.icon:SetDesaturated(false)
        button.icon:SetAlpha(1.0)
        button.name:SetFontObject("GameFontNormal")
    else
        if (isCollected) then
            button.unusable:Show()
            button.DragButton:SetEnabled(true)
            button.name:SetFontObject("GameFontNormal")
            button.icon:SetAlpha(0.75)
            button.additionalText = nil
            button.background:SetVertexColor(1, 0, 0, 1)
        else
            button.icon:SetDesaturated(true)
            button.DragButton:SetEnabled(false)
            button.icon:SetAlpha(0.25)
            button.additionalText = nil
            button.name:SetFontObject("GameFontDisable")
        end
    end

    if ( isFavorite ) then
        button.favorite:Show()
    else
        button.favorite:Hide()
    end

    if ( isFactionSpecific ) then
        button.factionIcon:SetAtlas(MOUNT_FACTION_TEXTURES[faction], true)
        button.factionIcon:Show()
    else
        button.factionIcon:Hide()
    end

    if ( button.showingTooltip ) then
        MountJournalMountButton_UpdateTooltip(button)
    end
end

function SMJ_resetButton(button)
    button.name:SetText("");
    button.icon:SetTexture("Interface\\PetBattles\\MountJournalEmptyIcon")
    button.index = nil
    button.spellID = 0
    button.selected = false
    button.unusable:Hide()
    button.DragButton.ActiveTexture:Hide()
    button.selectedTexture:Hide()
    button:SetEnabled(false)
    button.DragButton:SetEnabled(false)
    button.icon:SetDesaturated(true)
    button.icon:SetAlpha(0.5)
    button.favorite:Hide()
    button.factionIcon:Hide()
    button.background:SetVertexColor(1, 1, 1, 1)
    button.iconBorder:Hide()
end

function SMJ_MountListItem_OnClick(self, button)
    local visibleEntry = AddOnTable.VisibleEntries[self.index]

    --DEFAULT_CHAT_FRAME:AddMessage(GetTime().." SMJ: Clicked on entry "..self.index.." (Group: "..(visibleEntry.IsGroup and "true" or "false")..", ID="..visibleEntry.ID..")")
	if ( button ~= "LeftButton" ) then
		local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetDisplayedMountInfo(self.index)
		if isCollected then
			MountJournal_ShowMountDropdown(self.index, self, 0, 0)
		end
	elseif ( IsModifiedClick("CHATLINK") ) then
		local id = self.spellID
		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName = GetSpellInfo(id)
			ChatEdit_InsertLink(spellName)
		else
			local spellLink = GetSpellLink(id)
			ChatEdit_InsertLink(spellLink)
		end
    elseif ( self.spellID ~= MountJournal.selectedSpellID ) then
        if (visibleEntry.IsGroup) then
            MountJournal_SelectByMountID(visibleEntry.Group[1].MountID)
        else
            MountJournal_SelectByMountID(visibleEntry.ID)
        end
	end
end