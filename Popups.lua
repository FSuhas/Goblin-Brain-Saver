local talentButtons = BrainSaverTalentButtons
local mainFrame = BrainSaverMainFrame

if not BrainSaverDB then
    BrainSaverDB = {}
end
if not BrainSaverDB.spec then
    BrainSaverDB.spec = {}
end

local DB = BrainSaverDB
BrainSaver_TempPopupData = {}

local dropdownMenu = CreateFrame("Frame", "BrainSaverContextMenu", UIParent, "UIDropDownMenuTemplate")

local function OnMenuClick(self)
    local idx = this.arg1
    local action = this.value
    mainFrame.currentButton = idx

    if action == "load" then
        if DB.spec[idx] then
            StaticPopup_Show("ENABLE_TALENT_LAYOUT")
        end
    elseif action == "save" then
        StaticPopup_Show("SAVE_TALENT_LAYOUT")
    elseif action == "rename" then
        StaticPopup_Show("BRAINSAVER_RENAME")
    elseif action == "changeIcon" then
        StaticPopup_Show("EDIT_TALENT_SLOT")
    end
end

local function GetContextMenuEntries(idx)
    return {
        { text = "Save", value = "save",       arg1 = idx, func = OnMenuClick, notCheckable = true },
        { text = "Rename",    value = "rename",     arg1 = idx, func = OnMenuClick, notCheckable = true },
        { text = "Change Icon", value = "changeIcon", arg1 = idx, func = OnMenuClick, notCheckable = true },
        { text = "Cancel",     value = "cancel",     arg1 = idx, func = function() CloseDropDownMenus() end, notCheckable = true },
    }
end

local function ShowContextMenu(idx, anchor)
    if not idx or not anchor then
        print("ShowContextMenu: invalid arguments")
        return
    end

    local anchorName = anchor.GetName and anchor:GetName() or tostring(anchor)
    --print("ShowContextMenu called with index: " .. tostring(idx) .. " and anchor: " .. anchorName)

    UIDropDownMenu_Initialize(dropdownMenu, function()
        for _, item in ipairs(GetContextMenuEntries(idx)) do
            UIDropDownMenu_AddButton(item)
        end
    end, "MENU")

    ToggleDropDownMenu(1, nil, dropdownMenu, anchor, 0, 0)
end


StaticPopupDialogs["BUY_TALENT_SLOT"] = {
    text = "Do you want to buy a talent slot for %1$d gold?",
    button1 = "Yes",
    button2 = "No",
    OnShow = function(self)
        mainFrame:SetAlpha(dialog_alpha)
    end,
    OnAccept = function()
      local button
      local buy_button
      local slot
      for s,btn in mainFrame.gossip_slots.buy do
        -- Send the appropriate gossip option:
        btn.button:Click() -- this will close the dialogue for us
        break
      end
    end,
    OnHide = function()
        mainFrame:SetAlpha(1)
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3,
}

