-- Chargement des modules
local function LoadBrainSaverModules()
    BrainSaverDB = BrainSaverDB or { spec = {} }

    -- Chargement UI principale
    if BrainSaver_MainUI_Init then
        BrainSaver_MainUI_Init()
    end

    -- Chargement du menu contextuel
    if BrainSaver_ContextMenu_Init then
        BrainSaver_ContextMenu_Init()
    end

    -- Chargement popup de renommage
    if BrainSaver_Popup_Init then
        BrainSaver_Popup_Init()
    end

    -- Chargement sélecteur d'icônes
    if BrainSaver_IconSelector_Init then
        BrainSaver_IconSelector_Init()
    end
end

-- Chargement à la connexion
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    LoadBrainSaverModules()
end)

