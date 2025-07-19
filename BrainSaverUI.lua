local addon_name = "Goblin Brain Saver"

-- Récupère la table globale DB et Utils (assure-toi que BrainSaverDB.lua est chargé avant)
local DB = BrainSaverDB or {}
local Utils = DB.Utils or {}

-- Frame principale BrainSaver avec skin Spellbook
local mainFrame = CreateFrame("Frame", addon_name.."Frame", UIParent)
mainFrame:SetWidth(384)
mainFrame:SetHeight(512)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function() mainFrame:StartMoving() end)
mainFrame:SetScript("OnDragStop", function() mainFrame:StopMovingOrSizing() end)
mainFrame:Hide()

-- Arrière-plan Spellbook
mainFrame.tl = mainFrame:CreateTexture(nil, "ARTWORK")
mainFrame.tl:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-TopLeft")
mainFrame.tl:SetWidth(256)
mainFrame.tl:SetHeight(256)
mainFrame.tl:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, 0)

mainFrame.tr = mainFrame:CreateTexture(nil, "ARTWORK")
mainFrame.tr:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-TopRight")
mainFrame.tr:SetWidth(128)
mainFrame.tr:SetHeight(256)
mainFrame.tr:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0, 0)

mainFrame.bl = mainFrame:CreateTexture(nil, "ARTWORK")
mainFrame.bl:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-BotLeft")
mainFrame.bl:SetWidth(256)
mainFrame.bl:SetHeight(256)
mainFrame.bl:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, 0)

mainFrame.br = mainFrame:CreateTexture(nil, "ARTWORK")
mainFrame.br:SetTexture("Interface\\Spellbook\\UI-SpellbookPanel-BotRight")
mainFrame.br:SetWidth(128)
mainFrame.br:SetHeight(256)
mainFrame.br:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", 0, 0)

-- Anneau décoratif (optionnel)
mainFrame.ring = mainFrame:CreateTexture(nil, "ARTWORK")
mainFrame.ring:SetTexture("Interface\\QuestFrame\\UI-QuestLog-BookIcon")
mainFrame.ring:SetWidth(60)
mainFrame.ring:SetHeight(60)
mainFrame.ring:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -7)

-- Titre
mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
mainFrame.title:SetPoint("TOP", mainFrame, "TOP", 0, -15)
mainFrame.title:SetText("Goblin Brain Saver")

-- Bouton fermer
mainFrame.closeButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
mainFrame.closeButton:SetPoint("TOPRIGHT", -28, -9)
mainFrame.closeButton:SetScript("OnClick", function() mainFrame:Hide() end)

-- Résumé talents
mainFrame.talentSummaryText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
mainFrame.talentSummaryText:SetWidth(mainFrame:GetWidth() - 40)
mainFrame.talentSummaryText:SetJustifyH("CENTER")
mainFrame.talentSummaryText:SetPoint("TOP", mainFrame.title, "BOTTOM", 0, -20)
mainFrame.talentSummaryText:SetText("")

-- Texte inspiré sous le résumé
mainFrame.inspiredText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
mainFrame.inspiredText:SetPoint("TOP", mainFrame.talentSummaryText, "BOTTOM", 5, -30)
mainFrame.inspiredText:SetJustifyH("LEFT")
mainFrame.inspiredText:SetText("1. Take the device in both hands.\n2. Put it above your head.\n3. Let it go.\n4. Enjoy the sunshine of the spotless mind.")

-- Bouton reset
mainFrame.resetButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
mainFrame.resetButton:SetWidth(120)
mainFrame.resetButton:SetHeight(30)
mainFrame.resetButton:SetPoint("BOTTOM", mainFrame, "BOTTOM", -10, 85)
mainFrame.resetButton:SetText("Reset Talents")
mainFrame.resetButton:SetScript("OnClick", function()
    StaticPopup_Show("RESET_TALENTS")
end)

-- Bouton washer
mainFrame.washerButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
mainFrame.washerButton:SetWidth(60)
mainFrame.washerButton:SetHeight(20)
mainFrame.washerButton:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -45, 85)
mainFrame.washerButton:SetText("Washer")
mainFrame.washerButton:SetScript("OnClick", function()
    GossipFrame:SetAlpha(1)
end)
mainFrame.washerButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
    GameTooltip:SetText("Show original brainwasher dialogue.", 1, 1, 0)
    GameTooltip:Show()
end)
mainFrame.washerButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)


-- Table globale des boutons de talents (assure que ce tableau est défini et rempli ailleurs)
local talentButtons = BrainSaverTalentButtons or {}

-- Gestion des events
mainFrame:RegisterEvent("ADDON_LOADED")
mainFrame:RegisterEvent("GOSSIP_SHOW")
mainFrame:RegisterEvent("GOSSIP_CLOSED")
mainFrame:RegisterEvent("UI_ERROR_MESSAGE")

