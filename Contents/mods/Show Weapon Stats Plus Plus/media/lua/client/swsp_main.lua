require "ISUI/ISToolTipInv"

local SWSP = require("swsp_options")

local weaponTypes = {
  "Axe",
  "LongBlade",
  "SmallBlade",
  "SmallBlunt", -- small blunt must be checked before blunt
  "Blunt",
  "Spear",
  "Improvised"
}

function SWSP:_round(num, numDecimalPlaces)
  local mult  = 10 ^ (numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function SWSP:_calcEffMaintenance(weaponLevel)
  local maintenanceLevel  = getPlayer():getPerkLevel(Perks.Maintenance)
  local step1             = math.floor(weaponLevel / 2)
  local step2             = maintenanceLevel + step1
  local step3             = math.floor(step2 / 2)
  local effMaintenance    = step3 * 2

  return effMaintenance
end

function SWSP:_calcTreeMaintenance(item)
  local isTreeDamage  = item:getTreeDamage() > 0

  if isTreeDamage then
    local isAxe                 = item:getCategories():contains("Axe")
    local conditionLowerChance  = item:getConditionLowerChance()
    local maintenanceMod        = getPlayer():getMaintenanceMod()
    local treeConditionLower    = 0

    if isAxe then
      treeConditionLower  = conditionLowerChance * 2 + maintenanceMod
    else
      treeConditionLower  = conditionLowerChance / 2 + maintenanceMod
    end

    return math.floor(treeConditionLower)
  else
    return -1
  end
end

function SWSP:initStats(item)
  if not item or not instanceof(item, "HandWeapon") then
    return false
  end

  local weaponType  = ""
  local weaponLevel = 0
  local category    = item:getCategories()
  local isMelee     = item:getSubCategory() ~= "Firearm"

  if isMelee then
    for i, v in ipairs(weaponTypes) do
      if category:contains(tostring(v)) then
        weaponType  = tostring(v)
        weaponLevel = getPlayer():getPerkLevel(Perks[v])
        break
      end
    end
  else
    weaponType  = "Firearm"
    weaponLevel = getPlayer():getPerkLevel(Perks.Aiming)
  end

  if weaponType == "Improvised" and not self.Options.Improvised then
    return false
  end

  self.Text = {}

  -- formatting floats with different precision using string.format is a pain; easier to handle via code
  local minDamage   = tostring(self:_round(item:getMinDamage(), 3))
  local maxDamage   = tostring(self:_round(item:getMaxDamage(), 3))
  local minRange    = tostring(self:_round(item:getMinRange(), 3))
  local maxRange    = tostring(self:_round(item:getMaxRange(), 3))
  local critChance  = tostring(self:_round(item:getCriticalChance(), 3))
  local critDamage  = tostring(self:_round(item:getCritDmgMultiplier(), 3))
  local baseSpeed   = tostring(self:_round(item:getBaseSpeed(), 3))

  if self.Options.WeaponType then
    table.insert(self.Text, getText("Tooltip_SWSP_" .. weaponType))
  end

  table.insert(self.Text, string.format(getText("Tooltip_SWSP_Damage"), minDamage, maxDamage, 30 + weaponLevel * 10))

  if isMelee then
    table.insert(self.Text, string.format(getText("Tooltip_SWSP_Range"), minRange, maxRange))
    table.insert(self.Text, string.format(getText("Tooltip_SWSP_Crit"), critChance, 3 * weaponLevel, critDamage))
    table.insert(self.Text, string.format(getText("Tooltip_SWSP_Speed"), baseSpeed))
  else
    table.insert(self.Text, string.format(getText("Tooltip_SWSP_GunRange"), minRange, maxRange, item:getAimingPerkRangeModifier() * weaponLevel))
    table.insert(self.Text, string.format(getText("Tooltip_SWSP_Crit"), critChance, item:getAimingPerkCritModifier() * weaponLevel, critDamage))
  end

  if self.Options.MaxHit then
    table.insert(self.Text, string.format(getText("Tooltip_SWSP_MaxHit"), item:getMaxHitCount()))
  end

  table.insert(self.Text, string.format(getText("Tooltip_SWSP_Condition"), item:getCondition(), item:getConditionMax()))
  table.insert(self.Text, string.format(getText("Tooltip_SWSP_BreakChance"), item:getConditionLowerChance(), self:_calcEffMaintenance(weaponLevel)))

  local isTreeDamage  = item:getTreeDamage() > 0

  if isTreeDamage and self.Options.TreeBreakChance then
    table.insert(self.Text, string.format(getText("Tooltip_SWSP_TreeBreakChance"), self:_calcTreeMaintenance(item)))
  elseif not isMelee then
    table.insert(self.Text, string.format(getText("Tooltip_SWSP_GunAccuracy"), item:getHitChance(), item:getAimingPerkHitChanceModifier() * weaponLevel))
    table.insert(self.Text, string.format(getText("Tooltip_SWSP_GunMisc"), item:getAimingTime(), item:getReloadTime(), item:getRecoilDelay()))
    table.insert(self.Text, string.format(getText("Tooltip_SWSP_GunNoise"), item:getSoundRadius(), item:getSoundVolume()))
  end

  return true
end

local orig_render = ISToolTipInv.render

function ISToolTipInv:render()
  if not self.item or not SWSP:initStats(self.item) then
    return orig_render(self)
  end

  local font        = UIFont[getCore():getOptionTooltipFont()];
  local colors      = SWSP.Options.Color
  -- set height
  local lineSpacing = self.tooltip:getLineSpacing()
  local width       = self.tooltip:getWidth()
  local height      = self.tooltip:getHeight()
  local newHeight   = height + #SWSP.Text * lineSpacing

  local orig_setHeight = ISToolTipInv.setHeight

  self.setHeight  = function (self, h, ...)
    h = newHeight
    self.keepOnScreen = false -- temp fix for visual bug
    return orig_setHeight(self, h, ...)
  end

  local orig_drawRectBorder = ISToolTipInv.drawRectBorder

  self.drawRectBorder = function (self, ...)
    for _, text in ipairs(SWSP.Text) do
      self.tooltip:DrawText(
        font, text, 5, height,
        colors.r, colors.g, colors.b, 1
      )
      height = height + lineSpacing
    end
    orig_drawRectBorder(self, ...)
  end

  orig_render(self)

  -- return control back to original methods
  self.setHeight      = orig_setHeight
  self.drawRectBorder = orig_drawRectBorder
end

--[[ Citations
  Weapon Level Damage Boost: https://github.com/katupia/PZ_decompile_B41.68_2022_04_25/blob/f85ded64fd1379a768dbc9e932fdb2159a4ee252/java/characters/IsoGameCharacter.java#L4510-L4547
  speedMod: https://github.com/katupia/PZ_decompile_B41.68_2022_04_25/blob/f85ded64fd1379a768dbc9e932fdb2159a4ee252/java/inventory/types/HandWeapon.java#L482-L601
  I believe Maintenance applies to Firearms: https://github.com/katupia/PZ_decompile_B41.68_2022_04_25/blob/f85ded64fd1379a768dbc9e932fdb2159a4ee252/java/ai/states/SwipeStatePlayer.java#L276
  ]]