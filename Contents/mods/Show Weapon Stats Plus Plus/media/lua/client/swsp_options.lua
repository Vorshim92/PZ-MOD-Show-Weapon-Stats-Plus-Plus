local SWSP  = {}

SWSP.Options = {
  WeaponType      = true,
  Improvised      = false,
  MaxHit          = true,
  TreeBreakChance = true,
  Color           = {r=0.68, g=0.64, b=0.96}
}

if Mod.IsMCMInstalled_v1 then
  local MyModOptions = ModOptionTable:New("ShowWeaponStatsPlus", "Show Weapon Stats Plus", false)
  -- ExampleOptionTable:AddModOption("BoxEnable", "checkbox", BoxEnable, nil, "Enable", nil, function(value)
	-- 	BoxEnable = value
	-- end)

  MyModOptions:AddModOption("Improvised", "checkbox",
                              SWSP.Options.Improvised, nil,
                              getText("UI_SWSP_Option_Improvised"), nil,
                              function (value)
                                SWSP.Options.Improvised  = value
                              end
                            )

  MyModOptions:AddModOption("WeaponType", "checkbox",
                              SWSP.Options.WeaponType, nil,
                              getText("UI_SWSP_Option_WeaponType"), nil,
                              function (value)
                                SWSP.Options.WeaponType  = value
                              end
                            )

  MyModOptions:AddModOption("MaxHit", "checkbox",
                              SWSP.Options.MaxHit, nil,
                              getText("UI_SWSP_Option_MaxHit"), nil,
                              function (value)
                                SWSP.Options.MaxHit = value
                              end
                            )
  MyModOptions:AddModOption("TreeBreakChance", "checkbox",
                              SWSP.Options.TreeBreakChance, nil,
                              getText("UI_SWSP_Option_Tree"), nil,
                              function (value)
                                SWSP.Options.TreeBreakChance = value
                              end
                            )
  MyModOptions:AddModOption("TextColor", "color",
                              SWSP.Options.Color, nil,
                              getText("UI_SWSP_Option_TextColor"), nil,
                              function (value)
                                SWSP.Options.Color = value
                              end
                            )
end

return SWSP