StaticPopupDialogs["ENABLE_TALENT_LAYOUT"] = {
    text = "Do you want to enable these talents?",
    button1 = "Activate",
    button2 = "Cancel",
    showAlert = 1,
    OnShow = function()
      mainFrame:SetAlpha(dialog_alpha)
      this:SetBackdropColor(1,1,1,1)

      local button = talentButtons[mainFrame.currentButton]
      local spec = BrainSaverDB.spec[button.index] or {}
      local t1,t2,t3 = TalentCounts()
      local s1,s2,s3 = spec.t1 or 0, spec.t2 or 0, spec.t3 or 0
      _G[this:GetName().."Text"]:SetText(
        format("|cffff5500LOAD|r TALENTS\n\nSpec Slot %d:\nSpec name: %s\nSpec talents: %s\n\nCurrent talents: %s\nActivate spec talents? (causes brainwasher debuff)",
        -- format("Enable these talents from slot %d?\n\n%s\n\n%s",
                button.index,
                button:GetName(),
                ColorSpecSummary(s1, s2, s3),
                ColorSpecSummary(t1, t2, t3))
      )
      if spec then
        _G[this:GetName().."AlertIcon"]:SetTexture(spec.icon)
      else
        _G[this:GetName().."AlertIcon"]:SetTexture(button:GetIcon())
      end
    end,
    OnAccept = function()
      local button = talentButtons[mainFrame.currentButton]
      -- Send the appropriate gossip option:
      mainFrame.gossip_slots.load[mainFrame.currentButton]:Click()
    end,
    OnHide = function ()
      mainFrame:SetAlpha(1)
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3,
}

StaticPopupDialogs["EDIT_TALENT_SLOT"] = {
    text = "Choose icon for this spec:",
    button1 = "Save",
    button2 = "Cancel",

    OnShow = function(self)
        mainFrame:SetAlpha(dialog_alpha)

        local idx = mainFrame.currentButton
        local spec = BrainSaverDB.spec[idx]
        local currentIcon = spec and spec.icon or "Interface\\Icons\\INV_Misc_QuestionMark"

        -- Stocker l'icône actuelle au moment d'ouvrir la popup
        this.selectedIcon = currentIcon
        this.originalIcon = currentIcon -- pour restaurer en cas d'annulation

        -- Ouvrir le sélecteur avec surbrillance de l'icône actuelle
        BrainSaver_IconSelector:ShowSelector(function(selectedIcon)
            -- Mise à jour temporaire de l'icône sélectionnée
            this.selectedIcon = selectedIcon

            if idx and talentButtons[idx] then
                talentButtons[idx]:SetIcon(selectedIcon)
                icon = selectedIcon
            end
        end, currentIcon)
    end,

    OnAccept = function(self)
        local idx = mainFrame.currentButton

        BrainSaverDB.spec[idx] = BrainSaverDB.spec[idx] or {}
        BrainSaverDB.spec[idx].icon = icon

        if BrainSaver_IconSelector and BrainSaver_IconSelector:IsShown() then
            BrainSaver_IconSelector:Hide()
        end
    end,

    OnCancel = function(self)
        local idx = mainFrame.currentButton
        local spec = BrainSaverDB.spec[idx]
        local currentIcon = spec and spec.icon or "Interface\\Icons\\INV_Misc_QuestionMark"

        if idx and currentIcon then
            if talentButtons[idx] then
                talentButtons[idx]:SetIcon(currentIcon)
            end
        end

        if BrainSaver_IconSelector and BrainSaver_IconSelector:IsShown() then
            BrainSaver_IconSelector:Hide()
        end
    end,

    OnHide = function(self)
        mainFrame:SetAlpha(1)
    end,

    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3,
}

StaticPopupDialogs["BRAINSAVER_RENAME"] = {
    text = "Rename this specialization :",
    button1 = "Save",
    button2 = "Cancel",
    hasEditBox = 1,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    OnShow = function()
        mainFrame:SetAlpha(dialog_alpha)

        local idx = mainFrame.currentButton
        local spec = BrainSaverDB.spec[idx]
        local currentName = spec and spec.name or ""

        local popupName = this:GetName()

        local editBox = getglobal(popupName .. "EditBox")
        if editBox then
            editBox:SetText(currentName)
        else
            print("EditBox not found: " .. popupName .. "EditBox")
        end
    end,
    OnAccept = function()
        local idx = mainFrame.currentButton
        if not idx then return end

        local editBox = getglobal(this:GetParent():GetName() .. "EditBox")
        local newName = editBox and editBox:GetText()

        if not newName or newName == "" then return end

        BrainSaverDB.spec[idx] = BrainSaverDB.spec[idx] or {}
        BrainSaverDB.spec[idx].name = newName
        talentButtons[idx]:SetName(newName)
    end,
    OnHide = function(self)
        mainFrame:SetAlpha(1)
    end,
    EditBoxOnEnterPressed = function()
        local idx = mainFrame.currentButton
        if not idx then return end

        local editBox = getglobal(this:GetParent():GetName() .. "EditBox")
        local newName = editBox and editBox:GetText()

        if not newName or newName == "" then return end

        BrainSaverDB.spec[idx] = BrainSaverDB.spec[idx] or {}
        BrainSaverDB.spec[idx].name = newName
        talentButtons[idx]:SetName(newName)

        this:GetParent():Hide()
    end,
    EditBoxOnEscapePressed = function(self)
        this:GetParent():Hide()
    end,
}

-- todo, show the spec numbers you're saving, and what exists in the slot
StaticPopupDialogs["SAVE_TALENT_LAYOUT"] = {
    -- text = "Save your current talents to slot %d?\n\n%s\n\n%s\n\nEnter new name:",
    text = "Do you want to save these talents?",
    button1 = "Save",
    button2 = "Cancel",
    hasEditBox = 1,
    showAlert = 1,
    OnShow = function()
      mainFrame:SetAlpha(dialog_alpha)
      local button = talentButtons[mainFrame.currentButton]
      local spec = BrainSaverDB.spec[mainFrame.currentButton]
      local t1,t2,t3 = TalentCounts()

      _G[this:GetName().."Text"]:SetText(
        format("|cff00ff55SAVE|r TALENTS\n\nSpec Slot %d:\nSpec name: %s\nSpec talents: %s\n\nCurrent talents: %s\nReplace spec talents with current talents?",
                button.index,
                button.layoutName:GetText(),
                spec and ColorSpecSummary(spec.t1,spec.t2,spec.t3) or "? | ? | ?",
                ColorSpecSummary(t1,t2,t3))
      )
      local editBox = _G[this:GetName().."EditBox"]
      if spec then
        _G[this:GetName().."AlertIcon"]:SetTexture(spec.icon)
        editBox:SetText(spec.name)
      else
        _G[this:GetName().."AlertIcon"]:SetTexture(button:GetIcon())
        editBox:SetText(button:GetName())
      end
    end,
    OnAccept = function()
      print("OnAccept called in SAVE_TALENT_LAYOUT")
      local button = talentButtons[mainFrame.currentButton]
      local newName = _G[this:GetParent():GetName().."EditBox"]:GetText()
      local t1, t2, t3 = TalentCounts()
      local talents = FetchTalents()

      local newIcon = BrainSaverDB.spec[button.index] and BrainSaverDB.spec[button.index].icon or "Interface\\Icons\\INV_Misc_QuestionMark"
      print("Icon saved:", newIcon)

      BrainSaverDB.spec[button.index] = BrainSaverDB.spec[button.index] or {}

      BrainSaverDB.spec[button.index].name = newName
      BrainSaverDB.spec[button.index].t1 = t1
      BrainSaverDB.spec[button.index].t2 = t2
      BrainSaverDB.spec[button.index].t3 = t3
      BrainSaverDB.spec[button.index].talents = talents
      BrainSaverDB.spec[button.index].icon = newIcon

      button.layoutName:SetText(newName)
      button.talentSummary:SetText(ColorSpecSummary(t1, t2, t3))
      button:SetIcon(newIcon)

      mainFrame.gossip_slots.save[mainFrame.currentButton]:Click()
    end,
    OnHide = function()
      _G[this:GetName() .. "EditBox"]:SetText("")
      mainFrame:SetAlpha(1)
      _G[this:GetName().."AlertIcon"]:SetTexture()
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3,
}

-- can't use the builtin since this doesn't use the CONFIRM_TALENT_WIPE event
-- and can't use CheckTalentMasterDist
StaticPopupDialogs["RESET_TALENTS"] = {
    text = "Reset your current talent points?\n\nThis costs gold and causes a 10 minute brainwasher use debuff.",
    button1 = "Yes",
    button2 = "No",
    OnShow = function()
      mainFrame:SetAlpha(dialog_alpha)
      _G[this:GetName().."AlertIcon"]:SetTexture("Interface\\Icons\\Spell_Nature_AstralRecalGroup")
    end,
    OnAccept = function()
      mainFrame.gossip_slots.reset:Click()
    end,
    OnHide = function()
      mainFrame:SetAlpha(1)
      _G[this:GetName().."AlertIcon"]:SetTexture()
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3,
    showAlert = 1,
}


-- Expose la fonction globale
BrainSaverShowContextMenu = ShowContextMenu
