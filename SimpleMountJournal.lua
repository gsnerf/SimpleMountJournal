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
    local numDisplayedMounts = C_MountJournal.GetNumDisplayedMounts()
    --local numDisplayedMounts = numDisplayedMountsBlizz - database.OverallGroupedMounts + database.OverallGroupCount
    --DEFAULT_CHAT_FRAME:AddMessage(GetTime().." SMJ: Need to show "..numDisplayedMounts.." mounts rather than "..C_MountJournal.GetNumDisplayedMounts())
    
    -- update buttons based on stuff to show
    local scrollFrame = MountJournal.ListScrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons
    for i=1, #buttons do
		local button = buttons[i]
		local displayIndex = i + offset
        if ( displayIndex <= numDisplayedMounts and showMounts ) then
            updateButtonWithMount(displayIndex, button)
        else
            resetButton(button)
        end
    end
    
    local totalHeight = numDisplayedMounts * MOUNT_BUTTON_HEIGHT
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight())
	
	
end

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

function updateButtonWithMount(index, button)
    local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID = C_MountJournal.GetDisplayedMountInfo(index)
    local needsFanfare = C_MountJournal.NeedsFanfare(mountID)

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

function resetButton(button)
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