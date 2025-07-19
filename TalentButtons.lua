local mainFrame = BrainSaverMainFrame
local talentButtons = {}

local function GetDB()
    if not BrainSaverDB then BrainSaverDB = {} end
    if not BrainSaverDB.spec then BrainSaverDB.spec = {} end
    return BrainSaverDB
end

local DB = GetDB()

local Utils = BrainSaverDB.Utils

local numRows, numCols = 2, 2
local btnWidth, btnHeight = 64, 64
local spacing = 40

-- Calcul de la moitié des distances pour positionner autour du centre
local halfBtnWidth = btnWidth / 2
local halfBtnHeight = btnHeight / 2
local halfSpacing = spacing / 2

-- Positions relatives au centre pour chaque bouton (ordre : TL, TR, BL, BR)
local positions = {
    { x = - (halfBtnWidth + halfSpacing), y =  (halfBtnHeight + halfSpacing) }, -- Top Left
    { x =   (halfBtnWidth + halfSpacing), y =  (halfBtnHeight + halfSpacing) }, -- Top Right
    { x = - (halfBtnWidth + halfSpacing), y = - (halfBtnHeight + halfSpacing) }, -- Bottom Left
    { x =   (halfBtnWidth + halfSpacing), y = - (halfBtnHeight + halfSpacing) }, -- Bottom Right
}

-- Fonction utilitaire ColorSpecSummary depuis Utils
local ColorSpecSummary = Utils.ColorSpecSummary

-- Création des boutons
local index = 1
for row = 1, numRows do
    for col = 1, numCols do
        local btn = CreateFrame("Button", "TalentButton"..index, mainFrame, "ActionButtonTemplate")
        btn:SetWidth(btnWidth)
        btn:SetHeight(btnHeight)

        local pos = positions[index]
        btn:SetPoint("CENTER", mainFrame, "CENTER", pos.x -10, pos.y - 20)
        btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        -- Numéro de slot
        btn.slotNumberText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        btn.slotNumberText:SetFont(btn.slotNumberText:GetFont(), 16, "")
        btn.slotNumberText:SetPoint("CENTER", btn, "BOTTOMRIGHT", -8, 9)
        btn.slotNumberText:SetText(index)

        -- Nom au-dessus
        btn.layoutName = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        btn.layoutName:SetPoint("BOTTOM", btn, "TOP", 0, 16)
        if savedSpec and savedSpec.name then
            btn.layoutName:SetText(savedSpec.name)
        else
            btn.layoutName:SetText("Slot " .. index)
        end

        -- Résumé talents
        btn.talentSummary = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        btn.talentSummary:SetPoint("BOTTOM", btn, "TOP", 0, 2)
        btn.talentSummary:SetText("? | ? | ?")

        -- Indicateur actif
        btn.activeIndicator = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        local aif, ais = btn.activeIndicator:GetFont()
        btn.activeIndicator:SetFont(aif, ais, "OUTLINE")
        btn.activeIndicator:SetPoint("CENTER", btn, "CENTER", 0, 0)
        btn.activeIndicator:SetText("")

        -- Prix (optionnel)
        btn.priceText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        local ptf, pts = btn.priceText:GetFont()
        btn.priceText:SetFont(ptf, pts, "OUTLINE")
        btn.priceText:SetPoint("CENTER", btn, "CENTER", 0, 0)
        btn.priceText:SetText("")

        -- Méthodes
        function btn:SetName(name)
            self.layoutName:SetText(name)
        end
        function btn:SetTalentSummary(t1, t2, t3)
            if not t1 then
                self.talentSummary:SetText("? | ? | ?")
            elseif type(t1) == "string" then
                self.talentSummary:SetText(t1)
            else
                self.talentSummary:SetText(ColorSpecSummary(t1, t2, t3))
            end
        end

        function btn:SetIcon(iconPath, disabled)
            if type(iconPath) ~= "string" or iconPath == "" then
                iconPath = "Interface\\Icons\\INV_Misc_QuestionMark"
            end
            self:SetNormalTexture(iconPath)
            self:SetPushedTexture(iconPath)
            if disabled then
                self:GetNormalTexture():SetVertexColor(0.5, 0.5, 0.5)
            else
                self:GetNormalTexture():SetVertexColor(1, 1, 1)
            end
        end

        -- Chargement des données sauvegardées
        local savedSpec = GetDB().spec[index]
        if savedSpec then
            if savedSpec.icon then
                btn:SetIcon(savedSpec.icon)
            else
                btn:SetIcon("Interface\\Icons\\INV_Misc_QuestionMark")
            end
            if savedSpec.name then
                btn:SetName(savedSpec.name)
            end
            if savedSpec.t1 and savedSpec.t2 and savedSpec.t3 then
                btn:SetTalentSummary(savedSpec.t1, savedSpec.t2, savedSpec.t3)
            end
            btn.isActive = true
        else
            btn:SetIcon("Interface\\Icons\\INV_Misc_QuestionMark", true)
            btn.isActive = false
        end

        -- Met à jour l'indicateur actif
        btn:SetScript("OnShow", function(self)
            local idx = this.index
            local buyData = mainFrame.gossip_slots.buy and mainFrame.gossip_slots.buy[idx]

            if this.isCurrentSpec then
                this.activeIndicator:SetText("|cff00ff00ACTIVE|r")
                if this.priceText then
                    this.priceText:SetText("")
                end
            elseif buyData and buyData.price then
                this.activeIndicator:SetText("")
                if this.priceText then
                    this.priceText:SetText(buyData.price.. " g")
                end
            else
                this.activeIndicator:SetText("")
                 if this.priceText then
                    this.priceText:SetText("")
                end
            end
        end)

        -- Gère le clic : affiche le menu contextuel
        btn:SetScript("OnClick", function()
            local clickType = arg1
            local idx = this.index
            local anchor = this
            local DB = GetDB()

            if clickType == "LeftButton" then
                
                if this.isCurrentSpec then return end

                mainFrame.currentButton = idx

                local spec = DB and DB.spec and DB.spec[idx]
                local buyData = mainFrame.gossip_slots.buy and mainFrame.gossip_slots.buy[idx]

                if buyData and buyData.price then
                    StaticPopup_Show("BUY_TALENT_SLOT", buyData.price)
                elseif spec and spec.t1 and spec.t2 and spec.t3 then
                    StaticPopup_Show("ENABLE_TALENT_LAYOUT")
                end

            elseif clickType == "RightButton" then
                BrainSaverShowContextMenu(idx, anchor)
            end
        end)


        btn.index = index
        talentButtons[index] = btn
        index = index + 1
    end
end

-- Expose globalement
BrainSaverTalentButtons = talentButtons
