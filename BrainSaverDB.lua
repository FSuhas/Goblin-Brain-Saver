BrainSaverDB = BrainSaverDB or {}
BrainSaverDB.spec = BrainSaverDB.spec or {}

addon_name = "Goblin Brain Saver"

_G = _G or getfenv(0)

mainFrame = _G[addon_name.."Frame"]

dialog_alpha = 0.35

-- Fonction utilitaire pour vérifier si 2 specs sont identiques (counts des talents)
function IsSameSpec(t1, t2)
  if not t1 or not t2 then return false end
  for i, tab in ipairs(t1) do
    for j, talent in ipairs(tab) do
      if not (t2[i] and t2[i][j] and talent.count == t2[i][j].count) then
        return false
      end
    end
  end
  return true
end

-- Retourne le résumé coloré des talents (ex : "12 | 0 | 9")
function ColorSpecSummary(t1, t2, t3)
  t1 = tonumber(t1) or 0
  t2 = tonumber(t2) or 0
  t3 = tonumber(t3) or 0

  local largest  = math.max(t1, t2, t3)
  local smallest = math.min(t1, t2, t3)

  local function getColor(value)
      if value == largest then
          return "|cff00ff00"  -- Vert
      elseif value == smallest then
          return "|cff0077ff"  -- Bleu
      else
          return "|cffffff00"  -- Jaune
      end
  end

  return string.format("%s%d|r | %s%d|r | %s%d|r",
      getColor(t1), t1,
      getColor(t2), t2,
      getColor(t3), t3)
end


-- Fonction qui récupère les counts de talents actuels
function TalentCounts()
  local _,_,t1 = GetTalentTabInfo(1)
  local _,_,t2 = GetTalentTabInfo(2)
  local _,_,t3 = GetTalentTabInfo(3)
  return t1,t2,t3
end

-- Fonction qui récupère tous les talents actuels sous forme table
function FetchTalents()
  local talents = {}
  for tab=1,3 do
    talents[tab] = {}
    for talent=1,100 do
      local name,icon,row,col,count,max = GetTalentInfo(tab,talent)
      if not name then break end
      talents[tab][talent] = { name=name, icon=icon, row=row, col=col, count=count, max=max }
    end
  end
  return talents
end

-- Expose les fonctions via une table globale simple
BrainSaverDB.Utils = {
  IsSameSpec = IsSameSpec,
  ColorSpecSummary = ColorSpecSummary,
  TalentCounts = TalentCounts,
  FetchTalents = FetchTalents,
}
