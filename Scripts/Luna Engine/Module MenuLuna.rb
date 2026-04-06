module MenuLuna
  MENU_LIST = ["MainMenu", "ItemMenu", "SkillMenu", "StatusMenu",
               "SaveMenu", "EquipMenu", "ShopMenu"]

  COLOR_LIST = ["normal_color", "system_color", "crisis_color", "knockout_color",
                "gauge_back_color", "hp_gauge_color1", "hp_gauge_color2",
                "mp_gauge_color1", "mp_gauge_color2", "mp_cost_color",
                "power_up_color", "power_down_color", "tp_gauge_color1",
                "tp_gauge_color2", "tp_cost_color"]
  
  MENU_LIST.each { |menu|
    COLOR_LIST.each { |color|
      str = "
        module #{menu}
          def self.#{color}
            return \"#{color}\"
          end
        end
      "
      eval(str)
    }
  }
end