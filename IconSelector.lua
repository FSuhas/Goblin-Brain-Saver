local function mod(a, b)
  return a - math.floor(a / b) * b
end

local function CreateLegacyIconSelector()
  local f = CreateFrame("Frame", "BrainSaverIconSelector", UIParent)
  f:SetWidth(340)
  f:SetHeight(320)
  f:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
  })
  f:SetPoint("CENTER", UIParent, "CENTER")
  f:EnableMouse(true)
  f:SetMovable(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function() f:StartMoving() end)
  f:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)
  f:Hide()

  local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  title:SetText("Choose an Icon")
  title:SetPoint("TOP", 0, -16)

  local scrollFrame = CreateFrame("ScrollFrame", "BrainSaverIconSelectorScrollFrame", f, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -40)
  scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 10)

  local content = CreateFrame("Frame", nil, scrollFrame)
  content:SetWidth(300)
  scrollFrame:SetScrollChild(content)

  -- Liste des icônes prédéfinies (exemple réduit)
  local ICON_LIST = {
    "INV_Misc_QuestionMark",
    "Ability_Ambush",
    "Ability_BackStab",
    "Ability_CheapShot",
    "Ability_CriticalStrike",
    "Ability_Defend",
    "Ability_DualWield",
    "Ability_EyeOfTheOwl",
    --"Ability_FeignDeath",
    "Ability_GhoulFrenzy",
    "Ability_Gouge",
    "Ability_Hibernation",
    "Ability_Hunter_RunningShot",
    "Ability_Kick",
    "Ability_Marksmanship",
    "Ability_MeleeDamage",
    "Ability_Racial_BloodRage",
    "Ability_Throw",
    "Ability_ThunderBolt",
    "Ability_Tracking",
    "Ability_Whirlwind",

    -- Guerrier
    "Ability_Warrior_Charge",
    "Ability_Warrior_Cleave",
    "Ability_Warrior_DefensiveStance",
    "Ability_Warrior_Disarm",
    "Ability_Warrior_InnerRage",
    "Ability_Warrior_PunishingBlow",
    "Ability_Warrior_Revenge",
    "Ability_Warrior_Riposte",
    "Ability_Warrior_SavageBlow",
    "Ability_Warrior_ShieldBash",
    "Ability_Warrior_ShieldWall",
    "Ability_Warrior_Sunder",
    --"Ability_Warrior_Taunt",
    "Ability_Warrior_RallyingCry",
    "Ability_Warrior_WarCry",

    -- Paladin
    "Spell_Holy_HolyBolt",
    "Spell_Holy_SealOfMight",
    "Spell_Holy_SealOfRighteousness",
    "Spell_Holy_SealOfSalvation",
    --"Spell_Holy_SealOfLight",
    "Spell_Holy_SealOfWisdom",
    "Spell_Holy_AuraOfLight",
    "Spell_Holy_BlessingOfProtection",
    --"Spell_Holy_BlessingOfSacrifice",
    --"Spell_Holy_BlessingOfMight",
    --"Spell_Holy_BlessingOfKings",
    "Spell_Holy_Excorcism_02",
    --"Ability_Paladin_HolyAvenger",

    -- Chasseur
    "Ability_Hunter_AspectOfTheMonkey",
    --"Ability_Hunter_AspectOfTheHawk",
    --"Ability_Hunter_AspectOfTheCheetah",
    --"Ability_Hunter_AspectOfThePack",
    --"Ability_Hunter_ExplosiveTrap",
    --"Ability_Hunter_FrostTrap",
    "Ability_Hunter_Pet_Bear",
    "Ability_Hunter_Pet_Cat",
    "Ability_Hunter_Pet_Crab",
    "Ability_Hunter_Pet_Crocolisk",
    "Ability_Hunter_Pet_Gorilla",
    "Ability_Hunter_Pet_Hyena",
    "Ability_Hunter_Pet_Owl",
    "Ability_Hunter_Pet_Raptor",
    "Ability_Hunter_Pet_Scorpid",
    "Ability_Hunter_Pet_Spider",
    "Ability_Hunter_Pet_TallStrider",
    "Ability_Hunter_Pet_Turtle",
    "Ability_Hunter_Pet_WindSerpent",
    "Ability_Hunter_Pet_Wolf",
    "Ability_Hunter_SniperShot",
    "Ability_Hunter_SteadyShot",

    -- Voleur
    "Ability_Rogue_Eviscerate",
    "Ability_Rogue_KidneyShot",
    "Ability_Rogue_SliceDice",
    --"Ability_Rogue_SinisterStrike",
    "Ability_Rogue_FeignDeath",
    "Ability_Rogue_Garrote",
    "Ability_Rogue_Rupture",
    --"Ability_Rogue_DualWield",
    "Ability_Rogue_Disguise",
    "Ability_Rogue_Trip",

    -- Prêtre
    "Spell_Holy_FlashHeal",
    "Spell_Holy_GreaterHeal",
    "Spell_Holy_Heal",
    "Spell_Holy_HolyBolt",
    "Spell_Holy_PowerWordShield",
    "Spell_Holy_Renew",
    --"Spell_Holy_Serendipity",
    --"Spell_Holy_Shield",
    "Spell_Holy_PrayerOfHealing",
    --"Spell_Holy_Penance",
    "Spell_Holy_MindSooth",
    "Spell_Holy_MindVision",
    "Spell_Holy_DispelMagic",

    -- Chaman
    "Spell_Nature_HealingWaveLesser",
    --"Spell_Nature_HealingWave",
    "Spell_Nature_Lightning",
    "Spell_Nature_LightningBolt",
    "Spell_Nature_LightningShield",
    "Spell_Nature_MagicImmunity",
    "Spell_Nature_StoneClawTotem",
    "Spell_Nature_StoneSkinTotem",
    "Spell_Nature_Strength",
    "Spell_Nature_ThunderClap",
    "Spell_Nature_Windfury",
    "Spell_Nature_WispHeal",
    "Spell_Nature_EarthBind",
    "Spell_Nature_Earthquake",

    -- Mage
    "Spell_Frost_FrostBolt02",
    "Spell_Frost_FrostBolt",
    "Spell_Frost_IceStorm",
    "Spell_Frost_FrostNova",
    "Spell_Frost_FrostArmor",
    "Spell_Frost_ChainsOfIce",
    --"Spell_Frost_Blizzard",
    --"Spell_Frost_ColdSnap",
    "Spell_Frost_FrostWard",
    --"Spell_Frost_ManaShield",
    --"Spell_Frost_Polymorph",
    --"Spell_Frost_Frostfire",

    -- Démoniste
    "Spell_Shadow_Curse",
    --"Spell_Shadow_Corruption",
    "Spell_Shadow_DeathCoil",
    "Spell_Shadow_EnslaveDemon",
    --"Spell_Shadow_Fear",
    "Spell_Shadow_ImpPhaseShift",
    "Spell_Shadow_LifeDrain",
    "Spell_Shadow_Metamorphosis",
    "Spell_Shadow_RainOfFire",
    "Spell_Shadow_SiphonMana",
    "Spell_Shadow_SummonFelHunter",
    "Spell_Shadow_SummonSuccubus",
    "Spell_Shadow_SummonVoidWalker",
    "Spell_Shadow_SummonInfernal",

    -- Druide
    "Ability_Druid_AquaticForm",
    "Ability_Druid_Bash",
    --"Ability_Druid_BearForm",
    "Ability_Druid_CatForm",
    --"Ability_Druid_HealingTouch",
    "Ability_Druid_Maul",
    --"Ability_Druid_Rejuvenation",
    --"Ability_Druid_Regrowth",
    "Ability_Druid_Swipe",
    --"Ability_Druid_Thorns",
    "Ability_Druid_TravelForm",
    "Ability_Mount_WhiteTiger",
    "Ability_Mount_JungleTiger",

    -- Armes
    "INV_Weapon_ShortBlade_01",
    "INV_Weapon_ShortBlade_02",
    "INV_Weapon_ShortBlade_03",
    "INV_Weapon_ShortBlade_04",
    "INV_Weapon_ShortBlade_05",
    "INV_Weapon_Rifle_01",
    "INV_Weapon_Rifle_02",
    "INV_Weapon_Rifle_03",
    "INV_Weapon_Bow_01",
    "INV_Weapon_Bow_02",
    "INV_Weapon_Bow_03",
    "INV_Weapon_Bow_04",
    "INV_Weapon_Bow_05",
    "INV_Weapon_Crossbow_01",
    "INV_Weapon_Crossbow_02",
    "INV_Weapon_Crossbow_03",
    "INV_Weapon_Crossbow_04",
    "INV_Weapon_Crossbow_05",
    "INV_Weapon_Halberd_02",
    "INV_Weapon_Halberd_03",
    "INV_Weapon_Halberd_04",
    "INV_Weapon_Halberd_05",

    -- Armures
    "INV_Chest_Chain_05",
    "INV_Chest_Chain_06",
    "INV_Chest_Leather_07",
    "INV_Chest_Leather_08",
    "INV_Chest_Cloth_01",
    "INV_Chest_Cloth_02",
    "INV_Chest_Cloth_03",
    "INV_Chest_Plate03",
    "INV_Chest_Plate04",
    "INV_Chest_Plate05",
    "INV_Chest_Plate06",
    "INV_Boots_01",
    "INV_Boots_02",
    "INV_Boots_03",
    "INV_Boots_04",
    "INV_Boots_05",
    "INV_Belt_01",
    "INV_Belt_02",
    "INV_Belt_03",
    "INV_Belt_04",
    "INV_Belt_05",

    -- Casques
    "INV_Helmet_01",
    "INV_Helmet_02",
    "INV_Helmet_03",
    "INV_Helmet_04",
    "INV_Helmet_05",
    "INV_Helmet_06",
    "INV_Helmet_07",
    "INV_Helmet_08",
    "INV_Helmet_09",
    "INV_Helmet_10",

    -- Divers / Consommables / Montures / Têtes de monstres
    "INV_Misc_Book_01",
    "INV_Misc_Book_02",
    "INV_Misc_Book_03",
    "INV_Misc_Book_04",
    "INV_Misc_Book_05",
    "INV_Misc_Book_06",
    "INV_Misc_Book_07",
    "INV_Misc_Book_08",
    "INV_Misc_Book_09",
    "INV_Misc_EngGizmos_01",
    "INV_Misc_EngGizmos_02",
    "INV_Misc_EngGizmos_03",
    "INV_Misc_EngGizmos_04",
    "INV_Misc_Food_01",
    "INV_Misc_Food_02",
    "INV_Misc_Food_03",
    "INV_Misc_Food_04",
    "INV_Misc_Food_05",
    "INV_Misc_Gem_Emerald_01",
    "INV_Misc_Gem_Ruby_01",
    "INV_Misc_Gem_Sapphire_01",
    "INV_Misc_Herb_01",
    "INV_Misc_Herb_02",
    "INV_Misc_Herb_03",
    "INV_Misc_Orb_01",
    "INV_Misc_Orb_02",
    "INV_Misc_Pelt_Bear_01",
    "INV_Misc_Pelt_Wolf_01",
    "INV_Misc_Rune_01",
    "INV_Misc_Rune_02",
    "INV_Misc_StoneTablet_01",
    "INV_Misc_StoneTablet_02",
    "INV_Misc_StoneTablet_03",
    "INV_Misc_StoneTablet_04",
    "INV_Misc_StoneTablet_05",
    "INV_Misc_Head_Orc_01",
    "INV_Misc_Head_Orc_02",
    "INV_Misc_Head_Tauren_01",
    "INV_Misc_Head_Tauren_02",
    "INV_Misc_Head_Troll_01",
    "INV_Misc_Head_Troll_02",
    "INV_Misc_Head_Human_01",
    "INV_Misc_Head_Human_02",
    "INV_Misc_Head_Dwarf_01",
    "INV_Misc_Head_Dwarf_02",

    -- Potions & Consommables
    "INV_Potion_01",
    "INV_Potion_02",
    "INV_Potion_03",
    "INV_Potion_04",
    "INV_Potion_05",
    "INV_Potion_06",
    "INV_Potion_07",
    "INV_Potion_08",
    "INV_Potion_09",
    "INV_Potion_10",
    "INV_Potion_11",
    "INV_Potion_12",

    -- Montures
    "Ability_Mount_RidingHorse",
    "Ability_Mount_Dreadsteed",
    "Ability_Mount_BlackDireWolf",
    "Ability_Mount_WhiteTiger",
    "Ability_Mount_JungleTiger",
    "Ability_Mount_MountainRam",
  }

  local buttonsPerRow = 7
  local spacing = 40
  local offsetX, offsetY = 0, 0

  local iconCount = table.getn(ICON_LIST)
  f.iconButtons = {}

  for i = 1, iconCount do
    local thisIconName = ICON_LIST[i]
    local button = CreateFrame("Button", nil, content)
    button:SetWidth(36)
    button:SetHeight(36)

    local row = math.floor((i - 1) / buttonsPerRow)
    local col = mod(i - 1, buttonsPerRow)

    button:SetPoint("TOPLEFT", content, "TOPLEFT", offsetX + col * spacing, offsetY - row * spacing)

    local tex = button:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexture("Interface\\Icons\\" .. thisIconName)
    button.texture = tex
    button.iconName = thisIconName

    local highlight = button:CreateTexture(nil, "OVERLAY")
    highlight:SetAllPoints()
    highlight:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    highlight:SetVertexColor(1, 1, 0, 0.5)
    highlight:Hide()
    button.highlight = highlight

    button:SetScript("OnClick", function()
      if f.selectedCallback then
        f.selectedCallback("Interface\\Icons\\" .. thisIconName)
      end
      f:Hide()
    end)

    table.insert(f.iconButtons, button)
  end

  local totalRows = math.ceil(iconCount / buttonsPerRow)
  content:SetHeight(totalRows * spacing)

  function f:ShowSelector(callback, currentIcon)
    self.selectedCallback = callback
    self:Show()

    for _, btn in ipairs(self.iconButtons) do
      if ("Interface\\Icons\\" .. btn.iconName) == currentIcon then
        btn.highlight:Show()
      else
        btn.highlight:Hide()
      end
    end
  end

  return f
end

BrainSaver_IconSelector = BrainSaver_IconSelector or CreateLegacyIconSelector()