mainFrame:SetScript("OnEvent", function()
    this[event](this, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
end)

-- Event ADDON_LOADED
function mainFrame:ADDON_LOADED(addon)
    if addon ~= addon_name then return end
    BrainSaverDB = BrainSaverDB or {}
    BrainSaverDB.spec = BrainSaverDB.spec or {}
end

-- Event UI_ERROR_MESSAGE
function mainFrame:UI_ERROR_MESSAGE(msg)
    if not (string.find(msg, "^Scrambled brain detected")) then return end
    for i = 0, 16 do
        local ix = GetPlayerBuff(i, "HARMFUL")
        if ix < 0 then break end
        local texture = GetPlayerBuffTexture(ix)
        if string.lower(texture) == "interface\\icons\\spell_shadow_mindrot" then
            local timeRemaining = GetPlayerBuffTimeLeft(ix)
            if timeRemaining then
                UIErrorsFrame:Clear()
                UIErrorsFrame:AddMessage(format("Brainwasher Debuff: %dm %ds", timeRemaining/60, math.mod(timeRemaining,60)), 1, 0, 0)
            end
            break
        end
    end
end

-- Event GOSSIP_CLOSED
function mainFrame:GOSSIP_CLOSED()
    mainFrame:Hide()
end

-- Event GOSSIP_SHOW
function mainFrame:GOSSIP_SHOW()
  if GossipFrameNpcNameText:GetText() ~= "Goblin Brainwashing Device" then return end

  local talentButtons = BrainSaverTalentButtons
  if not talentButtons then
    print("BrainSaver : talentButtons non initialisé")
    return
  end

  local titleButton
  local t1,t2,t3 = TalentCounts()
  local current_spec = FetchTalents()

  local specName = "Unknown spec"
  for i=1,4 do
    local spec = BrainSaverDB.spec[i]
    if spec and spec.talents and IsSameSpec(spec.talents, current_spec) and spec.name then
      specName = spec.name
      break
    end
  end

self.talentSummaryText:SetText(format("Current spec: %s", specName))

  self.gossip_slots = {
    save = {},
    load = {},
    buy = {},
  }

  for i=1, NUMGOSSIPBUTTONS do
    titleButton = _G["GossipTitleButton"..i]

     if titleButton and titleButton:IsVisible() then
      local text = titleButton:GetText()
      local save_spec = tonumber(string.match(text, "Save (%d+)"))
      local load_spec = tonumber(string.match(text, "Activate (%d+)"))
      local buy_spec, price = string.match(text, "Buy (%d+).*Specialization tab for (%d+) gold")
      local isReset = string.find(text, "Reset my talents")

      -- Save
      if save_spec and talentButtons[save_spec] then
        self.gossip_slots.save[save_spec] = titleButton
        talentButtons[save_spec].canSave = true
        talentButtons[save_spec].isActive = true

      -- Load
      elseif load_spec and talentButtons[load_spec] then
        self.gossip_slots.load[load_spec] = titleButton
        talentButtons[load_spec].canLoad = true
        talentButtons[load_spec].isActive = true

      -- Buy
      elseif buy_spec and price then
        local specIndex = tonumber(buy_spec)
        self.gossip_slots.buy[specIndex] = { button = titleButton, price = tonumber(price) }

        for i = specIndex, 4 do
          if talentButtons[i] then
            talentButtons[i].isActive = false
            talentButtons[i]:SetIcon("Interface\\Icons\\INV_Misc_Coin_01", true)
            talentButtons[i]:SetName("")
            talentButtons[i]:SetTalentSummary("Buy Slot")
          end
        end

      -- Reset
      elseif isReset then
        self.gossip_slots.reset = titleButton
      end
    end
  end

  for i=1,4 do
    local button = talentButtons[i]
    local spec = BrainSaverDB.spec[i]
    if button then
      button.isCurrentSpec = false
      if button.isActive then
        if button.canLoad and spec then
          -- load spec data
          button:SetIcon(spec.icon)
          button:SetName(spec.name)
          button:SetTalentSummary(spec.t1, spec.t2, spec.t3)
          if spec.talents and IsSameSpec(spec.talents, current_spec) then
            button.isCurrentSpec = true
          end
        elseif button.canSave then -- if save but no load
          button:SetIcon("Interface\\Icons\\INV_Misc_QuestionMark")
          button:SetName("Spec " .. button.index)
          button:SetTalentSummary("? | ? | ?")
        end
      end
    else
      print("BrainSaver : bouton talentButtons[" .. i .. "] manquant")
    end
  end

  -- If no gossip options, disable washer
  if not self.gossip_slots.reset then
    self.talentSummaryText:SetText("\n\n\n\nBrainwasher not available on this character.")
    for _,btn in pairs(talentButtons) do
      btn:Hide()
    end
    self.resetButton:Hide()
    self.washerButton:Hide()
  else
    for _,btn in pairs(talentButtons) do
      btn:Show()
    end
    self.resetButton:Show()
    self.washerButton:Show()
  end

  GossipFrame:SetAlpha(0) -- hide but don't trigger GOSSIP_CLOSED
  self:Show()
end


-- Expose globalement
BrainSaverMainFrame = mainFrame
