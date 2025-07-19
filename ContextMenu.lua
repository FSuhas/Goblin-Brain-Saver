local menuFrame = CreateFrame("Frame", "BrainSaverContextMenuFrame", UIParent, "UIDropDownMenuTemplate")

BrainSaverContextMenu = {}

function BrainSaverContextMenu:Show(parentButton, options)
  local menuList = {}

  for i, opt in ipairs(options) do
    table.insert(menuList, {
      text = opt.text or "Option "..i,
      func = function()
        if opt.func then opt.func() end
        CloseDropDownMenus()
      end,
      notCheckable = true,
    })
  end

  EasyMenu(menuList, menuFrame, parentButton, 0 , 0, "MENU")
end
